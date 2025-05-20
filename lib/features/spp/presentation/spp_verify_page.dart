import 'package:flutter/material.dart';
import '../../../../core/constants/strings.dart';

class SppVerifyPage extends StatelessWidget {
  const SppVerifyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 100),
              SizedBox(height: 24),
              Text(
                Strings.SPPVerifyTitle,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 