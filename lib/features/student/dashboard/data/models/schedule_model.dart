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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hari': hari,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'mapel': mapel,
      'ruang_kelas': ruangKelas,
      'guru_pengajar': guruPengajar,
    };
  }

  // Helper untuk format waktu
  String get formattedJamMulai => jamMulai.length >= 5 ? jamMulai.substring(0, 5) : jamMulai;
  String get formattedJamSelesai => jamSelesai.length >= 5 ? jamSelesai.substring(0, 5) : jamSelesai;
  String get formattedWaktu => '$formattedJamMulai - $formattedJamSelesai';
  
  // Helper untuk cek jadwal sedang aktif
  bool isCurrentlyActive() {
    try {
      final now = DateTime.now();
      final dayIndex = now.weekday - 1; // 0 = Monday
      final daysOfWeek = ['senin', 'selasa', 'rabu', 'kamis', 'jum\'at', 'sabtu', 'minggu'];
      
      // Jika bukan hari yang sama, jadwal tidak aktif
      if (hari.toLowerCase() != daysOfWeek[dayIndex]) {
        return false;
      }
      
      // Format waktu sekarang untuk perbandingan
      final currentHour = now.hour.toString().padLeft(2, '0');
      final currentMinute = now.minute.toString().padLeft(2, '0');
      final currentTime = '$currentHour:$currentMinute';
      
      // Check if current time is between jamMulai and jamSelesai
      return currentTime.compareTo(formattedJamMulai) >= 0 && 
             currentTime.compareTo(formattedJamSelesai) <= 0;
    } catch (e) {
      return false;
    }
  }
}