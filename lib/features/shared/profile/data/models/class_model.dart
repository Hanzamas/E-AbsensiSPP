class ClassModel {
  final int id;
  final int idTahunAjaran;
  final String namaKelas;
  final String tahunAjaran;
  final int kapasitas;
  final String? createdAt;
  final String? updatedAt;

  ClassModel({
    required this.id,
    required this.idTahunAjaran,
    required this.namaKelas,
    required this.tahunAjaran,
    required this.kapasitas,
    this.createdAt,
    this.updatedAt,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'],
      idTahunAjaran: json['id_tahun_ajaran'],
      namaKelas: json['nama_kelas'],
      tahunAjaran: json['tahun_ajaran'],
      kapasitas: json['kapasitas'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_tahun_ajaran': idTahunAjaran,
      'nama_kelas': namaKelas,
      'tahun_ajaran': tahunAjaran,
      'kapasitas': kapasitas,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper method untuk menampilkan nama kelas dengan tahun ajaran
  String get displayName => '$namaKelas ($tahunAjaran)';
} 