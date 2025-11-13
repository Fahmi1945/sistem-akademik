// ========================================
// FILE: models/user.dart
// ========================================

class User {
  final int? id;
  final String username;
  final String password;
  final String role; // 'admin', 'guru', 'siswa'
  final String nama;
  final String? refId; // NIS untuk siswa, NIP untuk guru

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.nama,
    this.refId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
      'nama': nama,
      'refId': refId,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      role: map['role'],
      nama: map['nama'],
      refId: map['refId'],
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? password,
    String? role,
    String? nama,
    String? refId,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      nama: nama ?? this.nama,
      refId: refId ?? this.refId,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, role: $role, nama: $nama}';
  }
}
