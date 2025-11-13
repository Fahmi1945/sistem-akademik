import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pengumuman_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/pengumuman.dart';

class KelolaPengumumanScreen extends StatefulWidget {
  const KelolaPengumumanScreen({Key? key}) : super(key: key);

  @override
  State<KelolaPengumumanScreen> createState() => _KelolaPengumumanScreenState();
}

class _KelolaPengumumanScreenState extends State<KelolaPengumumanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PengumumanProvider>(context, listen: false).loadPengumuman();
    });
  }

  void _showFormDialog({Pengumuman? pengumuman}) {
    final isEdit = pengumuman != null;
    final judulController = TextEditingController(text: pengumuman?.judul);
    final isiController = TextEditingController(text: pengumuman?.isi);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Pengumuman' : 'Buat Pengumuman'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: judulController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Pengumuman',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: isiController,
                  decoration: const InputDecoration(
                    labelText: 'Isi Pengumuman',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Isi tidak boleh kosong';
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
                  final provider = Provider.of<PengumumanProvider>(
                    context,
                    listen: false,
                  );
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );

                  final newPengumuman = Pengumuman(
                    id: pengumuman?.id,
                    judul: judulController.text,
                    isi: isiController.text,
                    tanggal: pengumuman?.tanggal ?? DateTime.now(),
                    pembuat: authProvider.currentUser?.nama ?? 'Admin',
                  );

                  if (isEdit) {
                    await provider.updatePengumuman(newPengumuman);
                  } else {
                    await provider.addPengumuman(newPengumuman);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit
                              ? 'Pengumuman berhasil diupdate'
                              : 'Pengumuman berhasil dibuat',
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
            child: Text(isEdit ? 'Update' : 'Buat'),
          ),
        ],
      ),
    );
  }

  void _deletePengumuman(Pengumuman pengumuman) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengumuman'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${pengumuman.judul}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Provider.of<PengumumanProvider>(
                  context,
                  listen: false,
                ).deletePengumuman(pengumuman.id!);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengumuman berhasil dihapus'),
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

  void _showDetailDialog(Pengumuman pengumuman) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pengumuman.judul),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    pengumuman.tanggalFormatted,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    pengumuman.pembuat,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(pengumuman.isi),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pengumumanProvider = Provider.of<PengumumanProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengumuman'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: pengumumanProvider.isLoading
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
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: pengumuman.isBaru
                            ? Colors.purple.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.campaign,
                        color: pengumuman.isBaru
                            ? Colors.purple.shade700
                            : Colors.grey.shade600,
                      ),
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
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'BARU',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      '${pengumuman.tanggalSingkat} • ${pengumuman.pembuat}\n${pengumuman.isi.length > 50 ? '${pengumuman.isi.substring(0, 50)}...' : pengumuman.isi}',
                    ),
                    isThreeLine: true,
                    onTap: () => _showDetailDialog(pengumuman),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'detail',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 20),
                              SizedBox(width: 8),
                              Text('Detail'),
                            ],
                          ),
                        ),
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
                              Icon(Icons.delete, size: 20, color: Colors.red),
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
                        if (value == 'detail') {
                          _showDetailDialog(pengumuman);
                        } else if (value == 'edit') {
                          _showFormDialog(pengumuman: pengumuman);
                        } else if (value == 'delete') {
                          _deletePengumuman(pengumuman);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: Colors.purple.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
