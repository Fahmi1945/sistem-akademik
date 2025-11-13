// ========================================
// FILE: models/nilai.dart
// ========================================

class Nilai {
  final int? id;
  final String siswaId; // NIS siswa
  final String siswaNama;
  final String mataPelajaran;
  final double nilaiTugas;
  final double nilaiUTS;
  final double nilaiUAS;

  Nilai({
    this.id,
    required this.siswaId,
    required this.siswaNama,
    required this.mataPelajaran,
    required this.nilaiTugas,
    required this.nilaiUTS,
    required this.nilaiUAS,
  });

  // Hitung nilai akhir: (Tugas * 30%) + (UTS * 30%) + (UAS * 40%)
  double get nilaiAkhir {
    return (nilaiTugas * 0.3) + (nilaiUTS * 0.3) + (nilaiUAS * 0.4);
  }

  // Konversi nilai akhir ke predikat
  String get predikat {
    double nilai = nilaiAkhir;
    if (nilai >= 85) return 'A';
    if (nilai >= 75) return 'B';
    if (nilai >= 65) return 'C';
    return 'D';
  }

  bool get lulus => predikat != 'D';

  String get deskripsiPredikat {
    switch (predikat) {
      case 'A':
        return 'Sangat Baik';
      case 'B':
        return 'Baik';
      case 'C':
        return 'Cukup';
      case 'D':
        return 'Kurang';
      default:
        return '-';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'siswaId': siswaId,
      'siswaNama': siswaNama,
      'mataPelajaran': mataPelajaran,
      'nilaiTugas': nilaiTugas,
      'nilaiUTS': nilaiUTS,
      'nilaiUAS': nilaiUAS,
    };
  }

  factory Nilai.fromMap(Map<String, dynamic> map) {
    return Nilai(
      id: map['id'],
      siswaId: map['siswaId'],
      siswaNama: map['siswaNama'],
      mataPelajaran: map['mataPelajaran'],
      nilaiTugas: map['nilaiTugas'].toDouble(),
      nilaiUTS: map['nilaiUTS'].toDouble(),
      nilaiUAS: map['nilaiUAS'].toDouble(),
    );
  }

  Nilai copyWith({
    int? id,
    String? siswaId,
    String? siswaNama,
    String? mataPelajaran,
    double? nilaiTugas,
    double? nilaiUTS,
    double? nilaiUAS,
  }) {
    return Nilai(
      id: id ?? this.id,
      siswaId: siswaId ?? this.siswaId,
      siswaNama: siswaNama ?? this.siswaNama,
      mataPelajaran: mataPelajaran ?? this.mataPelajaran,
      nilaiTugas: nilaiTugas ?? this.nilaiTugas,
      nilaiUTS: nilaiUTS ?? this.nilaiUTS,
      nilaiUAS: nilaiUAS ?? this.nilaiUAS,
    );
  }

  @override
  String toString() {
    return 'Nilai{siswa: $siswaNama, mapel: $mataPelajaran, NA: ${nilaiAkhir.toStringAsFixed(2)}, predikat: $predikat}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Nilai &&
        other.siswaId == siswaId &&
        other.mataPelajaran == mataPelajaran;
  }

  @override
  int get hashCode => siswaId.hashCode ^ mataPelajaran.hashCode;
}
