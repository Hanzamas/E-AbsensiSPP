class Schedule {
  final String id;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final String mapel;
  final String ruangKelas;
  final String guruPengajar;

  Schedule({
    required this.id,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.mapel,
    required this.ruangKelas,
    required this.guruPengajar,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id']?.toString() ?? '',
      hari: json['hari'] ?? '',
      jamMulai: json['jam_mulai'] ?? '',
      jamSelesai: json['jam_selesai'] ?? '',
      mapel: json['mapel'] ?? '',
      ruangKelas: json['ruang_kelas'] ?? '',
      guruPengajar: json['guru_pengajar'] ?? '',
    );
  }

  // Helper untuk mendapatkan format jam yang rapi
  String get formattedJamMulai => jamMulai.substring(0, 5);
  String get formattedJamSelesai => jamSelesai.substring(0, 5);
  String get formattedWaktu => '$formattedJamMulai - $formattedJamSelesai';
}