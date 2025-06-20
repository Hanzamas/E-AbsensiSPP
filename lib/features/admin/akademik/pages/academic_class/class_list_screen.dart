import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/class_model.dart';
import '../../provider/class_provider.dart';
import 'edit_class_screen.dart';
import '../../../users/widgets/filter_and_sort_widget.dart';

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
        Provider.of<ClassProvider>(context, listen: false).loadClasses());
  }
  Future<void> _navigateToEditScreen(ClassModel classData) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditClassScreen(classData: classData),
      ),
    );

    if (result == true && mounted) {
      // Provider akan handle update list
    }
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
              child: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Hapus Kelas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus kelas ${classData.namaKelas}?',
          style: const TextStyle(color: Color(0xFF4A5568), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF718096))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = Provider.of<ClassProvider>(context, listen: false);
              final success = await provider.deleteClass(classData.id);
              if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kelas berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${provider.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
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
              child: const Icon(Icons.class_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Daftar Kelas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          FilterAndSortWidget(
            onApplyFilter: (query, order) {
              Provider.of<ClassProvider>(context, listen: false).applyFilters(query, order);
            },
            onResetFilter: () {
              Provider.of<ClassProvider>(context, listen: false).resetFilters();
            },
          ),
          Expanded(
            child: Consumer<ClassProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.isMasterListEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                    ),
                  );
                }

                if (provider.error != null && provider.isMasterListEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 64, color: Color(0xFFE53E3E)),
                        const SizedBox(height: 16),
                        Text(provider.error!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF4A5568), fontSize: 14)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => provider.loadClasses(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        Icon(provider.isFilterActive ? Icons.filter_alt_off_rounded : Icons.class_rounded, size: 64, color: const Color(0xFFA0AEC0)),
                        const SizedBox(height: 16),
                        Text(
                          provider.isFilterActive ? 'Tidak ada kelas yang cocok' : 'Belum ada data kelas',
                          style: const TextStyle(color: Color(0xFF4A5568), fontSize: 16)
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: provider.loadClasses,
                  child: ListView.builder(
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
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2196F3).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.class_rounded, color: Color(0xFF2196F3)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      classData.namaKelas,
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748), fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 12.0,
                                      runSpacing: 4.0,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.people_rounded, size: 14, color: Color(0xFF718096)),
                                            const SizedBox(width: 4),
                                            Text('Kapasitas: ${classData.kapasitas}', style: const TextStyle(color: Color(0xFF718096), fontSize: 12)),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF718096)),
                                            const SizedBox(width: 4),
                                            Text('T.A: ${classData.tahunAjaran}', style: const TextStyle(color: Color(0xFF718096), fontSize: 12)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [                          IconButton(
                                    icon: const Icon(Icons.edit_rounded, color: Color(0xFF2196F3)),
                                    onPressed: () => _navigateToEditScreen(classData),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_rounded, color: Color(0xFFE53E3E)),
                                    onPressed: () => _showDeleteConfirmation(classData),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}