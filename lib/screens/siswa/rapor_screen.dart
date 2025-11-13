// ========================================
// FILE: screens/siswa/rapor_screen.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/nilai_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/siswa_provider.dart';
import '../../utils/pdf_generator.dart';

class RaporScreen extends StatefulWidget {
  const RaporScreen({Key? key}) : super(key: key);

  @override
  State<RaporScreen> createState() => _RaporScreenState();
}

class _RaporScreenState extends State<RaporScreen> {
  bool _isGeneratingPDF = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final nilaiProvider = Provider.of<NilaiProvider>(context, listen: false);

      await nilaiProvider.loadNilaiBySiswa(
        authProvider.currentUser?.refId ?? '',
      );
    });
  }

  Future<void> _exportToPDF() async {
    setState(() => _isGeneratingPDF = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final siswaProvider = Provider.of<SiswaProvider>(context, listen: false);
      final nilaiProvider = Provider.of<NilaiProvider>(context, listen: false);

      final siswaId = authProvider.currentUser?.refId ?? '';
      final siswa = await siswaProvider.getSiswaByNis(siswaId);
      final nilaiList = nilaiProvider.allNilai
          .where((n) => n.siswaId == siswaId)
          .toList();

      if (siswa == null) {
        throw Exception('Data siswa tidak ditemukan');
      }

      final pdfGenerator = PDFGenerator();
      await pdfGenerator.generateRaporPDF(siswa, nilaiList);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF Rapor berhasil diunduh'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPDF = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final nilaiProvider = Provider.of<NilaiProvider>(context);

    final siswaId = authProvider.currentUser?.refId ?? '';
    final nilaiList = nilaiProvider.allNilai
        .where((n) => n.siswaId == siswaId)
        .toList();
    final statistik = nilaiProvider.getStatistikSiswa(siswaId);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => nilaiProvider.loadNilaiBySiswa(siswaId),
        child: nilaiProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'RAPOR SISWA',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      authProvider.currentUser?.nama ?? '-',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: _isGeneratingPDF
                                      ? null
                                      : _exportToPDF,
                                  icon: _isGeneratingPDF
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.picture_as_pdf),
                                  label: const Text('Export PDF'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade700,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Statistics Card
                    if (statistik['totalMapel'] > 0) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ringkasan Nilai',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    'Rata-rata',
                                    statistik['rataRata'].toStringAsFixed(2),
                                    Icons.stars,
                                    Colors.amber,
                                  ),
                                  _buildStatItem(
                                    'Tertinggi',
                                    statistik['nilaiTertinggi'].toStringAsFixed(
                                      2,
                                    ),
                                    Icons.arrow_upward,
                                    Colors.green,
                                  ),
                                  _buildStatItem(
                                    'Terendah',
                                    statistik['nilaiTerendah'].toStringAsFixed(
                                      2,
                                    ),
                                    Icons.arrow_downward,
                                    Colors.orange,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Table Header
                    const Text(
                      'Daftar Nilai',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Nilai Table
                    if (nilaiList.isEmpty) ...[
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text('Belum ada nilai yang diinput'),
                          ),
                        ),
                      ),
                    ] else ...[
                      Card(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('No')),
                              DataColumn(label: Text('Mata Pelajaran')),
                              DataColumn(label: Text('Tugas\n(30%)')),
                              DataColumn(label: Text('UTS\n(30%)')),
                              DataColumn(label: Text('UAS\n(40%)')),
                              DataColumn(label: Text('Nilai\nAkhir')),
                              DataColumn(label: Text('Predikat')),
                            ],
                            rows: List.generate(nilaiList.length, (index) {
                              final nilai = nilaiList[index];
                              return DataRow(
                                cells: [
                                  DataCell(Text('${index + 1}')),
                                  DataCell(Text(nilai.mataPelajaran)),
                                  DataCell(
                                    Text(nilai.nilaiTugas.toStringAsFixed(0)),
                                  ),
                                  DataCell(
                                    Text(nilai.nilaiUTS.toStringAsFixed(0)),
                                  ),
                                  DataCell(
                                    Text(nilai.nilaiUAS.toStringAsFixed(0)),
                                  ),
                                  DataCell(
                                    Text(
                                      nilai.nilaiAkhir.toStringAsFixed(2),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getPredikatColor(
                                          nilai.predikat,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        nilai.predikat,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Legend
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Keterangan Predikat:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              _buildLegendItem(
                                'A',
                                'Sangat Baik (≥ 85)',
                                Colors.green,
                              ),
                              _buildLegendItem(
                                'B',
                                'Baik (75 - 84)',
                                Colors.blue,
                              ),
                              _buildLegendItem(
                                'C',
                                'Cukup (65 - 74)',
                                Colors.orange,
                              ),
                              _buildLegendItem(
                                'D',
                                'Kurang (< 65)',
                                Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String predikat, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                predikat,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(desc, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Color _getPredikatColor(String predikat) {
    switch (predikat) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
