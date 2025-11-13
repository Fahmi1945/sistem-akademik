// ========================================
// FILE: providers/pengumuman_provider.dart
// ========================================

import 'package:flutter/material.dart';
import '../models/pengumuman.dart';
import '../database/database_helper.dart';

class PengumumanProvider with ChangeNotifier {
  List<Pengumuman> _pengumumanList = [];
  bool _isLoading = false;

  List<Pengumuman> get pengumumanList => _pengumumanList;
  bool get isLoading => _isLoading;

  List<Pengumuman> get pengumumanBaru {
    return _pengumumanList.where((p) => p.isBaru).toList();
  }

  int get jumlahPengumumanBaru => pengumumanBaru.length;

  Future<void> loadPengumuman() async {
    _isLoading = true;
    notifyListeners();

    try {
      _pengumumanList = await DatabaseHelper.instance.getAllPengumuman();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPengumuman(Pengumuman pengumuman) async {
    try {
      await DatabaseHelper.instance.createPengumuman(pengumuman);
      await loadPengumuman();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePengumuman(Pengumuman pengumuman) async {
    try {
      await DatabaseHelper.instance.updatePengumuman(pengumuman);
      await loadPengumuman();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePengumuman(int id) async {
    try {
      await DatabaseHelper.instance.deletePengumuman(id);
      await loadPengumuman();
    } catch (e) {
      rethrow;
    }
  }

  Future<Pengumuman?> getPengumumanById(int id) async {
    return await DatabaseHelper.instance.getPengumumanById(id);
  }
}
