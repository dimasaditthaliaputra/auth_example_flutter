import 'package:flutter/material.dart';

import '../../auth/domain/app_user.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/welcome_screen.dart';
import '../../../widgets/web_safe_image/web_safe_image.dart';

// HomeScreen: dashboard utama setelah user berhasil login.
// Di sini aku nampilin info user dari Supabase dan ada tombol logout.

class HomeScreen extends StatefulWidget {
  final AppUser user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = AuthRepository();

  bool _isLoadingUser = false;
  AppUser? _latestUser; // data user yang di-fetch ulang dari Supabase

  @override
  void initState() {
    super.initState();
    _latestUser = widget.user;
    _fetchLatestUserData();
  }

  // Ambil ulang data user terbaru dari Supabase
  Future<void> _fetchLatestUserData() async {
    setState(() => _isLoadingUser = true);
    try {
      final user = await _repo.fetchUserFromSupabase(widget.user.uid);
      if (mounted) {
        setState(() {
          _latestUser = user ?? widget.user;
        });
      }
    } catch (e) {
      // Kalau gagal, pakai data yang sudah ada
    } finally {
      if (mounted) setState(() => _isLoadingUser = false);
    }
  }

  void _showLovePhoto() {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipPath(
                clipper: HeartClipper(),
                child: Container(
                  width: 250,
                  height: 250,
                  color: Colors.white,
                  child: Image.asset(
                    'assets/foto.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          'Simpan foto as\nassets/foto.png',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    await _repo.signOut();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    user: _latestUser ?? widget.user,
                    onLogout: _handleLogout,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchLatestUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kartu selamat datang
                    _WelcomeCard(user: _latestUser!),
                    const SizedBox(height: 24),

                    // Info data dari Supabase
                    const Text(
                      'Data dari Supabase',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SupabaseInfoCard(user: _latestUser!),
                    const SizedBox(height: 32),

                    // Tombol Foto Bentuk Love
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        ),
                        onPressed: _showLovePhoto,
                        icon: const Icon(Icons.favorite),
                        label: const Text('Ini Apa Yaaa?'),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tombol refresh manual
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _fetchLatestUserData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Data dari Supabase'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─── Widget: Kartu selamat datang ────────────────────────────────────────────

class _WelcomeCard extends StatelessWidget {
  final AppUser user;
  const _WelcomeCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary, // Soft pink
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            clipBehavior: Clip.hardEdge,
            child: user.photoUrl != null
                ? WebSafeImage(url: user.photoUrl!)
                : const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${user.name ?? 'Cantik'}! 🎀',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget: Kartu info dari Supabase ────────────────────────────────────────

class _SupabaseInfoCard extends StatelessWidget {
  final AppUser user;
  const _SupabaseInfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(label: 'UID', value: user.uid),
          const Divider(height: 20),
          _InfoRow(label: 'Email', value: user.email),
          const Divider(height: 20),
          _InfoRow(label: 'Nama', value: user.name ?? '-'),
          const Divider(height: 20),
          _InfoRow(label: 'Dibuat', value: user.createdAt ?? '-'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── SettingsScreen ───────────────────────────────────────────────────────────
// Diletakkan di file ini karena masih satu fitur (home), bisa juga dipisah

class SettingsScreen extends StatelessWidget {
  final AppUser user;
  final VoidCallback onLogout;

  const SettingsScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Info user
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: user.photoUrl != null
                        ? WebSafeImage(url: user.photoUrl!)
                        : Icon(Icons.favorite,
                            size: 40, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name ?? 'Cantik',
                    style: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                ),
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Custom Clipper untuk bentuk hati (Love) ─────────────────────────────────

class HeartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double width = size.width;
    double height = size.height;
    Path path = Path();
    
    path.moveTo(width / 2, height / 4);
    path.cubicTo(width * 5 / 8, height / 8, width, height / 8, width, height / 2);
    path.cubicTo(width, height * 3 / 4, width / 2, height, width / 2, height);
    path.cubicTo(width / 2, height, 0, height * 3 / 4, 0, height / 2);
    path.cubicTo(0, height / 8, width * 3 / 8, height / 8, width / 2, height / 4);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
