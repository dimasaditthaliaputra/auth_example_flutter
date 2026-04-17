import 'package:flutter/material.dart';

import 'auth_controller.dart';
import 'home_screen_redirector.dart';
import 'welcome_screen.dart';

// SplashScreen ini adalah screen pertama yang tampil saat app dibuka.
// Tugasnya hanya satu: cek apakah user punya session aktif atau tidak.
// Kalau ada session → langsung ke HomeScreen, kalau enggak → ke WelcomeScreen.

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final controller = AuthController();

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final hasSession = await controller.checkSession();

    if (!mounted) return;

    if (hasSession) {
      // User sudah login sebelumnya, langsung masuk home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreenRedirector(user: controller.currentUser!),
        ),
      );
    } else {
      // Belum punya session, suruh login dulu
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background and text color now inherited from the new ThemeData in main.dart
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Coquette Icon: Heart or stars
            Icon(
              Icons.favorite, // Heart icon
              size: 80,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 24),
            Text(
              'Auth Example',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 32,
                fontStyle: FontStyle.italic, // Adds an elegant touch
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Firebase + Supabase',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
