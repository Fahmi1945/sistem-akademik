// ========================================
// FILE: screens/siswa/siswa_dashboard.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nilai_provider.dart';
import '../../providers/jadwal_provider.dart';
import '../../providers/pengumuman_provider.dart';
import '../login_screen.dart';
import 'jadwal_screen.dart';
import 'rapor_screen.dart';

class SiswaDashboard extends StatefulWidget {
  const SiswaDashboard({Key? key}) : super(key: key);

  @override
  State<SiswaDashboard> createState() => _SiswaDashboardState();
}

class _SiswaDashboardState extends State<SiswaDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final nilaiProvider = Provider.of<NilaiProvider>(context, listen: false);
    final jadwalProvider = Provider.of<JadwalProvider>(context, listen: false);
    final pengumumanProvider = Provider.of<PengumumanProvider>(
      context,
      listen: false,
    );

    await Future.wait([
      nilaiProvider.loadNilai(),
      jadwalProvider.loadJadwal(),
      pengumumanProvider.loadPengumuman(),
    ]);
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _DashboardHome(),
      const JadwalScreen(),
      const RaporScreen(),
      const _PengumumanPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Siswa'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blue.shade700,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Rapor'),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'Pengumuman',
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final nilaiProvider = Provider.of<NilaiProvider>(context);
    final pengumumanProvider = Provider.of<PengumumanProvider>(context);

    final siswaId = authProvider.currentUser?.refId ?? '';
    final nilaiBySiswa = nilaiProvider.allNilai
        .where((n) => n.siswaId == siswaId)
        .toList();
    final statistik = nilaiProvider.getStatistikSiswa(siswaId);

    return RefreshIndicator(
      onRefresh: () async {
        await nilaiProvider.loadNilai();
        await pengumumanProvider.loadPengumuman();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang,',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            authProvider.currentUser?.nama ?? 'Siswa',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'NIS: ${authProvider.currentUser?.refId ?? '-'}',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Academic Statistics
            Text(
              'Statistik Akademik',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (statistik['totalMapel'] > 0) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Rata-rata',
                      statistik['rataRata'].toStringAsFixed(1),
                      Icons.star,
                      Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Mapel',
                      statistik['totalMapel'].toString(),
                      Icons.book,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Distribusi Predikat',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPredikatCount(
                            'A',
                            statistik['jumlahA'],
                            Colors.green,
                          ),
                          _buildPredikatCount(
                            'B',
                            statistik['jumlahB'],
                            Colors.blue,
                          ),
                          _buildPredikatCount(
                            'C',
                            statistik['jumlahC'],
                            Colors.orange,
                          ),
                          _buildPredikatCount(
                            'D',
                            statistik['jumlahD'],
                            Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('Belum ada nilai yang diinput')),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Quick Menu
            Text(
              'Menu Cepat',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickMenuCard(
                    context,
                    'Jadwal\nPelajaran',
                    Icons.calendar_month,
                    Colors.orange,
                    () {
                      final scaffold = context
                          .findAncestorStateOfType<_SiswaDashboardState>();
                      scaffold?.setState(() {
                        scaffold._selectedIndex = 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickMenuCard(
                    context,
                    'Rapor\nNilai',
                    Icons.assessment,
                    Colors.purple,
                    () {
                      final scaffold = context
                          .findAncestorStateOfType<_SiswaDashboardState>();
                      scaffold?.setState(() {
                        scaffold._selectedIndex = 2;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Pengumuman
            if (pengumumanProvider.pengumumanList.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pengumuman Terbaru',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final scaffold = context
                          .findAncestorStateOfType<_SiswaDashboardState>();
                      scaffold?.setState(() {
                        scaffold._selectedIndex = 3;
                      });
                    },
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...pengumumanProvider.pengumumanList.take(3).map((pengumuman) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      Icons.campaign,
                      color: pengumuman.isBaru ? Colors.orange : Colors.grey,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            pengumuman.judul,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (pengumuman.isBaru)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'BARU',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      pengumuman.tanggalSingkat,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredikatCount(String predikat, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              predikat,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildQuickMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PengumumanPage extends StatelessWidget {
  const _PengumumanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pengumumanProvider = Provider.of<PengumumanProvider>(context);

    return RefreshIndicator(
      onRefresh: () => pengumumanProvider.loadPengumuman(),
      child: pengumumanProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : pengumumanProvider.pengumumanList.isEmpty
          ? const Center(child: Text('Belum ada pengumuman'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pengumumanProvider.pengumumanList.length,
              itemBuilder: (context, index) {
                final pengumuman = pengumumanProvider.pengumumanList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: Icon(
                      Icons.campaign,
                      color: pengumuman.isBaru ? Colors.orange : Colors.grey,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            pengumuman.judul,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (pengumuman.isBaru)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'BARU',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      '${pengumuman.tanggalSingkat} • ${pengumuman.pembuat}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(pengumuman.isi),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
