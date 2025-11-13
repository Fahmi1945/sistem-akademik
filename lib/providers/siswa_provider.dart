// ========================================
// FILE: providers/siswa_provider.dart
// ========================================

import 'package:flutter/material.dart';
import '../models/siswa.dart';
import '../database/database_helper.dart';

class SiswaProvider with ChangeNotifier {
  List<Siswa> _siswaList = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Siswa> get siswaList {
    if (_searchQuery.isEmpty) {
      return _siswaList;
    }
    return _siswaList.where((siswa) {
      return siswa.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          siswa.nis.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          siswa.kelas.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadSiswa() async {
    _isLoading = true;
    notifyListeners();

    try {
      _siswaList = await DatabaseHelper.instance.getAllSiswa();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSiswa(Siswa siswa) async {
    try {
      await DatabaseHelper.instance.createSiswa(siswa);
      await loadSiswa();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSiswa(Siswa siswa) async {
    try {
      await DatabaseHelper.instance.updateSiswa(siswa);
      await loadSiswa();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSiswa(int id) async {
    try {
      await DatabaseHelper.instance.deleteSiswa(id);
      await loadSiswa();
    } catch (e) {
      rethrow;
    }
  }

  Future<Siswa?> getSiswaByNis(String nis) async {
    return await DatabaseHelper.instance.getSiswaByNis(nis);
  }

  Future<List<Siswa>> getSiswaByKelas(String kelas) async {
    return await DatabaseHelper.instance.getSiswaByKelas(kelas);
  }

  List<String> getAvailableKelas() {
    final kelasSet = _siswaList.map((s) => s.kelas).toSet();
    final kelasList = kelasSet.toList();
    kelasList.sort();
    return kelasList;
  }

  List<String> getAvailableJurusan() {
    final jurusanSet = _siswaList.map((s) => s.jurusan).toSet();
    return jurusanSet.toList();
  }
}
