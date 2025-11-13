// ========================================
// FILE: providers/guru_provider.dart
// ========================================
import 'package:flutter/material.dart';
import '../models/guru.dart';
import '../database/database_helper.dart';

class GuruProvider with ChangeNotifier {
  List<Guru> _guruList = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Guru> get guruList {
    if (_searchQuery.isEmpty) {
      return _guruList;
    }
    return _guruList.where((guru) {
      return guru.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          guru.nip.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          guru.mataPelajaran.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadGuru() async {
    _isLoading = true;
    notifyListeners();

    try {
      _guruList = await DatabaseHelper.instance.getAllGuru();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGuru(Guru guru) async {
    try {
      await DatabaseHelper.instance.createGuru(guru);
      await loadGuru();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateGuru(Guru guru) async {
    try {
      await DatabaseHelper.instance.updateGuru(guru);
      await loadGuru();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGuru(int id) async {
    try {
      await DatabaseHelper.instance.deleteGuru(id);
      await loadGuru();
    } catch (e) {
      rethrow;
    }
  }

  Future<Guru?> getGuruByNip(String nip) async {
    return await DatabaseHelper.instance.getGuruByNip(nip);
  }

  List<String> getAvailableMapel() {
    final mapelSet = _guruList.map((g) => g.mataPelajaran).toSet();
    final mapelList = mapelSet.toList();
    mapelList.sort();
    return mapelList;
  }
}
