import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/strings.dart';
import '../../../shared/widgets/bottom_navbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/auth/cubit/auth_cubit.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? _selectedSubject;
  DateTime _selectedDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  int _selectedIndex = 1;

  final List<String> _subjects = [
    'Matematika',
    'Bahasa Indonesia',
    'Bahasa Inggris',
  ];

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String userRole = 'siswa';
        if (state is AuthSuccess) {
          userRole = state.auth.role;
        }
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Icon(
                  Icons.article_outlined,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(Strings.AttendanceTitle, style: TextStyle(color: Colors.white)),
              ],
            ),
            backgroundColor: Color(0xFF2196F3),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2196F3), Color(0xFFE3F2FD)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          // Dropdown Mata Pelajaran
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                            ),
                            hint: Text(Strings.CourseTitle),
                            value: _selectedSubject,
                            items:
                                _subjects.map((subject) {
                                  return DropdownMenuItem(
                                    value: subject,
                                    child: Text(subject),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedSubject = val;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          // Date Picker
                          InkWell(
                            onTap: _pickDate,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_dateFormat.format(_selectedDate)),
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: Color(0xFF2196F3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Buttons Filter & Unduh
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Color(0xFF2196F3)),
                                  minimumSize: const Size(140, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  // TODO: Implement filter logic
                                },
                                icon: Icon(
                                  Icons.filter_list,
                                  color: Color(0xFF2196F3),
                                ),
                                label: Text(
                                  Strings.FilterTitle,
                                  style: TextStyle(color: Color(0xFF2196F3)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Color(0xFF2196F3)),
                                  minimumSize: const Size(140, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  // TODO: Implement unduh (download) logic
                                },
                                icon: Icon(
                                  Icons.download,
                                  color: Color(0xFF2196F3),
                                ),
                                label: Text(
                                  Strings.DownloadTitle,
                                  style: TextStyle(color: Color(0xFF2196F3)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 350,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBBDEFB),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  children: const [
                                    _TableHeaderCell('Tanggal'),
                                    _TableHeaderCell('Mata pelajaran'),
                                    _TableHeaderCell('Status'),
                                    _TableHeaderCell('Keterangan'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Stack(
                                  children: [
                                    SingleChildScrollView(
                                      child: SizedBox(
                                        height: 200,
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        'Tidak ada data absensi\npada tanggal ini.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton(
                            heroTag: 'qr-btn',
                            backgroundColor: Color(0xFF2196F3),
                            onPressed: () {
                              context.go('/scan-qr');
                            },
                            child: Icon(Icons.qr_code_scanner),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _selectedIndex,
            userRole: userRole,
            context: context,
          ),
        );
      },
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;
  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}
