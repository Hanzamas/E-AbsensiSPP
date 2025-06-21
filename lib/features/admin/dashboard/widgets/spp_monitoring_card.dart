import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:e_absensi/core/api/api_endpoints.dart';
import '../provider/dashboard_provider.dart';
import '../data/services/report_service.dart';
import 'dashboard_stat_card.dart';

class SppMonitoringCard extends StatefulWidget {
  const SppMonitoringCard({Key? key}) : super(key: key);

  @override
  State<SppMonitoringCard> createState() => _SppMonitoringCardState();
}

class _SppMonitoringCardState extends State<SppMonitoringCard> {
  bool _isDownloading = false;
  final ReportService _reportService = ReportService();

  Future<void> _handleDownload({Map<String, dynamic>? filters, required String fileName}) async {
    setState(() => _isDownloading = true);
    try {
      final filePath = await _reportService.downloadReport(
        endpoint: ApiEndpoints.downloadSppReport,
        saveFileName: fileName,
        queryParams: filters,
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Laporan SPP berhasil diunduh di: $filePath'), backgroundColor: Colors.green, duration: const Duration(seconds: 4)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengunduh: ${e.toString()}'), backgroundColor: Colors.red, duration: const Duration(seconds: 4)));
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }
  
  Future<void> _showDownloadOptionsDialog() async {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Opsi Download Laporan'),
          content: const Text('Anda ingin mengunduh semua data laporan atau menggunakan filter terlebih dahulu?'),
          actions: <Widget>[
            TextButton(child: const Text('Gunakan Filter'), onPressed: () { Navigator.of(dialogContext).pop(); _showSppFilterDialog(); }),
            ElevatedButton(child: const Text('Download Semua'), onPressed: () {
              final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
              Navigator.of(dialogContext).pop();
              _handleDownload(fileName: 'Laporan_SPP_Semua_$timestamp.xlsx', filters: {});
            }),
          ],
        );
      },
    );
  }

  Future<void> _showSppFilterDialog() async {
    final nisController = TextEditingController();
    final studentNameController = TextEditingController();
    final classNameController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final billMonthController = TextEditingController();
    final billYearController = TextEditingController();
    String? statusBill;
    String? statusPayment;

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Filter Laporan SPP'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(controller: nisController, decoration: const InputDecoration(labelText: 'NIS')),
                const SizedBox(height: 8),
                TextFormField(controller: studentNameController, decoration: const InputDecoration(labelText: 'Nama Siswa')),
                const SizedBox(height: 8),
                TextFormField(controller: classNameController, decoration: const InputDecoration(labelText: 'Nama Kelas')),
                const SizedBox(height: 8),
                TextFormField(
                  controller: startDateController,
                  decoration: const InputDecoration(labelText: 'Tgl Bayar Mulai'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2101));
                    if (picked != null) startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: endDateController,
                  decoration: const InputDecoration(labelText: 'Tgl Bayar Akhir'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2101));
                    if (picked != null) endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(controller: billMonthController, decoration: const InputDecoration(labelText: 'Bulan Tagihan (e.g. 6)'), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                TextFormField(controller: billYearController, decoration: const InputDecoration(labelText: 'Tahun Tagihan (e.g. 2025)'), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: statusBill,
                  decoration: const InputDecoration(labelText: 'Status Tagihan'),
                  items: ['lunas', 'terhutang'].map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value[0].toUpperCase() + value.substring(1)))).toList(),
                  onChanged: (String? newValue) => statusBill = newValue,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: statusPayment,
                  decoration: const InputDecoration(labelText: 'Status Pembayaran'),
                  items: ['sukses', 'pending', 'gagal'].map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value[0].toUpperCase() + value.substring(1)))).toList(),
                  onChanged: (String? newValue) => statusPayment = newValue,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(child: const Text('Batal'), onPressed: () => Navigator.of(dialogContext).pop()),
            ElevatedButton(
              child: const Text('Download'),
              onPressed: () {
                final filters = {
                  'nis': nisController.text, 'student_name': studentNameController.text,
                  'class_name': classNameController.text, 'start_payment_date': startDateController.text,
                  'end_payment_date': endDateController.text, 'bill_month': billMonthController.text,
                  'bill_year': billYearController.text, 'status_bill': statusBill,
                  'status_payment': statusPayment,
                };
                final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
                Navigator.of(dialogContext).pop();
                _handleDownload(fileName: 'Laporan_SPP_Filter_$timestamp.xlsx', filters: filters);
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF2196F3).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.credit_card, color: Color(0xFF2196F3), size: 20)),
              const SizedBox(width: 12),
              const Text('Monitoring SPP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
              const Spacer(),
              _isDownloading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF2196F3)))
                  : IconButton(onPressed: _showDownloadOptionsDialog, icon: const Icon(Icons.download_rounded, color: Color(0xFF2196F3)), tooltip: 'Download Laporan SPP'),
            ]),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Expanded(child: DashboardStatCard(title: 'Total Siswa', value: provider.totalStudents.toString(), color: const Color(0xFF718096), icon: Icons.people, titleFontSize: 11)),
              const SizedBox(width: 12),
              Expanded(child: DashboardStatCard(title: 'Sudah Bayar', value: provider.totalSppPaid.toString(), color: const Color(0xFF4CAF50), icon: Icons.check_circle, titleFontSize: 11)),
              const SizedBox(width: 12),
              Expanded(child: DashboardStatCard(title: 'Belum Bayar', value: provider.totalSppUnpaid.toString(), color: const Color(0xFFE53E3E), icon: Icons.cancel, titleFontSize: 11)),
            ])
          ],
        ),
      ),
    );
  }
}