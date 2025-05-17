import 'package:flutter/material.dart';
import '../../../../core/constants/strings.dart';
import 'package:go_router/go_router.dart';

class SppBarcodePage extends StatelessWidget {
  final String bulan;
  const SppBarcodePage({Key? key, required this.bulan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.SPPBarcodeTitle, style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(Icons.qr_code, size: 120, color: Colors.grey[400]), // Dummy QR
                ),
              ),
              const SizedBox(height: 24),
              Text(
                Strings.SPPBarcodeDeadline,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '5.00',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 