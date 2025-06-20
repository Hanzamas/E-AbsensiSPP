// admin/akademik/data/models/teaching_model.dart

class TeachingModel {
  final int id;
  final int idGuru;
  final int idMapel;
  final int idKelas;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final String namaGuru;
  final String namaMapel;
  final String namaKelas;
  final String tahunAjaran;

  TeachingModel({
    required this.id,
    required this.idGuru,
    required this.idMapel,
    required this.idKelas,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.namaGuru,
    required this.namaMapel,
    required this.namaKelas,
    required this.tahunAjaran,
  });

  factory TeachingModel.fromJson(Map<String, dynamic> json) {
    return TeachingModel(
      id: json['id'] ?? 0,
      idGuru: json['id_guru'] ?? 0,
      idMapel: json['id_mapel'] ?? 0,
      idKelas: json['id_kelas'] ?? 0,
      hari: json['hari'] ?? '',
      jamMulai: json['jam_mulai'] ?? '',
      jamSelesai: json['jam_selesai'] ?? '',
      namaGuru: json['nama_guru'] ?? 'N/A',
      namaMapel: json['nama_mapel'] ?? 'N/A',
      namaKelas: json['nama_kelas'] ?? 'N/A',
      tahunAjaran: json['tahun_ajaran'] ?? 'N/A',
    );
  }
}