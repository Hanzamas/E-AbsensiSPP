class AttendanceModel {
  final int? absensiId;
  final String? namaSiswa;
  final String? nis;
  final String? namaKelas;
  final DateTime tanggal;
  final String namaMapel;
  final String jamMulai;
  final String jamSelesai;
  final String? waktuScan;
  final String status;
  final String? keterangan;
  final int? valid;

  AttendanceModel({
    this.absensiId,
    this.namaSiswa,
    this.nis,
    this.namaKelas,
    required this.tanggal,
    required this.namaMapel,
    required this.jamMulai,
    required this.jamSelesai,
    this.waktuScan,
    required this.status,
    this.keterangan,
    this.valid,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      absensiId: json['absensi_id'] as int?,
      namaSiswa: json['nama_siswa'] as String?,
      nis: json['nis'] as String?,
      namaKelas: json['nama_kelas'] as String?,
      tanggal: DateTime.parse(json['tanggal'] as String),
      namaMapel: json['nama_mapel'] as String,
      jamMulai: json['jam_mulai'] as String,
      jamSelesai: json['jam_selesai'] as String,
      waktuScan: json['waktu_scan'] as String?,
      status: json['status'] as String,
      keterangan: json['keterangan'] as String?,
      valid: json['valid'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'absensi_id': absensiId,
      'nama_siswa': namaSiswa,
      'nis': nis,
      'nama_kelas': namaKelas,
      'tanggal': tanggal.toIso8601String(),
      'nama_mapel': namaMapel,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'waktu_scan': waktuScan,
      'status': status,
      'keterangan': keterangan,
      'valid': valid,
    };
  }

  @override
  String toString() {
    return 'AttendanceModel(absensiId: $absensiId, namaMapel: $namaMapel, status: $status, tanggal: $tanggal)';
  }
}