class Student {
  final int id;
  final int idUsers;
  final int idKelas;
  final String nis;
  final String namaLengkap;
  final String jenisKelamin;
  final String tanggalLahir;
  final String tempatLahir;
  final String alamat;
  final String wali;
  final String waWali;
  final String createdAt;
  final String updatedAt;
  final String username;
  final String namaKelas;
  final String email;

  Student({
    required this.id,
    required this.idUsers,
    required this.idKelas,
    required this.nis,
    required this.namaLengkap,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.tempatLahir,
    required this.alamat,
    required this.wali,
    required this.waWali,
    required this.createdAt,
    required this.updatedAt,
    required this.username,
    required this.namaKelas,
    required this.email,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? 0,
      idUsers: json['id_users'] ?? 0,
      idKelas: json['id_kelas'] ?? 0,
      nis: json['nis'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? '',
      tanggalLahir: json['tanggal_lahir'] ?? '',
      tempatLahir: json['tempat_lahir'] ?? '',
      alamat: json['alamat'] ?? '',
      wali: json['wali'] ?? '',
      waWali: json['wa_wali'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      username: json['username'] ?? '',
      namaKelas: json['nama_kelas'] ?? '',
      email: json['email'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nis': nis,
      'nama_lengkap': namaLengkap,
      'jenis_kelamin': jenisKelamin,
      'tanggal_lahir': tanggalLahir,
      'tempat_lahir': tempatLahir,
      'alamat': alamat,
      'wali': wali,
      'wa_wali': waWali,
      'id_kelas': idKelas,
      'username': username, // Jika diperlukan
      'email': email, // Jika diperlukan
    };
  }
}