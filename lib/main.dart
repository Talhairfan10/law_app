import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'theme/app_theme.dart';
import 'screens/landing_screen.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/lawyer/lawyer_dashboard_screen.dart';
import 'services/user_service.dart';

/// Global locale notifier for language switching.
/// Updated by the Language screen and consumed by MaterialApp.
final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GoogleSignIn.instance.initialize();

  // Temporary diagnostic script to check user types
  _printUserTypes();

  // Set status bar to transparent for immersive dark UI
  // SystemChrome.setSystemUIOverlayStyle(...)

  runApp(const MashviraApp());
}

Future<void> _printUserTypes() async {
  try {
    debugPrint("==================================================");
    debugPrint("DIAGNOSIS: PRINTING ALL USERS AND THEIR userType");
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final email = data['email'] ?? 'No email';
      final type = data['userType'];
      debugPrint("USER [${doc.id}]: Email: $email | userType: '$type' (Type: ${type.runtimeType})");
    }
    debugPrint("==================================================");
  } catch (e) {
    debugPrint("DIAGNOSIS ERROR: $e");
  }
}

class MashviraApp extends StatelessWidget {
  const MashviraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'Mashvira Law House',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: locale,
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
                // Role-based routing
                return FutureBuilder<String>(
                  future: UserService.getUserType(snapshot.data!.uid),
                  builder: (context, typeSnap) {
                    if (typeSnap.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        backgroundColor: Color(0xFF0F0B1E),
                        body: Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFD4A843)),
                        ),
                      );
                    }
                    final userTypeRaw = typeSnap.data;
                    final userType = (userTypeRaw ?? '').toString().trim().toLowerCase();
                    
                    // Strict check: Must exactly be 'lawyer'
                    if (userType == 'lawyer') {
                      return const LawyerDashboardScreen();
                    }
                    
                    // Default fallback is always Client
                    return const HomeDashboardScreen();
                  },
                );
              }
              return const LandingScreen();
            },
          ),
        );
      },
    );
  }
}
