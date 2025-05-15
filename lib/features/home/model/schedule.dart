class Schedule {
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final String ruangKelas;
  final int kapasitas;
  final String mapel;
  final String guruPengajar;

  Schedule({
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.ruangKelas,
    required this.kapasitas,
    required this.mapel,
    required this.guruPengajar,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      hari: json['hari'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      ruangKelas: json['ruang_kelas'],
      kapasitas: json['kapasitas'],
      mapel: json['mapel'],
      guruPengajar: json['guru_pengajar'],
    );
  }
} 