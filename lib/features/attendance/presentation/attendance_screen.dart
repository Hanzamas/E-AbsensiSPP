import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/strings.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? _selectedSubject;
  DateTime _selectedDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  final List<String> _subjects = [
    'Matematika',
    'Bahasa Indonesia',
    'Bahasa Inggris',
    // Tambah mata pelajaran lainnya
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.article_outlined,
              color: Colors.white, // Ikon article berwarna putih
            ),
            const SizedBox(width: 8),
            Text(
              Strings.AttendanceTitle,
              style: TextStyle(color: Colors.white),
            ),
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
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Color(0xFF2196F3)),
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
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Color(0xFF2196F3)),
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
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Table Header
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        Strings.DateTitle,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        Strings.CourseTitle,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        Strings.StatusTitle,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        Strings.CaptionTitle,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              // Empty State / List
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      Strings.EmptyState,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF475A6B)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF2196F3),
        onPressed: () {
          context.go('/scan-qr');
        },
        child: Icon(Icons.qr_code_scanner),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Absensi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'SPP'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: 1, // Absensi
      //   selectedItemColor: Color(0xFF2196F3),
      //   unselectedItemColor: Colors.grey,
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.format_list_bulleted),
      //       label: 'Absensi',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.credit_card),
      //       label: 'SPP',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Akun',
      //     ),
      //   ],
      //   onTap: (index) {
      //     // TODO: Handle navigation tap
      //   },
      // ),
    );
  }
}
