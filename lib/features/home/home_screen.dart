import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/parakh_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.isHindi, super.key});

  final bool isHindi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          AppStrings.text('setupComplete', isHindi),
          style: const TextStyle(
            color: ParakhColors.forestGreen,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
