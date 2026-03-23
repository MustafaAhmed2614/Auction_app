import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth_gate_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseReady = false;
  String? firebaseError;

  // Initialize Firebase (Requires flutterfire configure)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    firebaseError = e.toString();
  }

  runApp(
    ProviderScope(
      child: MyApp(firebaseReady: firebaseReady, firebaseError: firebaseError),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool firebaseReady;
  final String? firebaseError;

  const MyApp({super.key, required this.firebaseReady, this.firebaseError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BPL Auction',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20), // Cricket green
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: firebaseReady
          ? const AuthGateScreen()
          : FirebaseUnavailableScreen(errorMessage: firebaseError),
    );
  }
}

class FirebaseUnavailableScreen extends StatelessWidget {
  final String? errorMessage;

  const FirebaseUnavailableScreen({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF0D47A1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                color: Colors.black45,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/app_logo.png',
                          height: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.sports_cricket,
                            size: 72,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Firebase Not Available',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'This app requires Firebase configuration for the current platform. Configure FlutterFire and restart the app.',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        SelectableText(
                          errorMessage!,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
