class ClassModel {
  final int id;
  final String namaKelas;
  final int kapasitas;
  final int idTahunAjaran;
  final String tahunAjaran;

  ClassModel({
    required this.id,
    required this.namaKelas,
    required this.kapasitas,
    required this.idTahunAjaran,
    required this.tahunAjaran,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] ?? 0,
      namaKelas: json['nama_kelas'] ?? '',
      kapasitas: json['kapasitas'] ?? 0,
      idTahunAjaran: json['id_tahun_ajaran'] ?? 0,
      tahunAjaran: json['tahun_ajaran'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_kelas': namaKelas,
      'kapasitas': kapasitas,
      'id_tahun_ajaran': idTahunAjaran,
      'tahun_ajaran': tahunAjaran,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'nama_kelas': namaKelas,
      'kapasitas': kapasitas,
      'id_tahun_ajaran': idTahunAjaran,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'nama_kelas': namaKelas,
      'kapasitas': kapasitas,
      'id_tahun_ajaran': idTahunAjaran,
    };
  }

  // Helper method untuk menampilkan nama kelas dengan tahun ajaran
  String get displayName => '$namaKelas ($tahunAjaran)';
} 