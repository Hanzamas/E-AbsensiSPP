import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/teaching_provider.dart';
import '../../data/models/teaching_model.dart';
import 'add_teaching_screen.dart';
import 'edit_teaching_screen.dart'; 
import '../../widgets/teaching_filter_widget.dart'; // Ganti import ke widget filter yang baru

class TeachingListScreen extends StatefulWidget {
  const TeachingListScreen({Key? key}) : super(key: key);

  @override
  _TeachingListScreenState createState() => _TeachingListScreenState();
}

class _TeachingListScreenState extends State<TeachingListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TeachingProvider>(context, listen: false);
      provider.loadAllTeachings();
      // Pastikan dependensi untuk filter juga dimuat
      provider.loadDependencies();
    });
  }

  void _navigateToEdit(BuildContext context, TeachingModel teaching) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: Provider.of<TeachingProvider>(context, listen: false),
          child: EditTeachingScreen(teaching: teaching),
        ),
      ),
    ).then((isSuccess) {
      if (isSuccess == true) {
        Provider.of<TeachingProvider>(context, listen: false).loadAllTeachings();
      }
    });
  }
  
  void _navigateToAdd(BuildContext context) {
     Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: Provider.of<TeachingProvider>(context, listen: false),
          child: const AddTeachingScreen(),
        ),
      ),
    ).then((isSuccess) {
      if (isSuccess == true) {
        Provider.of<TeachingProvider>(context, listen: false).loadAllTeachings();
      }
    });
  }

  void _showDeleteConfirmation(BuildContext context, TeachingModel teaching) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Anda yakin ingin menghapus jadwal "${teaching.namaMapel}" oleh ${teaching.namaGuru}?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final provider = Provider.of<TeachingProvider>(context, listen: false);
              final success = await provider.deleteTeaching(teaching.id);
              if (mounted && !success) {
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text('Gagal menghapus: ${provider.error}'), backgroundColor: Colors.red),
                );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengajaran'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Consumer<TeachingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.teachings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null && provider.teachings.isEmpty) {
            return Center(child: Text("Terjadi Error: ${provider.error}"));
          }

          final teachings = provider.filteredTeachings;

          return RefreshIndicator(
            onRefresh: () async {
              provider.clearFilters();
              await provider.loadAllTeachings();
            },
            child: Column(
              children: [
                // --- GANTI KE WIDGET FILTER YANG BARU ---
                const TeachingFilterWidget(),
                Expanded(
                  child: teachings.isEmpty
                      ? Center(
                          child: Text(
                            provider.isFilterActive
                                ? 'Tidak ada data pengajaran\nyang cocok dengan filter Anda.'
                                : 'Belum ada data pengajaran.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          itemCount: teachings.length,
                          itemBuilder: (context, index) {
                            final teaching = teachings[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2196F3).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.assignment_ind_rounded, color: Color(0xFF2196F3), size: 28),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            teaching.namaMapel,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text('Kelas: ${teaching.namaKelas}', style: TextStyle(color: Colors.grey.shade700)),
                                          Text('Guru: ${teaching.namaGuru}', style: TextStyle(color: Colors.grey.shade700)),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Jadwal: ${teaching.hari.replaceFirst(teaching.hari[0], teaching.hari[0].toUpperCase())}, ${teaching.jamMulai.substring(0, 5)} - ${teaching.jamSelesai.substring(0, 5)}',
                                            style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                          onPressed: () => _navigateToEdit(context, teaching),
                                          tooltip: 'Edit',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                                          onPressed: () => _showDeleteConfirmation(context, teaching),
                                          tooltip: 'Hapus',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAdd(context),
        backgroundColor: const Color(0xFF2196F3),
        tooltip: 'Tambah Pengajaran',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}