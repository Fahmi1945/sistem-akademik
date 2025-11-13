//  ========================================
// FILE: models/siswa.dart
// ========================================

class Siswa {
  final int? id;
  final String nis;
  final String nama;
  final String kelas;
  final String jurusan;

  Siswa({
    this.id,
    required this.nis,
    required this.nama,
    required this.kelas,
    required this.jurusan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nis': nis,
      'nama': nama,
      'kelas': kelas,
      'jurusan': jurusan,
    };
  }

  factory Siswa.fromMap(Map<String, dynamic> map) {
    return Siswa(
      id: map['id'],
      nis: map['nis'],
      nama: map['nama'],
      kelas: map['kelas'],
      jurusan: map['jurusan'],
    );
  }

  Siswa copyWith({
    int? id,
    String? nis,
    String? nama,
    String? kelas,
    String? jurusan,
  }) {
    return Siswa(
      id: id ?? this.id,
      nis: nis ?? this.nis,
      nama: nama ?? this.nama,
      kelas: kelas ?? this.kelas,
      jurusan: jurusan ?? this.jurusan,
    );
  }

  @override
  String toString() {
    return 'Siswa{id: $id, nis: $nis, nama: $nama, kelas: $kelas, jurusan: $jurusan}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Siswa && other.nis == nis;
  }

  @override
  int get hashCode => nis.hashCode;
}
