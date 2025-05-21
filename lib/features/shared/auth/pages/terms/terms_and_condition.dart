import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:e_absensi/core/constants/strings.dart';
import 'package:e_absensi/shared/animations/fade_in_animation.dart';

class TermsAndConditionsPage extends StatelessWidget {
  final String source;
  
  const TermsAndConditionsPage({Key? key, this.source = 'login'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse terms and conditions content
    final List<String> termsList = Strings.termsAndConditionsContent
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.trim())
        .where((line) => line.contains(RegExp(r'^\d+\.')))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => _navigateBack(context),
        ),
        title: Text(
          Strings.termsAndConditionsTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
      body: SafeArea(
        child: FadeInAnimation(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: termsList.map((term) {
                        final match = RegExp(r'^\s*(\d+)\.\s*(.*)$').firstMatch(term);
                        if (match != null) {
                          final number = match.group(1)!;
                          final content = match.group(2)!;
                          return _buildTermItem(number, content);
                        }
                        return const SizedBox.shrink();
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _navigateBack(context),
                    child: Text(
                      Strings.understandButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateBack(BuildContext context) {
    if (source == 'register') {
      context.goNamed('register');
    } else {
      context.goNamed('login');
    }
  }

  Widget _buildTermItem(String number, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}