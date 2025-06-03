import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/class_model.dart';
import '../provider/class_provider.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({Key? key}) : super(key: key);

  @override
  _ClassListScreenState createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<ClassProvider>(context, listen: false).loadClasses()
    );
  }

  Future<void> _showEditDialog(ClassModel classData) async {
    final TextEditingController namaController = TextEditingController(text: classData.namaKelas);
    final TextEditingController kapasitasController = TextEditingController(
      text: classData.kapasitas.toString(),
    );
    final TextEditingController tahunAjaranController = TextEditingController(
      text: classData.idTahunAjaran.toString(),
    );

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Color(0xFF2196F3),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Edit Kelas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInputField(
                controller: namaController,
                label: 'Nama Kelas',
                hint: 'Contoh: X IPA 1',
                icon: Icons.class_rounded,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: kapasitasController,
                label: 'Kapasitas',
                hint: 'Contoh: 30',
                icon: Icons.people_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: tahunAjaranController,
                label: 'ID Tahun Ajaran',
                hint: 'Contoh: 10',
                icon: Icons.calendar_today_rounded,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF718096)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final updatedClass = ClassModel(
                  id: classData.id,
                  namaKelas: namaController.text,
                  kapasitas: int.parse(kapasitasController.text),
                  idTahunAjaran: int.parse(tahunAjaranController.text),
                  tahunAjaran: classData.tahunAjaran,
                );

                final provider = Provider.of<ClassProvider>(context, listen: false);
                final success = await provider.updateClass(classData.id, updatedClass);

                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kelas berhasil diperbarui'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(ClassModel classData) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Hapus Kelas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus kelas ${classData.namaKelas}?',
          style: const TextStyle(
            color: Color(0xFF4A5568),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF718096)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final provider = Provider.of<ClassProvider>(context, listen: false);
                final success = await provider.deleteClass(classData.id);
                
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kelas berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2196F3)),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      keyboardType: keyboardType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.class_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Daftar Kelas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.refresh_rounded),
        //     onPressed: () => Provider.of<ClassProvider>(context, listen: false).loadClasses(),
        //   ),
        // ],
      ),
      body: Consumer<ClassProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Color(0xFFE53E3E),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF4A5568),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadClasses(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.classes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.class_rounded,
                    size: 64,
                    color: Color(0xFFA0AEC0),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada data kelas',
                    style: TextStyle(
                      color: Color(0xFF4A5568),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.classes.length,
            padding: const EdgeInsets.all(20),
            itemBuilder: (context, index) {
              final classData = provider.classes[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Leading Icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.class_rounded,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Title and Subtitle (Expanded to take available space)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title (Class Name)
                            Text(
                              classData.namaKelas,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            // Subtitle (Capacity and Academic Year)
                            Row(
                              children: [
                                const Icon(
                                  Icons.people_rounded,
                                  size: 16,
                                  color: Color(0xFF718096),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Kapasitas: ${classData.kapasitas}',
                                  style: const TextStyle(
                                    color: Color(0xFF718096),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: Color(0xFF718096),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tahun Ajaran: ${classData.tahunAjaran}',
                                  style: const TextStyle(
                                    color: Color(0xFF718096),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Trailing Buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_rounded,
                              color: Color(0xFF2196F3),
                            ),
                            onPressed: () => _showEditDialog(classData),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_rounded,
                              color: Color(0xFFE53E3E),
                            ),
                            onPressed: () => _showDeleteConfirmation(classData),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 