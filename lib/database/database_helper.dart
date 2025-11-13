import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/siswa.dart';
import '../models/guru.dart';
import '../models/jadwal.dart';
import '../models/nilai.dart';
import '../models/pengumuman.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('akademik.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';

    // Tabel Users
    await db.execute('''
    CREATE TABLE users (
      id $idType,
      username $textType,
      password $textType,
      role $textType,
      nama $textType,
      refId TEXT
    )
    ''');

    // Tabel Siswa
    await db.execute('''
    CREATE TABLE siswa (
      id $idType,
      nis $textType UNIQUE,
      nama $textType,
      kelas $textType,
      jurusan $textType
    )
    ''');

    // Tabel Guru
    await db.execute('''
    CREATE TABLE guru (
      id $idType,
      nip $textType UNIQUE,
      nama $textType,
      mataPelajaran $textType
    )
    ''');

    // Tabel Jadwal
    await db.execute('''
    CREATE TABLE jadwal (
      id $idType,
      hari $textType,
      jamMulai $textType,
      jamSelesai $textType,
      mataPelajaran $textType,
      kelas $textType,
      guruNip $textType,
      guruNama $textType
    )
    ''');

    // Tabel Nilai
    await db.execute('''
    CREATE TABLE nilai (
      id $idType,
      siswaId $textType,
      siswaNama $textType,
      mataPelajaran $textType,
      nilaiTugas $realType,
      nilaiUTS $realType,
      nilaiUAS $realType,
      UNIQUE(siswaId, mataPelajaran)
    )
    ''');

    // Tabel Pengumuman
    await db.execute('''
    CREATE TABLE pengumuman (
      id $idType,
      judul $textType,
      isi $textType,
      tanggal $textType,
      pembuat $textType
    )
    ''');

    // Insert dummy data
    await _insertDummyData(db);
  }

  Future _insertDummyData(Database db) async {
    // Dummy Users
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123',
      'role': 'admin',
      'nama': 'Admin Sistem',
      'refId': null,
    });

    await db.insert('users', {
      'username': 'guru1',
      'password': 'guru123',
      'role': 'guru',
      'nama': 'Budi Santoso',
      'refId': '198501012010011001',
    });

    await db.insert('users', {
      'username': 'siswa1',
      'password': 'siswa123',
      'role': 'siswa',
      'nama': 'Ahmad Fadli',
      'refId': '2024001',
    });

    // Dummy Guru
    await db.insert('guru', {
      'nip': '198501012010011001',
      'nama': 'Budi Santoso',
      'mataPelajaran': 'Matematika',
    });

    await db.insert('guru', {
      'nip': '198602022011012001',
      'nama': 'Siti Nurhaliza',
      'mataPelajaran': 'Bahasa Indonesia',
    });

    await db.insert('guru', {
      'nip': '198703032012011001',
      'nama': 'Agus Wijaya',
      'mataPelajaran': 'Bahasa Inggris',
    });

    // Dummy Siswa
    await db.insert('siswa', {
      'nis': '2024001',
      'nama': 'Ahmad Fadli',
      'kelas': 'XII IPA 1',
      'jurusan': 'IPA',
    });

    await db.insert('siswa', {
      'nis': '2024002',
      'nama': 'Siti Aminah',
      'kelas': 'XII IPA 1',
      'jurusan': 'IPA',
    });

    await db.insert('siswa', {
      'nis': '2024003',
      'nama': 'Budi Hermawan',
      'kelas': 'XII IPS 1',
      'jurusan': 'IPS',
    });

    // Dummy Jadwal
    await db.insert('jadwal', {
      'hari': 'Senin',
      'jamMulai': '07:00',
      'jamSelesai': '08:30',
      'mataPelajaran': 'Matematika',
      'kelas': 'XII IPA 1',
      'guruNip': '198501012010011001',
      'guruNama': 'Budi Santoso',
    });

    await db.insert('jadwal', {
      'hari': 'Senin',
      'jamMulai': '08:30',
      'jamSelesai': '10:00',
      'mataPelajaran': 'Bahasa Indonesia',
      'kelas': 'XII IPA 1',
      'guruNip': '198602022011012001',
      'guruNama': 'Siti Nurhaliza',
    });

    // Dummy Nilai
    await db.insert('nilai', {
      'siswaId': '2024001',
      'siswaNama': 'Ahmad Fadli',
      'mataPelajaran': 'Matematika',
      'nilaiTugas': 85.0,
      'nilaiUTS': 80.0,
      'nilaiUAS': 88.0,
    });

    await db.insert('nilai', {
      'siswaId': '2024001',
      'siswaNama': 'Ahmad Fadli',
      'mataPelajaran': 'Bahasa Indonesia',
      'nilaiTugas': 90.0,
      'nilaiUTS': 85.0,
      'nilaiUAS': 92.0,
    });

    // Dummy Pengumuman
    await db.insert('pengumuman', {
      'judul': 'Selamat Datang di Sistem Informasi Akademik',
      'isi':
          'Selamat datang di aplikasi Sistem Informasi Akademik Sekolah XYZ. Silakan gunakan fitur-fitur yang tersedia sesuai dengan role Anda.',
      'tanggal': DateTime.now().toIso8601String(),
      'pembuat': 'Admin Sistem',
    });
  }

  // ==================== USER CRUD ====================
  Future<User?> login(String username, String password) async {
    final db = await instance.database;
    final results = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (results.isNotEmpty) {
      return User.fromMap(results.first);
    }
    return null;
  }

  Future<User> createUser(User user) async {
    final db = await instance.database;
    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  Future<List<User>> getAllUsers() async {
    final db = await instance.database;
    final results = await db.query('users', orderBy: 'id DESC');
    return results.map((map) => User.fromMap(map)).toList();
  }

  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== SISWA CRUD ====================
  Future<Siswa> createSiswa(Siswa siswa) async {
    final db = await instance.database;
    final id = await db.insert('siswa', siswa.toMap());
    return siswa.copyWith(id: id);
  }

  Future<List<Siswa>> getAllSiswa() async {
    final db = await instance.database;
    final results = await db.query('siswa', orderBy: 'nama ASC');
    return results.map((map) => Siswa.fromMap(map)).toList();
  }

  Future<Siswa?> getSiswaByNis(String nis) async {
    final db = await instance.database;
    final results = await db.query('siswa', where: 'nis = ?', whereArgs: [nis]);
    if (results.isNotEmpty) {
      return Siswa.fromMap(results.first);
    }
    return null;
  }

  Future<List<Siswa>> getSiswaByKelas(String kelas) async {
    final db = await instance.database;
    final results = await db.query(
      'siswa',
      where: 'kelas = ?',
      whereArgs: [kelas],
      orderBy: 'nama ASC',
    );
    return results.map((map) => Siswa.fromMap(map)).toList();
  }

  Future<int> updateSiswa(Siswa siswa) async {
    final db = await instance.database;
    return db.update(
      'siswa',
      siswa.toMap(),
      where: 'id = ?',
      whereArgs: [siswa.id],
    );
  }

  Future<int> deleteSiswa(int id) async {
    final db = await instance.database;
    return await db.delete('siswa', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== GURU CRUD ====================
  Future<Guru> createGuru(Guru guru) async {
    final db = await instance.database;
    final id = await db.insert('guru', guru.toMap());
    return guru.copyWith(id: id);
  }

  Future<List<Guru>> getAllGuru() async {
    final db = await instance.database;
    final results = await db.query('guru', orderBy: 'nama ASC');
    return results.map((map) => Guru.fromMap(map)).toList();
  }

  Future<Guru?> getGuruByNip(String nip) async {
    final db = await instance.database;
    final results = await db.query('guru', where: 'nip = ?', whereArgs: [nip]);
    if (results.isNotEmpty) {
      return Guru.fromMap(results.first);
    }
    return null;
  }

  Future<int> updateGuru(Guru guru) async {
    final db = await instance.database;
    return db.update(
      'guru',
      guru.toMap(),
      where: 'id = ?',
      whereArgs: [guru.id],
    );
  }

  Future<int> deleteGuru(int id) async {
    final db = await instance.database;
    return await db.delete('guru', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== JADWAL CRUD ====================
  Future<Jadwal> createJadwal(Jadwal jadwal) async {
    final db = await instance.database;
    final id = await db.insert('jadwal', jadwal.toMap());
    return jadwal.copyWith(id: id);
  }

  Future<List<Jadwal>> getAllJadwal() async {
    final db = await instance.database;
    final results = await db.query('jadwal');
    final jadwalList = results.map((map) => Jadwal.fromMap(map)).toList();

    // Sort by hari dan jam
    jadwalList.sort((a, b) {
      if (a.hariIndex != b.hariIndex) {
        return a.hariIndex.compareTo(b.hariIndex);
      }
      return a.jamMulai.compareTo(b.jamMulai);
    });

    return jadwalList;
  }

  Future<List<Jadwal>> getJadwalByKelas(String kelas) async {
    final db = await instance.database;
    final results = await db.query(
      'jadwal',
      where: 'kelas = ?',
      whereArgs: [kelas],
    );
    final jadwalList = results.map((map) => Jadwal.fromMap(map)).toList();

    jadwalList.sort((a, b) {
      if (a.hariIndex != b.hariIndex) {
        return a.hariIndex.compareTo(b.hariIndex);
      }
      return a.jamMulai.compareTo(b.jamMulai);
    });

    return jadwalList;
  }

  Future<List<Jadwal>> getJadwalByGuru(String guruNip) async {
    final db = await instance.database;
    final results = await db.query(
      'jadwal',
      where: 'guruNip = ?',
      whereArgs: [guruNip],
    );
    return results.map((map) => Jadwal.fromMap(map)).toList();
  }

  Future<int> updateJadwal(Jadwal jadwal) async {
    final db = await instance.database;
    return db.update(
      'jadwal',
      jadwal.toMap(),
      where: 'id = ?',
      whereArgs: [jadwal.id],
    );
  }

  Future<int> deleteJadwal(int id) async {
    final db = await instance.database;
    return await db.delete('jadwal', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== NILAI CRUD ====================
  Future<Nilai> createNilai(Nilai nilai) async {
    final db = await instance.database;
    final id = await db.insert(
      'nilai',
      nilai.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return nilai.copyWith(id: id);
  }

  Future<List<Nilai>> getAllNilai() async {
    final db = await instance.database;
    final results = await db.query('nilai', orderBy: 'siswaNama ASC');
    return results.map((map) => Nilai.fromMap(map)).toList();
  }

  Future<List<Nilai>> getNilaiBySiswa(String siswaId) async {
    final db = await instance.database;
    final results = await db.query(
      'nilai',
      where: 'siswaId = ?',
      whereArgs: [siswaId],
      orderBy: 'mataPelajaran ASC',
    );
    return results.map((map) => Nilai.fromMap(map)).toList();
  }

  Future<List<Nilai>> getNilaiByMapel(String mataPelajaran) async {
    final db = await instance.database;
    final results = await db.query(
      'nilai',
      where: 'mataPelajaran = ?',
      whereArgs: [mataPelajaran],
      orderBy: 'siswaNama ASC',
    );
    return results.map((map) => Nilai.fromMap(map)).toList();
  }

  Future<Nilai?> getNilaiSiswaMapel(
    String siswaId,
    String mataPelajaran,
  ) async {
    final db = await instance.database;
    final results = await db.query(
      'nilai',
      where: 'siswaId = ? AND mataPelajaran = ?',
      whereArgs: [siswaId, mataPelajaran],
    );
    if (results.isNotEmpty) {
      return Nilai.fromMap(results.first);
    }
    return null;
  }

  Future<int> updateNilai(Nilai nilai) async {
    final db = await instance.database;
    return db.update(
      'nilai',
      nilai.toMap(),
      where: 'id = ?',
      whereArgs: [nilai.id],
    );
  }

  Future<int> deleteNilai(int id) async {
    final db = await instance.database;
    return await db.delete('nilai', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== PENGUMUMAN CRUD ====================
  Future<Pengumuman> createPengumuman(Pengumuman pengumuman) async {
    final db = await instance.database;
    final id = await db.insert('pengumuman', pengumuman.toMap());
    return pengumuman.copyWith(id: id);
  }

  Future<List<Pengumuman>> getAllPengumuman() async {
    final db = await instance.database;
    final results = await db.query('pengumuman', orderBy: 'tanggal DESC');
    return results.map((map) => Pengumuman.fromMap(map)).toList();
  }

  Future<Pengumuman?> getPengumumanById(int id) async {
    final db = await instance.database;
    final results = await db.query(
      'pengumuman',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return Pengumuman.fromMap(results.first);
    }
    return null;
  }

  Future<int> updatePengumuman(Pengumuman pengumuman) async {
    final db = await instance.database;
    return db.update(
      'pengumuman',
      pengumuman.toMap(),
      where: 'id = ?',
      whereArgs: [pengumuman.id],
    );
  }

  Future<int> deletePengumuman(int id) async {
    final db = await instance.database;
    return await db.delete('pengumuman', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== UTILITY ====================
  Future<void> resetDatabase() async {
    final db = await instance.database;
    await db.delete('users');
    await db.delete('siswa');
    await db.delete('guru');
    await db.delete('jadwal');
    await db.delete('nilai');
    await db.delete('pengumuman');
    await _insertDummyData(db);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
