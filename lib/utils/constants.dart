
// ========================================
// FILE: utils/constants.dart
// ========================================

import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Sistem Informasi Akademik';
  static const String schoolName = 'Sekolah XYZ';
  static const String tahunAjaran = '2024/2025';

  // Colors
  static const Color primaryColor = Colors.blue;
  static const Color adminColor = Colors.blue;
  static const Color guruColor = Colors.green;
  static const Color siswaColor = Colors.purple;

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleGuru = 'guru';
  static const String roleSiswa = 'siswa';

  // Predikat
  static const Map<String, String> predikatDesc = {
    'A': 'Sangat Baik',
    'B': 'Baik',
    'C': 'Cukup',
    'D': 'Kurang',
  };

  static const Map<String, Color> predikatColors = {
    'A': Colors.green,
    'B': Colors.blue,
    'C': Colors.orange,
    'D': Colors.red,
  };

  // Hari
  static const List<String> hariList = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  // Kelas
  static const List<String> kelasList = [
    'X IPA 1', 'X IPA 2', 'X IPS 1', 'X IPS 2',
    'XI IPA 1', 'XI IPA 2', 'XI IPS 1', 'XI IPS 2',
    'XII IPA 1', 'XII IPA 2', 'XII IPS 1', 'XII IPS 2',
  ];

  // Jurusan
  static const List<String> jurusanList = [
    'IPA',
    'IPS',
  ];

  // Nilai Config
  static const double bobotTugas = 0.3;
  static const double bobotUTS = 0.3;
  static const double bobotUAS = 0.4;

  // Grade Boundaries
  static const double gradeA = 85;
  static const double gradeB = 75;
  static const double gradeC = 65;

  static String getPredikat(double nilaiAkhir) {
    if (nilaiAkhir >= gradeA) return 'A';
    if (nilaiAkhir >= gradeB) return 'B';
    if (nilaiAkhir >= gradeC) return 'C';
    return 'D';
  }

  static Color getPredikatColor(String predikat) {
    return predikatColors[predikat] ?? Colors.grey;
  }

  static String getPredikatDescription(String predikat) {
    return predikatDesc[predikat] ?? '-';
  }
}

