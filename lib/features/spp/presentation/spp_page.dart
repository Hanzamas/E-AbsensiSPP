import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/bottom_navbar.dart';
import '../../../../core/constants/strings.dart';

class SppPage extends StatefulWidget {
  const SppPage({Key? key}) : super(key: key);

  @override
  State<SppPage> createState() => _SppPageState();
}

class _SppPageState extends State<SppPage> {
  String? selectedMonth;

  void _showMonthPicker() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: Strings.SPPMonths.map((bulan) => ListTile(
            title: Text(bulan, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            onTap: () => Navigator.pop(context, bulan),
          )).toList(),
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedMonth = picked;
      });
      // TODO: Navigate ke detail atau update tampilan
    }
  }

  @override
  Widget build(BuildContext context) {
    String userRole = 'siswa';
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.credit_card, color: Colors.white),
            const SizedBox(width: 8),
            Text(Strings.SPPTitle, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2196F3), Color(0xFFE3F2FD)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              GestureDetector(
                onTap: _showMonthPicker,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedMonth ?? Strings.SPPMonthTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
              // Bisa tambahkan tampilan detail bulan di bawah jika sudah dipilih
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        userRole: userRole,
        context: context,
      ),
    );
  }
} 