import 'package:flutter/material.dart';

class DefaultLoading extends StatelessWidget {
  const DefaultLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
      ),
    );
  }
}
