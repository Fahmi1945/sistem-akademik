// ========================================
// FILE: screens/admin/kelola_users_screen.dart (SUPER ADMIN RESTRICTION)
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/siswa_provider.dart';
import '../../providers/guru_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';

class KelolaUsersScreen extends StatefulWidget {
  const KelolaUsersScreen({Key? key}) : super(key: key);

  @override
  State<KelolaUsersScreen> createState() => _KelolaUsersScreenState();
}

class _KelolaUsersScreenState extends State<KelolaUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUsers();
      Provider.of<SiswaProvider>(context, listen: false).loadSiswa();
      Provider.of<GuruProvider>(context, listen: false).loadGuru();
    });
  }

  // Cek apakah user yang login adalah Super Admin
  bool _isSuperAdmin(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.currentUser?.id == 1;
  }

  void _showFormDialog({User? user}) {
    final isEdit = user != null;
    final isSuperAdmin = user?.id == 1; // ID 1 = Super Admin
    final isLoggedInSuperAdmin = _isSuperAdmin(context);

    final usernameController = TextEditingController(text: user?.username);
    final passwordController = TextEditingController(text: user?.password);
    final namaController = TextEditingController(text: user?.nama);
    String selectedRole = user?.role ?? 'siswa';
    String? selectedRefId = user?.refId;
    bool obscurePassword = true;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final siswaProvider = Provider.of<SiswaProvider>(context);
          final guruProvider = Provider.of<GuruProvider>(context);

          List<DropdownMenuItem<String>> refIdItems = [];
          if (selectedRole == 'siswa') {
            refIdItems = siswaProvider.siswaList
                .map(
                  (s) => DropdownMenuItem(
                    value: s.nis,
                    child: Text('${s.nis} - ${s.nama}'),
                  ),
                )
                .toList();
          } else if (selectedRole == 'guru') {
            refIdItems = guruProvider.guruList
                .map(
                  (g) => DropdownMenuItem(
                    value: g.nip,
                    child: Text('${g.nip} - ${g.nama}'),
                  ),
                )
                .toList();
          }

          // Role items: Admin biasa tidak bisa pilih 'admin'
          List<DropdownMenuItem<String>> roleItems = [
            const DropdownMenuItem(value: 'guru', child: Text('Guru')),
            const DropdownMenuItem(value: 'siswa', child: Text('Siswa')),
          ];

          // Hanya Super Admin yang bisa pilih role 'admin'
          if (isLoggedInSuperAdmin) {
            roleItems.insert(
              0,
              const DropdownMenuItem(value: 'admin', child: Text('Admin')),
            );
          }

          return AlertDialog(
            title: Row(
              children: [
                Text(isEdit ? 'Edit User' : 'Tambah User'),
                if (isSuperAdmin) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.shield, color: Colors.red, size: 20),
                ],
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Info banner untuk Super Admin
                      if (isSuperAdmin)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.red.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Super Admin - Role tidak bisa diubah',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Info untuk admin biasa
                      if (!isLoggedInSuperAdmin && !isEdit)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Anda hanya bisa membuat user Guru dan Siswa. Hanya Super Admin yang bisa menambah Admin baru.',
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Info untuk user baru
                      if (!isEdit)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Pastikan data Siswa/Guru sudah ada sebelum membuat akun User',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        enabled: !isEdit,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username tidak boleh kosong';
                          }
                          if (value.length < 4) {
                            return 'Username minimal 4 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.admin_panel_settings),
                        ),
                        items: roleItems,
                        onChanged: isSuperAdmin
                            ? null // Disable untuk Super Admin
                            : (value) {
                                setDialogState(() {
                                  selectedRole = value!;
                                  selectedRefId = null;
                                });
                              },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      if (selectedRole != 'admin')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              value: selectedRefId,
                              decoration: InputDecoration(
                                labelText: selectedRole == 'siswa'
                                    ? 'Pilih Siswa (NIS)'
                                    : 'Pilih Guru (NIP)',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.link),
                              ),
                              items: refIdItems,
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedRefId = value;
                                });
                              },
                              validator: (value) {
                                if (selectedRole != 'admin' &&
                                    (value == null || value.isEmpty)) {
                                  return 'Harus memilih ${selectedRole == 'siswa' ? 'siswa' : 'guru'}';
                                }
                                return null;
                              },
                            ),
                            if (refIdItems.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '⚠️ Belum ada data ${selectedRole == 'siswa' ? 'siswa' : 'guru'}. Tambahkan dulu!',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
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
                      final provider = Provider.of<UserProvider>(
                        context,
                        listen: false,
                      );
                      final newUser = User(
                        id: user?.id,
                        username: usernameController.text,
                        password: passwordController.text,
                        role: selectedRole,
                        nama: namaController.text,
                        refId: selectedRole == 'admin' ? null : selectedRefId,
                      );

                      if (isEdit) {
                        await provider.updateUser(newUser);
                      } else {
                        await provider.addUser(newUser);
                      }

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEdit
                                  ? 'User berhasil diupdate'
                                  : 'User berhasil ditambahkan',
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
          );
        },
      ),
    );
  }

  void _deleteUser(User user) {
    // Proteksi Super Admin
    if (user.id == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Super Admin tidak bisa dihapus!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Admin biasa tidak bisa hapus user dengan role 'admin'
    if (!_isSuperAdmin(context) && user.role == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Hanya Super Admin yang bisa menghapus Admin!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text(
          'Apakah Anda yakin ingin menghapus user ${user.username}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Provider.of<UserProvider>(
                  context,
                  listen: false,
                ).deleteUser(user.id!);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User berhasil dihapus'),
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

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'guru':
        return Colors.green;
      case 'siswa':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'guru':
        return Icons.school;
      case 'siswa':
        return Icons.person;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedInSuperAdmin = _isSuperAdmin(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Users'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari user...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => userProvider.setSearchQuery(value),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isLoggedInSuperAdmin
                              ? 'Alur: Tambah Siswa/Guru dulu → Baru buat akun User'
                              : 'Anda hanya bisa kelola User Guru & Siswa',
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: userProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : userProvider.userList.isEmpty
                ? const Center(child: Text('Tidak ada data user'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: userProvider.userList.length,
                    itemBuilder: (context, index) {
                      final user = userProvider.userList[index];
                      final roleColor = _getRoleColor(user.role);
                      final roleIcon = _getRoleIcon(user.role);
                      final isSuperAdmin = user.id == 1;

                      // Admin biasa tidak bisa edit/hapus user admin
                      final canEdit =
                          isLoggedInSuperAdmin || user.role != 'admin';
                      final canDelete = isLoggedInSuperAdmin && !isSuperAdmin;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: roleColor.withOpacity(0.2),
                                child: Icon(roleIcon, color: roleColor),
                              ),
                              if (isSuperAdmin)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.shield,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isSuperAdmin)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'SUPER',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Username: ${user.username}'),
                              Text('Password: ${user.password}'),
                              if (user.refId != null)
                                Text(
                                  'Ref ID: ${user.refId}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: roleColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user.role.toUpperCase(),
                                  style: TextStyle(
                                    color: roleColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (canEdit || canDelete)
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    if (canEdit)
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
                                    if (canDelete)
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
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showFormDialog(user: user);
                                    } else if (value == 'delete') {
                                      _deleteUser(user);
                                    }
                                  },
                                ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        backgroundColor: Colors.deepPurple.shade700,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah User', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}