// Model user yang akan disimpan/diambil dari Supabase.
// Fieldnya ambil dari data yang dikasih Firebase setelah login seng.

class AppUser {
  final String uid;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? createdAt;

  AppUser({
    required this.uid,
    required this.email,
    this.name,
    this.photoUrl,
    this.createdAt,
  });

  // ini mapping manual dari Map (response Supabase) ke Object
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  // kalu ini mapping manual dari Object ke Map (untuk kirim ke Supabase)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
      'created_at': createdAt,
    };
  }
}
