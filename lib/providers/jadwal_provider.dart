// ========================================
// FILE: providers/jadwal_provider.dart
// ========================================

import 'package:flutter/material.dart';
import '../models/jadwal.dart';
import '../database/database_helper.dart';

class JadwalProvider with ChangeNotifier {
  List<Jadwal> _jadwalList = [];
  bool _isLoading = false;
  String _selectedKelas = '';

  List<Jadwal> get jadwalList {
    if (_selectedKelas.isEmpty) {
      return _jadwalList;
    }
    return _jadwalList
        .where((jadwal) => jadwal.kelas == _selectedKelas)
        .toList();
  }

  List<Jadwal> get allJadwal => _jadwalList;
  bool get isLoading => _isLoading;
  String get selectedKelas => _selectedKelas;

  void setSelectedKelas(String kelas) {
    _selectedKelas = kelas;
    notifyListeners();
  }

  Future<void> loadJadwal() async {
    _isLoading = true;
    notifyListeners();

    try {
      _jadwalList = await DatabaseHelper.instance.getAllJadwal();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadJadwalByKelas(String kelas) async {
    _isLoading = true;
    notifyListeners();

    try {
      _jadwalList = await DatabaseHelper.instance.getJadwalByKelas(kelas);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addJadwal(Jadwal jadwal) async {
    try {
      await DatabaseHelper.instance.createJadwal(jadwal);
      await loadJadwal();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateJadwal(Jadwal jadwal) async {
    try {
      await DatabaseHelper.instance.updateJadwal(jadwal);
      await loadJadwal();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteJadwal(int id) async {
    try {
      await DatabaseHelper.instance.deleteJadwal(id);
      await loadJadwal();
    } catch (e) {
      rethrow;
    }
  }

  Map<String, List<Jadwal>> getJadwalGroupedByHari() {
    final Map<String, List<Jadwal>> grouped = {};
    final hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

    for (var hari in hariList) {
      grouped[hari] = jadwalList.where((j) => j.hari == hari).toList();
    }

    return grouped;
  }

  List<String> getAvailableKelas() {
    final kelasSet = _jadwalList.map((j) => j.kelas).toSet();
    final kelasList = kelasSet.toList();
    kelasList.sort();
    return kelasList;
  }
}
