class User {
  final int id;
  final String username;
  final String email;
  final String namaLengkap;
  final String role;
  final String? profilePict;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.namaLengkap,
    required this.role,
    this.profilePict,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      namaLengkap: json['nama_lengkap']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      profilePict: json['profile_pict']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'nama_lengkap': namaLengkap,
      'role': role,
      'profile_pict': profilePict,
    };
  }
}