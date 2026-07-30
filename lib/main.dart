import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'theme/app_theme.dart';
import 'screens/landing_screen.dart';
import 'screens/home_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GoogleSignIn.instance.initialize();

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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF0F0B1E),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
              ),
            );
          }
          if (snapshot.hasData) {
            return const HomeDashboardScreen();
          }
          return const LandingScreen();
        },
      ),
    );
  }
}
