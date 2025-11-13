import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nilai_provider.dart';
import '../../providers/pengumuman_provider.dart';
import '../../providers/guru_provider.dart';
import '../login_screen.dart';
import 'input_nilai_screen.dart';

class GuruDashboard extends StatefulWidget {
  const GuruDashboard({Key? key}) : super(key: key);

  @override
  State<GuruDashboard> createState() => _GuruDashboardState();
}

class _GuruDashboardState extends State<GuruDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final nilaiProvider = Provider.of<NilaiProvider>(context, listen: false);
    final pengumumanProvider = Provider.of<PengumumanProvider>(
      context,
      listen: false,
    );
    final guruProvider = Provider.of<GuruProvider>(context, listen: false);

    await Future.wait([
      nilaiProvider.loadNilai(),
      pengumumanProvider.loadPengumuman(),
      guruProvider.loadGuru(),
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
      const InputNilaiScreen(),
      const _PengumumanPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Guru'),
        backgroundColor: Colors.green.shade700,
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
        selectedItemColor: Colors.green.shade700,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Input Nilai'),
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
                      backgroundColor: Colors.green.shade100,
                      child: Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.green.shade700,
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
                            authProvider.currentUser?.nama ?? 'Guru',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'NIP: ${authProvider.currentUser?.refId ?? '-'}',
                            style: TextStyle(
                              color: Colors.green.shade700,
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

            // Statistics
            Text(
              'Statistik',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Nilai Diinput',
                    nilaiProvider.allNilai.length.toString(),
                    Icons.assignment_turned_in,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Pengumuman Baru',
                    pengumumanProvider.jumlahPengumumanBaru.toString(),
                    Icons.campaign,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Menu Cepat',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.edit, color: Colors.green.shade700),
                ),
                title: const Text(
                  'Input Nilai Siswa',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Masukkan nilai tugas, UTS, dan UAS'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InputNilaiScreen()),
                  );
                },
              ),
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
                      // Switch to pengumuman tab
                      final scaffold = context
                          .findAncestorStateOfType<_GuruDashboardState>();
                      scaffold?.setState(() {
                        scaffold._selectedIndex = 2;
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
