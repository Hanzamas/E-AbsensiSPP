class TeacherProfile {
  final int id;
  final int idUsers;
  final String nip;
  final String namaLengkap;
  final String jenisKelamin;
  final String tanggalLahir;
  final String tempatLahir;
  final String alamat;
  final String pendidikanTerakhir;

  static const List<String> intFields = [];
  static const List<String> stringFields = ['nip', 'nama_lengkap', 'jenis_kelamin', 'tanggal_lahir', 'tempat_lahir', 'alamat', 'pendidikan_terakhir'];

  TeacherProfile({
    required this.id,
    required this.idUsers,
    required this.nip,
    required this.namaLengkap,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.tempatLahir,
    required this.alamat,
    required this.pendidikanTerakhir,
  });

  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    String formatTanggalLahir(String? tanggal) {
      if (tanggal == null || tanggal.isEmpty) return '';
      // Handle ISO date format
      if (tanggal.contains('T')) {
        return tanggal.split('T')[0];
      }
      return tanggal;
    }

    return TeacherProfile(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      idUsers: json['id_users'] is int ? json['id_users'] : int.tryParse(json['id_users'].toString()) ?? 0,
      nip: json['nip']?.toString() ?? '',
      namaLengkap: json['nama_lengkap']?.toString() ?? '',
      jenisKelamin: json['jenis_kelamin']?.toString() ?? '',
      tanggalLahir: formatTanggalLahir(json['tanggal_lahir']?.toString()),
      tempatLahir: json['tempat_lahir']?.toString() ?? '',
      alamat: json['alamat']?.toString() ?? '',
      pendidikanTerakhir: json['pendidikan_terakhir']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'id_users': idUsers,
    'nip': nip,
    'nama_lengkap': namaLengkap,
    'jenis_kelamin': jenisKelamin,
    'tanggal_lahir': tanggalLahir,
    'tempat_lahir': tempatLahir,
    'alamat': alamat,
    'pendidikan_terakhir': pendidikanTerakhir,
  };
}