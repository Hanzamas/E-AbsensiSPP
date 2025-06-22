import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/academic_year_provider.dart';
import '../../data/models/academic_year_model.dart';
import '../../widgets/academic_date_picker_helper.dart';
import 'edit_academic_year_screen.dart';

class AcademicYearListScreen extends StatefulWidget {
  const AcademicYearListScreen({Key? key}) : super(key: key);

  @override
  State<AcademicYearListScreen> createState() => _AcademicYearListScreenState();
}

class _AcademicYearListScreenState extends State<AcademicYearListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AcademicYearProvider>(context, listen: false).fetchAcademicYears();
    });
  }


  // ====== PERBAIKAN DI SINI ======
  void _navigateToEdit(AcademicYearModel year) {
    // Ambil provider dari context saat ini (AcademicYearListScreen)
    final provider = Provider.of<AcademicYearProvider>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        // Berikan instance provider yang sudah ada ke halaman baru
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: EditAcademicYearScreen(academicYear: year),
        ),
      ),
    ).then((isSuccess) {
      if (isSuccess == true) {
        provider.fetchAcademicYears();
      }
    });
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final provider = Provider.of<AcademicYearProvider>(context, listen: false);
              final success = await provider.deleteAcademicYear(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Data berhasil dihapus' : 'Gagal menghapus: ${provider.error}'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
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
        title: const Text('Daftar Tahun Ajaran',style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF2196F3),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<AcademicYearProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.academicYears.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text("Terjadi Error: ${provider.error}"));
          }
          if (provider.academicYears.isEmpty) {
            return const Center(child: Text("Tidak ada data tahun ajaran."));
          }
          return RefreshIndicator(
            onRefresh: () => provider.fetchAcademicYears(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: provider.academicYears.length,
              itemBuilder: (context, index) {
                final year = provider.academicYears[index];
                final formattedStartDate = AcademicDatePickerHelper.formatDateIndonesian(year.tanggalMulai);
                final formattedEndDate = AcademicDatePickerHelper.formatDateIndonesian(year.tanggalSelesai);
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(year.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('Periode: $formattedStartDate - $formattedEndDate', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _navigateToEdit(year)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _showDeleteConfirmation(year.id!)),
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
    );
  }
}