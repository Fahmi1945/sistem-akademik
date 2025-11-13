// ========================================
// FILE: screens/admin/kelola_jadwal_screen.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/jadwal_provider.dart';
import '../../providers/guru_provider.dart';
import '../../models/jadwal.dart';
import '../../models/guru.dart';

class KelolaJadwalScreen extends StatefulWidget {
  const KelolaJadwalScreen({Key? key}) : super(key: key);

  @override
  State<KelolaJadwalScreen> createState() => _KelolaJadwalScreenState();
}

class _KelolaJadwalScreenState extends State<KelolaJadwalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JadwalProvider>(context, listen: false).loadJadwal();
      Provider.of<GuruProvider>(context, listen: false).loadGuru();
    });
  }

  void _showFormDialog({Jadwal? jadwal}) {
    final isEdit = jadwal != null;
    String selectedHari = jadwal?.hari ?? 'Senin';
    String selectedKelas = jadwal?.kelas ?? 'XII IPA 1';
    Guru? selectedGuru;

    final jamMulaiController = TextEditingController(text: jadwal?.jamMulai);
    final jamSelesaiController = TextEditingController(
      text: jadwal?.jamSelesai,
    );
    final mapelController = TextEditingController(text: jadwal?.mataPelajaran);
    final formKey = GlobalKey<FormState>();

    final hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final kelasList = [
      'X IPA 1',
      'X IPA 2',
      'X IPS 1',
      'X IPS 2',
      'XI IPA 1',
      'XI IPA 2',
      'XI IPS 1',
      'XI IPS 2',
      'XII IPA 1',
      'XII IPA 2',
      'XII IPS 1',
      'XII IPS 2',
    ];

    showDialog(
      context: context,
      builder: (context) {
        final guruProvider = Provider.of<GuruProvider>(context);

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Jadwal' : 'Tambah Jadwal'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedHari,
                        decoration: const InputDecoration(
                          labelText: 'Hari',
                          border: OutlineInputBorder(),
                        ),
                        items: hariList.map((hari) {
                          return DropdownMenuItem(
                            value: hari,
                            child: Text(hari),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedHari = value!);
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: jamMulaiController,
                              decoration: const InputDecoration(
                                labelText: 'Jam Mulai',
                                hintText: '07:00',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Wajib diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: jamSelesaiController,
                              decoration: const InputDecoration(
                                labelText: 'Jam Selesai',
                                hintText: '08:30',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Wajib diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
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
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedKelas,
                        decoration: const InputDecoration(
                          labelText: 'Kelas',
                          border: OutlineInputBorder(),
                        ),
                        items: kelasList.map((kelas) {
                          return DropdownMenuItem(
                            value: kelas,
                            child: Text(kelas),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedKelas = value!);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Guru>(
                        value: selectedGuru,
                        decoration: const InputDecoration(
                          labelText: 'Guru Pengampu',
                          border: OutlineInputBorder(),
                        ),
                        items: guruProvider.guruList.map((guru) {
                          return DropdownMenuItem(
                            value: guru,
                            child: Text('${guru.nama} (${guru.mataPelajaran})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedGuru = value);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Pilih guru pengampu';
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
                        final provider = Provider.of<JadwalProvider>(
                          context,
                          listen: false,
                        );
                        final newJadwal = Jadwal(
                          id: jadwal?.id,
                          hari: selectedHari,
                          jamMulai: jamMulaiController.text,
                          jamSelesai: jamSelesaiController.text,
                          mataPelajaran: mapelController.text,
                          kelas: selectedKelas,
                          guruNip: selectedGuru!.nip,
                          guruNama: selectedGuru!.nama,
                        );

                        if (isEdit) {
                          await provider.updateJadwal(newJadwal);
                        } else {
                          await provider.addJadwal(newJadwal);
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEdit
                                    ? 'Jadwal berhasil diupdate'
                                    : 'Jadwal berhasil ditambahkan',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
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
            );
          },
        );
      },
    );
  }

  void _deleteJadwal(Jadwal jadwal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: Text(
          'Hapus jadwal ${jadwal.mataPelajaran} pada ${jadwal.hari}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Provider.of<JadwalProvider>(
                  context,
                  listen: false,
                ).deleteJadwal(jadwal.id!);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Jadwal berhasil dihapus'),
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
    final jadwalProvider = Provider.of<JadwalProvider>(context);
    final jadwalGrouped = jadwalProvider.getJadwalGroupedByHari();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Jadwal Pelajaran'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: jadwalProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : jadwalProvider.allJadwal.isEmpty
          ? const Center(child: Text('Tidak ada jadwal'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jadwalGrouped.length,
              itemBuilder: (context, index) {
                final hari = jadwalGrouped.keys.elementAt(index);
                final jadwalHari = jadwalGrouped[hari]!;

                if (jadwalHari.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        hari,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...jadwalHari.map((jadwal) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: Icon(
                              Icons.schedule,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          title: Text(
                            jadwal.mataPelajaran,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${jadwal.jamLengkap}\n${jadwal.kelas} - ${jadwal.guruNama}',
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
                                _showFormDialog(jadwal: jadwal);
                              } else if (value == 'delete') {
                                _deleteJadwal(jadwal);
                              }
                            },
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: Colors.orange.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
