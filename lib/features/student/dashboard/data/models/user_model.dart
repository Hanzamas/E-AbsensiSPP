

class User {
  final String id;
  final String username;
  final String namaLengkap;
  final String email;
  final String role;
  final String? profilePict;

  User({
    required this.id,
    required this.username,
    required this.namaLengkap,
    required this.email,
    required this.role,
    this.profilePict,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? json['namaLengkap'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      profilePict: json['profile_pict'],
    );
  }

  // Fallback empty constructor
  factory User.empty() {
    return User(
      id: '',
      username: 'User',
      namaLengkap: 'User',
      email: '',
      role: 'siswa',
      profilePict: null,
    );
  }
}