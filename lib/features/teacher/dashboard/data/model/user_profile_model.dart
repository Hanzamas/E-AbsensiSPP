class UserProfileModel {
  final int id;
  final String username;
  final String email;
  final String role;
  final String namaLengkap;

  UserProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.namaLengkap,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
    );
  }

  String get firstName => namaLengkap.isNotEmpty ? namaLengkap.split(' ').first : 'Guru';
  String get greetingName => 'Pak/Bu $firstName';
  String get displayName => namaLengkap.isNotEmpty ? namaLengkap : username;
}