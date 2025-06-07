class ScheduleModel {
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final String ruangKelas;
  final int kapasitas;
  final String mapel;
  final String guruPengajar;

  ScheduleModel({
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.ruangKelas,
    required this.kapasitas,
    required this.mapel,
    required this.guruPengajar,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      hari: json['hari'] ?? '',
      jamMulai: json['jam_mulai'] ?? '',
      jamSelesai: json['jam_selesai'] ?? '',
      ruangKelas: json['ruang_kelas'] ?? '',
      kapasitas: json['kapasitas'] ?? 0,
      mapel: json['mapel'] ?? '',
      guruPengajar: json['guru_pengajar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hari': hari,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'ruang_kelas': ruangKelas,
      'kapasitas': kapasitas,
      'mapel': mapel,
      'guru_pengajar': guruPengajar,
    };
  }

  @override
  String toString() {
    return 'ScheduleModel(hari: $hari, mapel: $mapel, jam: $jamMulai-$jamSelesai)';
  }
}