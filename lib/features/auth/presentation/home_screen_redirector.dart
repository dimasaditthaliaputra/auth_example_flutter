import 'package:flutter/material.dart';
import '../../auth/domain/app_user.dart';
import '../../home/presentation/home_screen.dart';

// File ini hanya jembatan navigasi dari auth ke home.
// Kenapa dipisah? Karena SplashScreen dan LoginScreen butuh navigasi ke HomeScreen,
// tapi tidak boleh directly import dari features lain (prinsip clean separation).

class HomeScreenRedirector extends StatelessWidget {
  final AppUser user;

  const HomeScreenRedirector({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return HomeScreen(user: user);
  }
}
