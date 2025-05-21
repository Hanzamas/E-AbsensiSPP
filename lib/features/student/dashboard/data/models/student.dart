class Student {
  final int id;
  final String username;
  final String email;
  final String role;
  final String? siswaNamaLengkap;
  final String? siswaNis;
  final String? guruNamaLengkap;
  final String? guruNip;

  Student({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.siswaNamaLengkap,
    this.siswaNis,
    this.guruNamaLengkap,
    this.guruNip,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      siswaNamaLengkap: json['siswa_nama_lengkap'],
      siswaNis: json['siswa_nis'],
      guruNamaLengkap: json['guru_nama_lengkap'],
      guruNip: json['guru_nip'],
    );
  }

  // Getter untuk mendapatkan nama yang sesuai berdasarkan role
  String get displayName {
    if (role.toLowerCase() == 'siswa') {
      return siswaNamaLengkap ?? username;
    } else if (role.toLowerCase() == 'guru') {
      return guruNamaLengkap ?? username;
    } else {
      return username;
    }
  }
}