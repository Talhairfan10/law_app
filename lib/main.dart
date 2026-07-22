import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar to transparent for immersive dark UI
  // SystemChrome.setSystemUIOverlayStyle(...)

  runApp(const MashviraApp());
}

class MashviraApp extends StatelessWidget {
  const MashviraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mashvira Law House',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const OnboardingScreen(),
    );
  }
}
