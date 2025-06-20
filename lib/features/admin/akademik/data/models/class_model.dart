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
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,

      // Handle both 'nama_kelas' and 'nama' from API
      namaKelas:
          json['nama_kelas']?.toString() ?? json['nama']?.toString() ?? '',

      kapasitas: int.tryParse(json['kapasitas']?.toString() ?? '0') ?? 0,
      idTahunAjaran:
          int.tryParse(json['id_tahun_ajaran']?.toString() ?? '0') ?? 0,
      tahunAjaran: json['tahun_ajaran']?.toString() ?? '',
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

  // --- PERBAIKAN DI SINI ---
  // Menyesuaikan dengan body request API yang meminta key 'nama'
  Map<String, dynamic> toCreateJson() {
    return {
      'nama': namaKelas, // Diganti dari 'nama_kelas' menjadi 'nama'
      'kapasitas': kapasitas,
      'id_tahun_ajaran': idTahunAjaran,
    };
  }

  // --- PERBAIKAN DI SINI ---
  // Menyesuaikan dengan body request API yang meminta key 'nama'
  Map<String, dynamic> toUpdateJson() {
    return {
      'nama': namaKelas, // Diganti dari 'nama_kelas' menjadi 'nama'
      'kapasitas': kapasitas,
      'id_tahun_ajaran': idTahunAjaran,
    };
  }
  // --- AKHIR PERBAIKAN ---

  // Helper method untuk menampilkan nama kelas dengan tahun ajaran
  String get displayName => '$namaKelas ($tahunAjaran)';
}
