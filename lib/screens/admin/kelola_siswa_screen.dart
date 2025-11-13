// ========================================
// FILE: screens/admin/kelola_siswa_screen.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/siswa_provider.dart';
import '../../models/siswa.dart';

class KelolaSiswaScreen extends StatefulWidget {
  const KelolaSiswaScreen({Key? key}) : super(key: key);

  @override
  State<KelolaSiswaScreen> createState() => _KelolaSiswaScreenState();
}

class _KelolaSiswaScreenState extends State<KelolaSiswaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SiswaProvider>(context, listen: false).loadSiswa();
    });
  }

  void _showFormDialog({Siswa? siswa}) {
    final isEdit = siswa != null;
    final nisController = TextEditingController(text: siswa?.nis);
    final namaController = TextEditingController(text: siswa?.nama);
    final kelasController = TextEditingController(text: siswa?.kelas);
    final jurusanController = TextEditingController(text: siswa?.jurusan);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Siswa' : 'Tambah Siswa'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nisController,
                  decoration: const InputDecoration(
                    labelText: 'NIS',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !isEdit,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NIS tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: kelasController,
                  decoration: const InputDecoration(
                    labelText: 'Kelas (contoh: XII IPA 1)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kelas tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: jurusanController,
                  decoration: const InputDecoration(
                    labelText: 'Jurusan (IPA/IPS)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jurusan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final provider = Provider.of<SiswaProvider>(
                    context,
                    listen: false,
                  );
                  final newSiswa = Siswa(
                    id: siswa?.id,
                    nis: nisController.text,
                    nama: namaController.text,
                    kelas: kelasController.text,
                    jurusan: jurusanController.text,
                  );

                  if (isEdit) {
                    await provider.updateSiswa(newSiswa);
                  } else {
                    await provider.addSiswa(newSiswa);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit
                              ? 'Siswa berhasil diupdate'
                              : 'Siswa berhasil ditambahkan',
                        ),
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
                }
              }
            },
            child: Text(isEdit ? 'Update' : 'Tambah'),
          ),
        ],
      ),
    );
  }

  void _deleteSiswa(Siswa siswa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Siswa'),
        content: Text('Apakah Anda yakin ingin menghapus ${siswa.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Provider.of<SiswaProvider>(
                  context,
                  listen: false,
                ).deleteSiswa(siswa.id!);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Siswa berhasil dihapus'),
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
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final siswaProvider = Provider.of<SiswaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Data Siswa'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari siswa...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => siswaProvider.setSearchQuery(value),
            ),
          ),
          Expanded(
            child: siswaProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : siswaProvider.siswaList.isEmpty
                ? const Center(child: Text('Tidak ada data siswa'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: siswaProvider.siswaList.length,
                    itemBuilder: (context, index) {
                      final siswa = siswaProvider.siswaList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              siswa.nama[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            siswa.nama,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'NIS: ${siswa.nis}\n${siswa.kelas} - ${siswa.jurusan}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showFormDialog(siswa: siswa);
                              } else if (value == 'delete') {
                                _deleteSiswa(siswa);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// Sisanya akan dilanjutkan di response berikutnya karena sudah panjang
// - kelola_guru_screen.dart
// - kelola_jadwal_screen.dart  
// - kelola_pengumuman_screen.dart