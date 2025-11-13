import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/nilai_provider.dart';
import '../../providers/siswa_provider.dart';
import '../../providers/guru_provider.dart';
import '../../models/nilai.dart';
import '../../models/siswa.dart';

class InputNilaiScreen extends StatefulWidget {
  const InputNilaiScreen({Key? key}) : super(key: key);

  @override
  State<InputNilaiScreen> createState() => _InputNilaiScreenState();
}

class _InputNilaiScreenState extends State<InputNilaiScreen> {
  final _formKey = GlobalKey<FormState>();

  Siswa? _selectedSiswa;
  String? _selectedMapel;

  final _tugasController = TextEditingController();
  final _utsController = TextEditingController();
  final _uasController = TextEditingController();

  double? _nilaiAkhir;
  String? _predikat;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final siswaProvider = Provider.of<SiswaProvider>(context, listen: false);
    final guruProvider = Provider.of<GuruProvider>(context, listen: false);

    await Future.wait([siswaProvider.loadSiswa(), guruProvider.loadGuru()]);
  }

  @override
  void dispose() {
    _tugasController.dispose();
    _utsController.dispose();
    _uasController.dispose();
    super.dispose();
  }

  void _calculateNilai() {
    if (_tugasController.text.isEmpty ||
        _utsController.text.isEmpty ||
        _uasController.text.isEmpty) {
      setState(() {
        _nilaiAkhir = null;
        _predikat = null;
      });
      return;
    }

    final tugas = double.tryParse(_tugasController.text) ?? 0;
    final uts = double.tryParse(_utsController.text) ?? 0;
    final uas = double.tryParse(_uasController.text) ?? 0;

    // Perhitungan: Tugas 30%, UTS 30%, UAS 40%
    final nilaiAkhir = (tugas * 0.3) + (uts * 0.3) + (uas * 0.4);

    // Predikat sesuai model: A≥85, B≥75, C≥65, D<65
    String predikat;
    if (nilaiAkhir >= 85) {
      predikat = 'A';
    } else if (nilaiAkhir >= 75) {
      predikat = 'B';
    } else if (nilaiAkhir >= 65) {
      predikat = 'C';
    } else {
      predikat = 'D';
    }

    setState(() {
      _nilaiAkhir = nilaiAkhir;
      _predikat = predikat;
    });
  }

  Future<void> _simpanNilai() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSiswa == null || _selectedMapel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih siswa dan mata pelajaran terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final nilaiProvider = Provider.of<NilaiProvider>(context, listen: false);

      final nilai = Nilai(
        siswaId: _selectedSiswa!.nis,
        siswaNama: _selectedSiswa!.nama,
        mataPelajaran: _selectedMapel!,
        nilaiTugas: double.parse(_tugasController.text),
        nilaiUTS: double.parse(_utsController.text),
        nilaiUAS: double.parse(_uasController.text),
      );

      await nilaiProvider.addOrUpdateNilai(nilai);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nilai berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        setState(() {
          _selectedSiswa = null;
          _selectedMapel = null;
          _tugasController.clear();
          _utsController.clear();
          _uasController.clear();
          _nilaiAkhir = null;
          _predikat = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan nilai: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final siswaProvider = Provider.of<SiswaProvider>(context);
    final guruProvider = Provider.of<GuruProvider>(context);
    final availableMapel = guruProvider.getAvailableMapel();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Card(
                elevation: 4,
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 40, color: Colors.green.shade700),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Input Nilai Siswa',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Masukkan nilai tugas, UTS, dan UAS',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
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

              // Pilih Siswa
              Text(
                'Pilih Siswa',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<Siswa>(
                    value: _selectedSiswa,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.person),
                      hintText: 'Pilih Siswa',
                    ),
                    items: siswaProvider.siswaList.map((siswa) {
                      return DropdownMenuItem(
                        value: siswa,
                        child: Text('${siswa.nama} (${siswa.nis})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedSiswa = value);
                    },
                    validator: (value) {
                      if (value == null) return 'Pilih siswa terlebih dahulu';
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Pilih Mata Pelajaran
              Text(
                'Pilih Mata Pelajaran',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    value: _selectedMapel,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.book),
                      hintText: 'Pilih Mata Pelajaran',
                    ),
                    items: availableMapel.map((mapel) {
                      return DropdownMenuItem(value: mapel, child: Text(mapel));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedMapel = value);
                    },
                    validator: (value) {
                      if (value == null)
                        return 'Pilih mata pelajaran terlebih dahulu';
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Input Nilai
              Text(
                'Input Nilai',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Nilai Tugas
              _buildNilaiInput(
                controller: _tugasController,
                label: 'Nilai Tugas (30%)',
                icon: Icons.assignment,
              ),
              const SizedBox(height: 12),

              // Nilai UTS
              _buildNilaiInput(
                controller: _utsController,
                label: 'Nilai UTS (30%)',
                icon: Icons.school,
              ),
              const SizedBox(height: 12),

              // Nilai UAS
              _buildNilaiInput(
                controller: _uasController,
                label: 'Nilai UAS (40%)',
                icon: Icons.edit_note,
              ),
              const SizedBox(height: 24),

              // Hasil Perhitungan
              if (_nilaiAkhir != null && _predikat != null) ...[
                Card(
                  elevation: 4,
                  color: _getPredikatColor(_predikat!).withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Hasil Perhitungan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Nilai Akhir',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _nilaiAkhir!.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: _getPredikatColor(_predikat!),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 60,
                              color: Colors.grey.shade300,
                            ),
                            Column(
                              children: [
                                Text(
                                  'Predikat',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: _getPredikatColor(_predikat!),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _predikat!,
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getDeskripsiPredikat(_predikat!),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _getPredikatColor(_predikat!),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Tombol Simpan
              ElevatedButton(
                onPressed: _isLoading ? null : _simpanNilai,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'SIMPAN NILAI',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Info Perhitungan
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Perhitungan Nilai Akhir',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tugas: 30% • UTS: 30% • UAS: 40%',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'A: ≥85 • B: ≥75 • C: ≥65 • D: <65',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNilaiInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Card(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Nilai tidak boleh kosong';
          }
          final nilai = double.tryParse(value);
          if (nilai == null) {
            return 'Nilai harus berupa angka';
          }
          if (nilai < 0 || nilai > 100) {
            return 'Nilai harus antara 0-100';
          }
          return null;
        },
        onChanged: (value) => _calculateNilai(),
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

  String _getDeskripsiPredikat(String predikat) {
    switch (predikat) {
      case 'A':
        return 'Sangat Baik';
      case 'B':
        return 'Baik';
      case 'C':
        return 'Cukup';
      case 'D':
        return 'Kurang';
      default:
        return '-';
    }
  }
}
