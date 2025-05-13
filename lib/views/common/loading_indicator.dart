import 'package:flutter/material.dart';
import 'package:dream_journal/utils/theme_helper.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: ThemeHelper.primaryColor,
      ),
    );
  }
}
