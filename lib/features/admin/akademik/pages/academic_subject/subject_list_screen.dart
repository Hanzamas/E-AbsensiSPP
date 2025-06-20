import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/subject_model.dart';
import '../../provider/subject_provider.dart';
import './add_subject_screen.dart';
import './edit_subject_screen.dart';
import '../../../users/widgets/filter_and_sort_widget.dart';


class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({Key? key}) : super(key: key);

  @override
  _SubjectListScreenState createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<SubjectProvider>(context, listen: false).loadSubjects());
  }

  Future<void> _navigateToEditScreen(SubjectModel subject) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSubjectScreen(subject: subject),
      ),
    );

    if (result == true && mounted) {
      // Data sudah otomatis terupdate di provider, tidak perlu panggil loadSubjects lagi
    }
  }

  Future<void> _showDeleteConfirmation(SubjectModel subject) async {
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
            const Text('Hapus Mata Pelajaran',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748))),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus mata pelajaran ${subject.nama}?',
          style: const TextStyle(color: Color(0xFF4A5568), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Batal', style: TextStyle(color: Color(0xFF718096))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final provider = Provider.of<SubjectProvider>(context, listen: false);
                final success = await provider.deleteSubject(subject.id!);

                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mata pelajaran berhasil dihapus'),
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
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
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
              child: const Icon(Icons.book_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Daftar Mata Pelajaran',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddSubjectScreen(),
                  ),
                );
                if (result == true && mounted) {
                  Provider.of<SubjectProvider>(context, listen: false)
                      .loadSubjects();
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Widget Filter
          FilterAndSortWidget(
            onApplyFilter: (query, order) {
              Provider.of<SubjectProvider>(context, listen: false).applyFilters(query, order);
            },
            onResetFilter: () {
              Provider.of<SubjectProvider>(context, listen: false).resetFilters();
            },
          ),
          Expanded(
            child: Consumer<SubjectProvider>(
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
                          onPressed: () => provider.loadSubjects(),
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

                if (provider.subjects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(provider.isFilterActive ? Icons.filter_alt_off_rounded : Icons.book_rounded, size: 64, color: const Color(0xFFA0AEC0)),
                        const SizedBox(height: 16),
                        Text(
                          provider.isFilterActive ? 'Tidak ada mata pelajaran yang cocok' : 'Belum ada mata pelajaran',
                          style: const TextStyle(color: Color(0xFF4A5568), fontSize: 16)
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: provider.loadSubjects,
                  child: ListView.builder(
                    itemCount: provider.subjects.length,
                    padding: const EdgeInsets.all(20),
                    itemBuilder: (context, index) {
                      final subject = provider.subjects[index];
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2196F3).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.book_rounded, color: Color(0xFF2196F3)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subject.nama,
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748), fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      subject.deskripsi,
                                      style: const TextStyle(color: Color(0xFF718096), fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_rounded, color: Color(0xFF2196F3)),
                                    onPressed: () => _navigateToEditScreen(subject),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_rounded, color: Color(0xFFE53E3E)),
                                    onPressed: () => _showDeleteConfirmation(subject),
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