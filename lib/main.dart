import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/presentation/splash_screen.dart';

const String _supabaseUrl = 'https://jxoepvnoidctlnejonzc.supabase.co';
const String _supabaseAnonKey =
    'sb_publishable_NQdT419cZkl7NQTaFNYPGg_f3Co5mhA';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCjNDT0QfbA7la30W03RMue0mNj77aXCVk',
      appId: '1:869361773034:android:151bdf3f55ab8990d0aa93',
      messagingSenderId: '869361773034',
      projectId: 'authexample-9c207',
    ),
  );

  // Inisialisasi GoogleSignIn
  await GoogleSignIn.instance.initialize(
    serverClientId:
        '869361773034-4vias09lbl45f3iddd4gq1hul8hnivk7.apps.googleusercontent.com',
  );

  // Inisialisasi Supabase
  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFB6C1), // Pastel Pink
          primary: const Color(0xFFFFB6C1),
          secondary: const Color(0xFFF48FB1), // Soft Pink
          surface: const Color(0xFFFFF0F5), // Lavender Blush
          onPrimary: const Color(0xFF5C4033), // Warm dark brown text
          onSurface: const Color(0xFF5C4033),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF0F5),
        useMaterial3: true,
        // Global Input styling (Soft Rounded)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.8),
          labelStyle: const TextStyle(color: Color(0xFF8B7355)),
          prefixIconColor: const Color(0xFFF48FB1),
          suffixIconColor: const Color(0xFFF48FB1),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Color(0xFFFFE4E1), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Color(0xFFFFB6C1), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Color(0xFFE57373)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Color(0xFFE57373), width: 2),
          ),
        ),
        // Global Elevated Button Styling (Pill shaped, soft)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB6C1), // Primary Pink
            foregroundColor: const Color(0xFF5C4033), // Brown Text
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ),
        // Global Outlined Button Styling
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF5C4033),
            side: const BorderSide(color: Color(0xFFFFB6C1), width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ),
        // App Bar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF5C4033)),
          titleTextStyle: TextStyle(
            color: Color(0xFF5C4033),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
