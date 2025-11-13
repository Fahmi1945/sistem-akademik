// ========================================
// FILE: screens/siswa/jadwal_screen.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/jadwal_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/siswa_provider.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({Key? key}) : super(key: key);

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final siswaProvider = Provider.of<SiswaProvider>(context, listen: false);
      final jadwalProvider = Provider.of<JadwalProvider>(
        context,
        listen: false,
      );

      // Get siswa data to get kelas
      final siswa = await siswaProvider.getSiswaByNis(
        authProvider.currentUser?.refId ?? '',
      );

      if (siswa != null) {
        await jadwalProvider.loadJadwalByKelas(siswa.kelas);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final jadwalProvider = Provider.of<JadwalProvider>(context);
    final jadwalGrouped = jadwalProvider.getJadwalGroupedByHari();

    return RefreshIndicator(
      onRefresh: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final siswaProvider = Provider.of<SiswaProvider>(
          context,
          listen: false,
        );
        final siswa = await siswaProvider.getSiswaByNis(
          authProvider.currentUser?.refId ?? '',
        );
        if (siswa != null) {
          await jadwalProvider.loadJadwalByKelas(siswa.kelas);
        }
      },
      child: jadwalProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : jadwalProvider.jadwalList.isEmpty
          ? const Center(child: Text('Tidak ada jadwal'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jadwalGrouped.length,
              itemBuilder: (context, index) {
                final hari = jadwalGrouped.keys.elementAt(index);
                final jadwalHari = jadwalGrouped[hari]!;

                if (jadwalHari.isEmpty) return const SizedBox.shrink();

                // Check if today
                final now = DateTime.now();
                final isToday = _isToday(hari, now);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            hari,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isToday ? Colors.blue.shade700 : null,
                            ),
                          ),
                          if (isToday) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade700,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'HARI INI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    ...jadwalHari.map((jadwal) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isToday ? Colors.blue.shade50 : null,
                        child: ListTile(
                          leading: Container(
                            width: 60,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  jadwal.jamMulai,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const Text('—', style: TextStyle(fontSize: 10)),
                                Text(
                                  jadwal.jamSelesai,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          title: Text(
                            jadwal.mataPelajaran,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            jadwal.guruNama,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: Icon(
                            Icons.book,
                            color: Colors.blue.shade300,
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
    );
  }

  bool _isToday(String hari, DateTime now) {
    const hariMap = {
      1: 'Senin',
      2: 'Selasa',
      3: 'Rabu',
      4: 'Kamis',
      5: 'Jumat',
      6: 'Sabtu',
      7: 'Minggu',
    };

    return hariMap[now.weekday] == hari;
  }
}

// File rapor_screen.dart akan dibuat di artifact terpisah karena memerlukan PDF generator
