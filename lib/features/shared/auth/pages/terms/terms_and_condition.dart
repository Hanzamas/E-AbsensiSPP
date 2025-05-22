import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:e_absensi/core/constants/app_strings.dart';
import 'package:e_absensi/features/shared/animations/fade_in_animation.dart';

class TermsAndConditionsPage extends StatelessWidget {
  final String source;
  
  const TermsAndConditionsPage({Key? key, this.source = 'login'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse terms and conditions content
    final List<String> termsList = AppStrings.termsAndConditionsContent
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.trim())
        .where((line) => line.contains(RegExp(r'^\d+\.')))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF2196F3),
            size: 20,
          ),
          onPressed: () => _navigateBack(context),
        ),
        title: Text(
          AppStrings.termsAndConditionsTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2196F3),
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeInAnimation(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Harap baca dan pahami syarat dan ketentuan berikut sebelum menggunakan aplikasi ini.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black87.withOpacity(0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
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
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFF2196F3).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => _navigateBack(context),
                    child: Text(
                      AppStrings.understandButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.only(right: 12, top: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}