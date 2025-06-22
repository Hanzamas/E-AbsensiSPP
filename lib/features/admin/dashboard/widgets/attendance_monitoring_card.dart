import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:e_absensi/core/api/api_endpoints.dart';
import '../provider/dashboard_provider.dart';
import '../data/services/report_service.dart';
import 'dashboard_stat_card.dart';

class AttendanceMonitoringCard extends StatefulWidget {
  const AttendanceMonitoringCard({Key? key}) : super(key: key);

  @override
  State<AttendanceMonitoringCard> createState() => _AttendanceMonitoringCardState();
}

class _AttendanceMonitoringCardState extends State<AttendanceMonitoringCard> {
  bool _isDownloading = false;
  final ReportService _reportService = ReportService();

  Future<void> _handleDownload({Map<String, dynamic>? filters, required String fileName}) async {
    setState(() => _isDownloading = true);
    try {
      final filePath = await _reportService.downloadReport(
        endpoint: ApiEndpoints.downloadAttendanceReport,
        saveFileName: fileName,
        queryParams: filters,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Laporan berhasil diunduh di: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal mengunduh: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4)));
      }
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
            TextButton(
              child: const Text('Gunakan Filter'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _showAttendanceFilterDialog();
              },
            ),
            ElevatedButton(
              child: const Text('Download Semua'),
              onPressed: () {
                final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
                Navigator.of(dialogContext).pop();
                _handleDownload(
                    fileName: 'Laporan_Absensi_Semua_$timestamp.xlsx', filters: {});
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAttendanceFilterDialog() async {
    final studentNameController = TextEditingController();
    final teacherNameController = TextEditingController();
    final subjectNameController = TextEditingController();
    final classNameController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    String? status;

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Filter Laporan Absensi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(controller: studentNameController, decoration: const InputDecoration(labelText: 'Nama Siswa')),
                const SizedBox(height: 8),
                TextFormField(controller: teacherNameController, decoration: const InputDecoration(labelText: 'Nama Guru')),
                const SizedBox(height: 8),
                TextFormField(controller: subjectNameController, decoration: const InputDecoration(labelText: 'Nama Mapel')),
                const SizedBox(height: 8),
                TextFormField(controller: classNameController, decoration: const InputDecoration(labelText: 'Nama Kelas')),
                const SizedBox(height: 8),
                TextFormField(
                  controller: startDateController,
                  decoration: const InputDecoration(labelText: 'Tanggal Mulai', hintText: 'YYYY-MM-DD'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2101));
                    if (picked != null) {
                      startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: endDateController,
                  decoration: const InputDecoration(labelText: 'Tanggal Akhir', hintText: 'YYYY-MM-DD'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2101));
                    if (picked != null) {
                      endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                    }
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status Kehadiran'),
                  items: ['hadir', 'alpha', 'izin', 'sakit'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value[0].toUpperCase() + value.substring(1)));
                  }).toList(),
                  onChanged: (String? newValue) { status = newValue; },
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
                  'student_name': studentNameController.text, 'teacher_name': teacherNameController.text,
                  'subject_name': subjectNameController.text, 'class_name': classNameController.text,
                  'start_date': startDateController.text, 'end_date': endDateController.text,
                  'status': status,
                };
                final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
                Navigator.of(dialogContext).pop();
                _handleDownload(
                  fileName: 'Laporan_Absensi_Filter_$timestamp.xlsx', filters: filters);
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
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.bar_chart, color: Color(0xFF2196F3), size: 20)),
              const SizedBox(width: 12),
              const Text('Monitoring Absensi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
              const Spacer(),
              _isDownloading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF2196F3)))
                  : IconButton(
                      onPressed: _showDownloadOptionsDialog,
                      icon: const Icon(Icons.download_rounded, color: Color(0xFF2196F3)),
                      tooltip: 'Download Laporan Absensi'),
            ]),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Expanded(child: DashboardStatCard(title: 'Total Siswa', value: provider.totalStudents.toString(), color: const Color(0xFF718096), icon: Icons.people, titleFontSize: 11)),
              const SizedBox(width: 12),
              Expanded(child: DashboardStatCard(title: 'Total Hadir', value: provider.totalPresent.toString(), color: const Color(0xFF4CAF50), icon: Icons.check_circle, titleFontSize: 11)),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Expanded(child: DashboardStatCard(title: 'Total Alpha', value: provider.totalAlpha.toString(), color: const Color(0xFFE53E3E), icon: Icons.cancel, titleFontSize: 11)),
              const SizedBox(width: 12),
              Expanded(child: DashboardStatCard(title: 'Sakit/Izin', value: provider.totalSickOrPermit.toString(), color: const Color(0xFFFF9800), icon: Icons.healing, titleFontSize: 10)),
            ])
          ],
        ),
      ),
    );
  }
}