class StudentProfile {
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
  final int? waWali;

  static const List<String> intFields = ['id_kelas', 'wa_wali'];
  static const List<String> stringFields = ['nis', 'nama_lengkap', 'jenis_kelamin', 'tanggal_lahir', 'tempat_lahir', 'alamat', 'wali'];

  StudentProfile({
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
    this.waWali,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    String formatTanggalLahir(String? tanggal) {
      if (tanggal == null || tanggal.isEmpty) return '';
      // Handle ISO date format
      if (tanggal.contains('T')) {
        return tanggal.split('T')[0];
      }
      return tanggal;
    }

    return StudentProfile(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      idUsers: json['id_users'] is int ? json['id_users'] : int.tryParse(json['id_users'].toString()) ?? 0,
      idKelas: json['id_kelas'] is int ? json['id_kelas'] : int.tryParse(json['id_kelas'].toString()) ?? 0,
      nis: json['nis']?.toString() ?? '',
      namaLengkap: json['nama_lengkap']?.toString() ?? '',
      jenisKelamin: json['jenis_kelamin']?.toString() ?? '',
      tanggalLahir: formatTanggalLahir(json['tanggal_lahir']?.toString()),
      tempatLahir: json['tempat_lahir']?.toString() ?? '',
      alamat: json['alamat']?.toString() ?? '',
      wali: json['wali']?.toString() ?? '',
      waWali: json['wa_wali'] is int 
          ? json['wa_wali'] 
          : (json['wa_wali'] != null ? int.tryParse(json['wa_wali'].toString()) : null),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'id_users': idUsers,
    'id_kelas': idKelas,
    'nis': nis,
    'nama_lengkap': namaLengkap,
    'jenis_kelamin': jenisKelamin,
    'tanggal_lahir': tanggalLahir,
    'tempat_lahir': tempatLahir,
    'alamat': alamat,
    'wali': wali,
    'wa_wali': waWali,
  };
}