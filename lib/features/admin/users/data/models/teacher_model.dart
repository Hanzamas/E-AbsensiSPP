class Teacher {
  final int idUsers;
  final String username;
  final String email;
  final String role;
  final String nip;
  final String namaLengkap;
  final String jenisKelamin;
  final String tanggalLahir;
  final String tempatLahir;
  final String alamat;
  final String pendidikanTerakhir;

  Teacher({
    required this.idUsers,
    required this.username,
    required this.email,
    required this.role,
    required this.nip,
    required this.namaLengkap,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.tempatLahir,
    required this.alamat,
    required this.pendidikanTerakhir,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      idUsers: json['id_users'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      nip: json['nip'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? '',
      tanggalLahir: json['tanggal_lahir'] ?? '',
      tempatLahir: json['tempat_lahir'] ?? '',
      alamat: json['alamat'] ?? '',
      pendidikanTerakhir: json['pendidikan_terakhir'] ?? '',
    );
  }
}