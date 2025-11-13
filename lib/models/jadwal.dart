// ========================================
// FILE: models/jadwal.dart
// ========================================

class Jadwal {
  final int? id;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final String mataPelajaran;
  final String kelas;
  final String guruNip;
  final String guruNama;

  Jadwal({
    this.id,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.mataPelajaran,
    required this.kelas,
    required this.guruNip,
    required this.guruNama,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hari': hari,
      'jamMulai': jamMulai,
      'jamSelesai': jamSelesai,
      'mataPelajaran': mataPelajaran,
      'kelas': kelas,
      'guruNip': guruNip,
      'guruNama': guruNama,
    };
  }

  factory Jadwal.fromMap(Map<String, dynamic> map) {
    return Jadwal(
      id: map['id'],
      hari: map['hari'],
      jamMulai: map['jamMulai'],
      jamSelesai: map['jamSelesai'],
      mataPelajaran: map['mataPelajaran'],
      kelas: map['kelas'],
      guruNip: map['guruNip'],
      guruNama: map['guruNama'],
    );
  }

  Jadwal copyWith({
    int? id,
    String? hari,
    String? jamMulai,
    String? jamSelesai,
    String? mataPelajaran,
    String? kelas,
    String? guruNip,
    String? guruNama,
  }) {
    return Jadwal(
      id: id ?? this.id,
      hari: hari ?? this.hari,
      jamMulai: jamMulai ?? this.jamMulai,
      jamSelesai: jamSelesai ?? this.jamSelesai,
      mataPelajaran: mataPelajaran ?? this.mataPelajaran,
      kelas: kelas ?? this.kelas,
      guruNip: guruNip ?? this.guruNip,
      guruNama: guruNama ?? this.guruNama,
    );
  }

  String get jamLengkap => '$jamMulai - $jamSelesai';

  int get hariIndex {
    const hariMap = {
      'Senin': 1,
      'Selasa': 2,
      'Rabu': 3,
      'Kamis': 4,
      'Jumat': 5,
      'Sabtu': 6,
      'Minggu': 7,
    };
    return hariMap[hari] ?? 0;
  }

  @override
  String toString() {
    return 'Jadwal{id: $id, hari: $hari, jam: $jamLengkap, mapel: $mataPelajaran, kelas: $kelas, guru: $guruNama}';
  }
}
