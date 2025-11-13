// ========================================
// FILE: screens/admin/kelola_guru_screen.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/guru_provider.dart';
import '../../models/guru.dart';

class KelolaGuruScreen extends StatefulWidget {
  const KelolaGuruScreen({Key? key}) : super(key: key);

  @override
  State<KelolaGuruScreen> createState() => _KelolaGuruScreenState();
}

class _KelolaGuruScreenState extends State<KelolaGuruScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GuruProvider>(context, listen: false).loadGuru();
    });
  }

  void _showFormDialog({Guru? guru}) {
    final isEdit = guru != null;
    final nipController = TextEditingController(text: guru?.nip);
    final namaController = TextEditingController(text: guru?.nama);
    final mapelController = TextEditingController(text: guru?.mataPelajaran);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Guru' : 'Tambah Guru'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nipController,
                  decoration: const InputDecoration(
                    labelText: 'NIP',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !isEdit,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NIP tidak boleh kosong';
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
                  controller: mapelController,
                  decoration: const InputDecoration(
                    labelText: 'Mata Pelajaran',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mata pelajaran tidak boleh kosong';
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
                  final provider = Provider.of<GuruProvider>(
                    context,
                    listen: false,
                  );
                  final newGuru = Guru(
                    id: guru?.id,
                    nip: nipController.text,
                    nama: namaController.text,
                    mataPelajaran: mapelController.text,
                  );

                  if (isEdit) {
                    await provider.updateGuru(newGuru);
                  } else {
                    await provider.addGuru(newGuru);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit
                              ? 'Guru berhasil diupdate'
                              : 'Guru berhasil ditambahkan',
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

  void _deleteGuru(Guru guru) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Guru'),
        content: Text('Apakah Anda yakin ingin menghapus ${guru.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Provider.of<GuruProvider>(
                  context,
                  listen: false,
                ).deleteGuru(guru.id!);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Guru berhasil dihapus'),
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
    final guruProvider = Provider.of<GuruProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Data Guru'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari guru...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => guruProvider.setSearchQuery(value),
            ),
          ),
          Expanded(
            child: guruProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : guruProvider.guruList.isEmpty
                ? const Center(child: Text('Tidak ada data guru'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: guruProvider.guruList.length,
                    itemBuilder: (context, index) {
                      final guru = guruProvider.guruList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: Icon(
                              Icons.school,
                              color: Colors.green.shade700,
                            ),
                          ),
                          title: Text(
                            guru.nama,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'NIP: ${guru.nip}\n${guru.mataPelajaran}',
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
                                _showFormDialog(guru: guru);
                              } else if (value == 'delete') {
                                _deleteGuru(guru);
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
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
