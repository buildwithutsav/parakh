import 'package:flutter/material.dart';

import 'core/theme/parakh_theme.dart';
import 'features/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ParakhApp());
}

class ParakhApp extends StatelessWidget {
  const ParakhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parakh',
      theme: ParakhTheme.light,
      home: const SplashScreen(),
    );
  }
}
