import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/app_user.dart';

// AuthRepository ini ngurusi semua urusan autentikasi:
// - Login/Register pakai Firebase (email & Google)
// - Setelah login, sync data user ke Supabase

class AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Cek apakah user sudah login sebelumnya (session aktif di Firebase)
  firebase_auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  // Login dengan email & password

  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) return null;

    return await _syncUserToSupabase(user);
  }

  // Register dengan email & password

  Future<AppUser?> registerWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) return null;

    // Kalau ada nama, update display name dulu di Firebase
    if (name != null && name.isNotEmpty) {
      await user.updateDisplayName(name);
      await user.reload();
    }

    return await _syncUserToSupabase(
      _firebaseAuth.currentUser ?? user,
    );
  }

  // Login pakai Google SSO

  Future<AppUser?> signInWithGoogle() async {
    // Pada platform Web, google_sign_in v7.2+ tidak mensupport pemanggilan login pop-up 
    // secara manual tanpa menggunakan widget GoogleSignInButton khusus.
    // Oleh karena itu, kita bypass dengan langsung menggunakan Firebase Auth provider!
    if (kIsWeb) {
      final googleProvider = firebase_auth.GoogleAuthProvider();
      
      final userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      final user = userCredential.user;
      if (user == null) return null;

      return await _syncUserToSupabase(user);
    }

    // Untuk Mobile (Android/iOS)
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw Exception('Google Sign-In tidak didukung di platform ini.');
    }

    final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

    // Di google_sign_in v7, .authentication tidak perlu di-await
    // sayang km cm perlu idToken untuk Firebase (accessToken terpisah untuk Google API)
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final String? idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception('Tidak bisa mendapatkan ID token dari Google.');
    }

    // Buat credential Firebase dari idToken Google
    final credential = firebase_auth.GoogleAuthProvider.credential(
      idToken: idToken,
    );

    // Login ke Firebase pakai credential Google
    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) return null;

    return await _syncUserToSupabase(user);
  }


  // Logout

  Future<void> signOut() async {
    // Firebase sign out
    await _firebaseAuth.signOut();

    // Google sign out (biar dialog pilih akun muncul lagi saat login berikutnya)
    await GoogleSignIn.instance.signOut();
  }

  // Sync user ke Supabase
  // Ambil data dari Firebase, simpan ke Supabase pakai UPSERT
  // Kalau user sudah ada (login kedua kali) harus update, bukan insert duplikat
  // RLS nya cek readme seng

  Future<AppUser?> _syncUserToSupabase(firebase_auth.User firebaseUser) async {
    final appUser = AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      createdAt: DateTime.now().toIso8601String(),
    );

    await _supabase.from('users').upsert(
      appUser.toJson(),
      onConflict: 'uid', // kalau uid sudah ada, update saja
    );

    return appUser;
  }

  // Fetch user dari Supabase
  // Dipakai kalau mau ambil data user terbaru dari DB (bukan dari Firebase)

  Future<AppUser?> fetchUserFromSupabase(String uid) async {
    final response = await _supabase
        .from('users')
        .select()
        .eq('uid', uid)
        .maybeSingle();

    if (response == null) return null;
    return AppUser.fromJson(response);
  }
}
