//  ========================================
// FILE: models/guru.dart
// ========================================

class Guru {
  final int? id;
  final String nip;
  final String nama;
  final String mataPelajaran;

  Guru({
    this.id,
    required this.nip,
    required this.nama,
    required this.mataPelajaran,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'nip': nip, 'nama': nama, 'mataPelajaran': mataPelajaran};
  }

  factory Guru.fromMap(Map<String, dynamic> map) {
    return Guru(
      id: map['id'],
      nip: map['nip'],
      nama: map['nama'],
      mataPelajaran: map['mataPelajaran'],
    );
  }

  Guru copyWith({int? id, String? nip, String? nama, String? mataPelajaran}) {
    return Guru(
      id: id ?? this.id,
      nip: nip ?? this.nip,
      nama: nama ?? this.nama,
      mataPelajaran: mataPelajaran ?? this.mataPelajaran,
    );
  }

  @override
  String toString() {
    return 'Guru{id: $id, nip: $nip, nama: $nama, mataPelajaran: $mataPelajaran}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Guru && other.nip == nip;
  }

  @override
  int get hashCode => nip.hashCode;
}
