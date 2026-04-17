import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../data/auth_repository.dart';
import '../domain/app_user.dart';

// AuthController ini ngurusi state dari semua hal yang berhubungan dengan auth.
// Kita pakai ChangeNotifier (setState-style), tidak pakai Riverpod/Provider.

class AuthController extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  bool isLoading = false;
  String? errorMessage;
  AppUser? currentUser;

  // ─── LOGIN EMAIL ─────────────────────────────────────────────────────────

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      currentUser = await _repo.signInWithEmail(
        email: email,
        password: password,
      );
      return currentUser != null;
    } catch (e) {
      debugPrint('DEBUG: Error SignInEmail -> $e');
      errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── REGISTER EMAIL ──────────────────────────────────────────────────────

  Future<bool> registerWithEmail(String email, String password, String name) async {
    _setLoading(true);
    _clearError();
    try {
      currentUser = await _repo.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );
      return currentUser != null;
    } catch (e) {
      debugPrint('DEBUG: Error RegisterEmail -> $e');
      errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── GOOGLE SSO ──────────────────────────────────────────────────────────

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      currentUser = await _repo.signInWithGoogle();
      return currentUser != null;
    } catch (e) {
      debugPrint('DEBUG: Error SignInGoogle -> $e');
      errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── LOGOUT ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _repo.signOut();
    currentUser = null;
    notifyListeners();
  }

  // ─── CEK SESSION (dipakai di SplashScreen) ───────────────────────────────

  Future<bool> checkSession() async {
    try {
      final firebase_auth.User? firebaseUser = _repo.currentFirebaseUser;
      if (firebaseUser == null) return false;

      // Kalau ada session Firebase, coba ambil data dari Supabase
      currentUser = await _repo.fetchUserFromSupabase(firebaseUser.uid);
      return currentUser != null;
    } catch (e) {
      debugPrint('DEBUG: Error CheckSession -> $e');
      return false;
    }
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    errorMessage = null;
    notifyListeners();
  }

  // Pesan error yang lebih manusiawi dari Firebase
  String _parseError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('user-not-found')) return 'Email tidak ditemukan.';
    if (msg.contains('wrong-password')) return 'Password salah.';
    if (msg.contains('invalid-credential')) return 'Email atau password salah.';
    if (msg.contains('email-already-in-use')) return 'Email sudah terdaftar.';
    if (msg.contains('weak-password')) return 'Password terlalu lemah (min. 6 karakter).';
    if (msg.contains('invalid-email')) return 'Format email tidak valid.';
    if (msg.contains('network-request-failed')) return 'Tidak ada koneksi internet.';
    
    if (msg.contains('supabase')) return 'Gagal sinkron data ke Supabase.';
    
    return 'Terjadi kesalahan: $e';
  }
}
