

class UserProfileModel {
  final String id;
  final String username;
  final String namaLengkap;
  final String email;
  final String role;

  UserProfileModel({
    required this.id,
    required this.username,
    required this.namaLengkap,
    required this.email,
    required this.role,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? json['namaLengkap'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }

  String get firstName => namaLengkap.isNotEmpty ? namaLengkap.split(' ').first : 'Siswa';
  String get greetingName => ' $firstName';
  String get displayName => namaLengkap.isNotEmpty ? namaLengkap : username;
}