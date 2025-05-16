import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/bottom_navbar.dart';
import '../../../../core/constants/strings.dart';

class SppPage extends StatelessWidget {
  const SppPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String userRole = 'siswa';
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.credit_card, color: Colors.white),
            const SizedBox(width: 8),
            Text(Strings.SPPTitle, style: TextStyle(color: Colors.white)),
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    border: InputBorder.none,
                  ),
                  hint: const Text(
                    'Bulan Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  items: const [],
                  onChanged: (val) {},
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2, // SPP tab index
        userRole: userRole,
        context: context,
      ),
    );
  }
} 