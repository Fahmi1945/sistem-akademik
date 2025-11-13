//========================================
// FILE: providers/nilai_provider.dart
// ========================================

import 'package:flutter/material.dart';
import '../models/nilai.dart';
import '../database/database_helper.dart';

class NilaiProvider with ChangeNotifier {
  List<Nilai> _nilaiList = [];
  bool _isLoading = false;
  String _selectedSiswaId = '';
  String _selectedMapel = '';

  List<Nilai> get nilaiList {
    List<Nilai> filtered = _nilaiList;

    if (_selectedSiswaId.isNotEmpty) {
      filtered = filtered.where((n) => n.siswaId == _selectedSiswaId).toList();
    }

    if (_selectedMapel.isNotEmpty) {
      filtered = filtered
          .where((n) => n.mataPelajaran == _selectedMapel)
          .toList();
    }

    return filtered;
  }

  List<Nilai> get allNilai => _nilaiList;
  bool get isLoading => _isLoading;
  String get selectedSiswaId => _selectedSiswaId;
  String get selectedMapel => _selectedMapel;

  void setSelectedSiswa(String siswaId) {
    _selectedSiswaId = siswaId;
    notifyListeners();
  }

  void setSelectedMapel(String mapel) {
    _selectedMapel = mapel;
    notifyListeners();
  }

  void clearFilters() {
    _selectedSiswaId = '';
    _selectedMapel = '';
    notifyListeners();
  }

  Future<void> loadNilai() async {
    _isLoading = true;
    notifyListeners();

    try {
      _nilaiList = await DatabaseHelper.instance.getAllNilai();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNilaiBySiswa(String siswaId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _nilaiList = await DatabaseHelper.instance.getNilaiBySiswa(siswaId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addOrUpdateNilai(Nilai nilai) async {
    try {
      // Cek apakah nilai sudah ada
      final existing = await DatabaseHelper.instance.getNilaiSiswaMapel(
        nilai.siswaId,
        nilai.mataPelajaran,
      );

      if (existing != null) {
        // Update
        await DatabaseHelper.instance.updateNilai(
          nilai.copyWith(id: existing.id),
        );
      } else {
        // Create
        await DatabaseHelper.instance.createNilai(nilai);
      }

      await loadNilai();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateNilai(Nilai nilai) async {
    try {
      await DatabaseHelper.instance.updateNilai(nilai);
      await loadNilai();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNilai(int id) async {
    try {
      await DatabaseHelper.instance.deleteNilai(id);
      await loadNilai();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Nilai>> getNilaiBySiswa(String siswaId) async {
    return await DatabaseHelper.instance.getNilaiBySiswa(siswaId);
  }

  // Statistik nilai siswa
  Map<String, dynamic> getStatistikSiswa(String siswaId) {
    final nilaiSiswa = _nilaiList.where((n) => n.siswaId == siswaId).toList();

    if (nilaiSiswa.isEmpty) {
      return {
        'totalMapel': 0,
        'rataRata': 0.0,
        'nilaiTertinggi': 0.0,
        'nilaiTerendah': 0.0,
        'jumlahA': 0,
        'jumlahB': 0,
        'jumlahC': 0,
        'jumlahD': 0,
      };
    }

    double totalNilai = 0;
    double nilaiTertinggi = 0;
    double nilaiTerendah = 100;
    int jumlahA = 0, jumlahB = 0, jumlahC = 0, jumlahD = 0;

    for (var nilai in nilaiSiswa) {
      totalNilai += nilai.nilaiAkhir;
      if (nilai.nilaiAkhir > nilaiTertinggi) nilaiTertinggi = nilai.nilaiAkhir;
      if (nilai.nilaiAkhir < nilaiTerendah) nilaiTerendah = nilai.nilaiAkhir;

      switch (nilai.predikat) {
        case 'A':
          jumlahA++;
          break;
        case 'B':
          jumlahB++;
          break;
        case 'C':
          jumlahC++;
          break;
        case 'D':
          jumlahD++;
          break;
      }
    }

    return {
      'totalMapel': nilaiSiswa.length,
      'rataRata': totalNilai / nilaiSiswa.length,
      'nilaiTertinggi': nilaiTertinggi,
      'nilaiTerendah': nilaiTerendah,
      'jumlahA': jumlahA,
      'jumlahB': jumlahB,
      'jumlahC': jumlahC,
      'jumlahD': jumlahD,
    };
  }

  List<String> getAvailableMapel() {
    final mapelSet = _nilaiList.map((n) => n.mataPelajaran).toSet();
    final mapelList = mapelSet.toList();
    mapelList.sort();
    return mapelList;
  }
}
