# 🔐 Auth Example — Flutter + Firebase + Supabase

HI SEENGGGGGGGG! Ini tuh project Flutter sederhana yang menggabungkan **Firebase Authentication** dan **Supabase** sebagai backend data. Tujuannya biar kamu ngerti cara kerja keduanya bareng.

---

## 🚀 Flow Aplikasi

### 1. App dibuka → SplashScreen

Pertama kali app dibuka, yang tampil adalah `SplashScreen`. Tugasnya simple: cek apakah user punya **session Firebase yang masih aktif**.

- Kalau **ada session** → langsung redirect ke `HomeScreen`
- Kalau **tidak ada session** → redirect ke `WelcomeScreen`

---

### 2. WelcomeScreen → Pilih Login atau Register

Di sini user bisa milih:
- **Login** → ke `LoginScreen`
- **Daftar** → ke `RegisterScreen`

---

### 3. Login / Register → Firebase Auth

**Login Email:**
```
Email + Password
     ↓
FirebaseAuth.signInWithEmailAndPassword()
     ↓
Dapat Firebase User (uid, email, displayName, photoURL)
```

**Login Google SSO:**
```
Tap tombol Google
     ↓
GoogleSignIn.signIn() → dapat Google credential
     ↓
FirebaseAuth.signInWithCredential(googleCredential)
     ↓
Dapat Firebase User
```

**Register Email:**
```
Nama + Email + Password
     ↓
FirebaseAuth.createUserWithEmailAndPassword()
     ↓
user.updateDisplayName(nama)
     ↓
Dapat Firebase User
```

---

### 4. Sync Firebase → Supabase

Setelah berhasil login/register di Firebase, data user **langsung dikirim ke Supabase**:

```
Firebase User (uid, email, name, photoURL)
     ↓
Bungkus jadi AppUser model
     ↓
supabase.from('users').upsert(appUser.toJson(), onConflict: 'uid')
```

Kenapa `upsert`? Biar kalau user sudah ada (login kedua kali), datanya diperbarui, bukan error duplikasi.

---

### 5. HomeScreen → Fetch data dari Supabase

Setelah login, `HomeScreen` akan **fetch ulang data user dari Supabase** (bukan dari Firebase):

```
HomeScreen.initState()
     ↓
supabase.from('users').select().eq('uid', uid).maybeSingle()
     ↓
Tampilkan di UI (nama, email, created_at, dll)
```

User juga bisa pull-to-refresh untuk ambil data terbaru.

---

### 6. Logout

Di `SettingsScreen`, ada tombol logout yang:
1. Sign out dari Firebase
2. Sign out dari GoogleSignIn (biar dialog pilih akun muncul lagi)
3. Redirect ke `WelcomeScreen`

---

## 📁 Struktur Folder

```
lib/
├── main.dart                        ← Entry point, init Firebase & Supabase
└── features/
    ├── auth/
    │   ├── data/
    │   │   └── auth_repository.dart  ← Semua logic Firebase Auth + sync Supabase
    │   ├── domain/
    │   │   └── app_user.dart         ← Model user (serialisasi manual)
    │   └── presentation/
    │       ├── auth_controller.dart  ← Ngurusi state (isLoading, error, currentUser)
    │       ├── splash_screen.dart    ← Cek session otomatis saat app dibuka
    │       ├── welcome_screen.dart   ← Pilih login atau register
    │       ├── login_screen.dart     ← Form login + Google SSO
    │       ├── register_screen.dart  ← Form registrasi (nama, email, password)
    │       └── home_screen_redirector.dart ← Jembatan navigasi auth → home
    └── home/
        └── presentation/
            ├── home_screen.dart      ← Dashboard + fetch data dari Supabase
            └── settings_screen.dart  ← Info user + logout (diimplementasi di home_screen.dart)
```

### Penjelasan tiap folder:

| Folder | Fungsi |
|--------|--------|
| `auth/data/` | Tempat semua panggilan ke Firebase dan Supabase |
| `auth/domain/` | Model data user (`AppUser`) |
| `auth/presentation/` | Semua screen dan state management untuk fitur auth |
| `home/presentation/` | Dashboard setelah login |

---

## ⚙️ Setup Supabase

Buat tabel `users` di Supabase dengan struktur berikut:

```sql
create table users (
  uid text primary key,
  email text not null,
  name text,
  photo_url text,
  created_at text
);
```

Kalau mau pakai Row Level Security (RLS), tambahkan policy:

```sql
-- Aktifkan RLS
alter table users enable row level security;

-- User bisa insert/update data sendiri
create policy "Users can upsert own data"
on users for all
using (auth.uid()::text = uid);
```

---

## 🔧 Setup Firebase

1. Buat project di [Firebase Console](https://console.firebase.google.com/)
2. Aktifkan **Authentication** → **Sign-in methods**: Email/Password + Google
3. Download `google-services.json` → taruh di `android/app/`
4. Ganti konfigurasi di `main.dart`:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'your-api-key',
    appId: 'your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
  ),
);
```

> 💡 **Tips:** Kalau sudah install FlutterFire CLI, kamu bisa jalankan `flutterfire configure` dan pakai `DefaultFirebaseOptions.currentPlatform` yang lebih rapi.

---

## ▶️ Cara Menjalankan Project

```bash
# 1. Clone project (kalau dari repo)
git clone <repo-url>
cd auth_example

# 2. Install dependency
flutter pub get

# 3. Isi konfigurasi Firebase dan Supabase di main.dart

# 4. Jalankan app
flutter run
```

---

## 📦 Dependencies yang Dipakai

| Package | Fungsi |
|---------|--------|
| `firebase_core` | Inisialisasi Firebase |
| `firebase_auth` | Autentikasi (Email + Google) |
| `google_sign_in` | Google SSO |
| `supabase_flutter` | Koneksi ke Supabase (database) |

---

*TANYAAA KALAU ADA YANG GAK NGERTI SAYANGGG!* 😊
