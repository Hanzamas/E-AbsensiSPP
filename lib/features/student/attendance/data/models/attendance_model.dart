class AttendanceModel {
  final int? absensiId;
  final DateTime tanggal;
  final String namaMapel;
  final String status;
  final String? jam_mulai;
  final String? jam_selesai;
  final String? waktuScan;

  AttendanceModel({
    this.absensiId,
    required this.tanggal,
    required this.namaMapel,
    required this.status,
    this.waktuScan,
    this.jam_mulai,
    this.jam_selesai,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      absensiId: json['absensi_id'] as int?,
      tanggal: DateTime.parse(json['tanggal'] as String),
      namaMapel: json['nama_mapel'] as String,
      status: json['status'] as String,
      waktuScan: json['waktu_scan'] != null 
          ? (json['waktu_scan'] as String) 
          : null,
      jam_mulai: json['jam_mulai'] as String?,
      jam_selesai: json['jam_selesai'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'absensi_id': absensiId,
      'tanggal': tanggal.toIso8601String().split('Z')[0],
      'nama_mapel': namaMapel,
      'status': status,
      'waktu_scan': waktuScan,
      'jam_mulai': jam_mulai,
      'jam_selesai': jam_selesai,
    };
  }
}
