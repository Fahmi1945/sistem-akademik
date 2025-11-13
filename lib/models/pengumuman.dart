// ========================================
// FILE: models/pengumuman.dart
// ========================================
class Pengumuman {
  final int? id;
  final String judul;
  final String isi;
  final DateTime tanggal;
  final String pembuat;

  Pengumuman({
    this.id,
    required this.judul,
    required this.isi,
    required this.tanggal,
    required this.pembuat,
  });

  String get tanggalFormatted {
    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final day = days[tanggal.weekday % 7];
    final month = months[tanggal.month - 1];

    return '$day, ${tanggal.day} $month ${tanggal.year}';
  }

  String get tanggalSingkat {
    return '${tanggal.day.toString().padLeft(2, '0')}/${tanggal.month.toString().padLeft(2, '0')}/${tanggal.year}';
  }

  bool get isBaru {
    final sekarang = DateTime.now();
    final selisih = sekarang.difference(tanggal).inDays;
    return selisih <= 7;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'tanggal': tanggal.toIso8601String(),
      'pembuat': pembuat,
    };
  }

  factory Pengumuman.fromMap(Map<String, dynamic> map) {
    return Pengumuman(
      id: map['id'],
      judul: map['judul'],
      isi: map['isi'],
      tanggal: DateTime.parse(map['tanggal']),
      pembuat: map['pembuat'],
    );
  }

  Pengumuman copyWith({
    int? id,
    String? judul,
    String? isi,
    DateTime? tanggal,
    String? pembuat,
  }) {
    return Pengumuman(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      tanggal: tanggal ?? this.tanggal,
      pembuat: pembuat ?? this.pembuat,
    );
  }

  @override
  String toString() {
    return 'Pengumuman{id: $id, judul: $judul, tanggal: $tanggalSingkat, pembuat: $pembuat}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pengumuman && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
