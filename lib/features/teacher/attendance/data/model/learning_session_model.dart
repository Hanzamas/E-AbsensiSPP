class LearningSessionModel {
  final int idSesi;
  final int idPengajaran;
  final String date;
  final String qrToken;
  final String jamMulai;
  final String jamSelesai;

  LearningSessionModel({
    required this.idSesi,
    required this.idPengajaran,
    required this.date,
    required this.qrToken,
    required this.jamMulai,
    required this.jamSelesai,
  });

  factory LearningSessionModel.fromJson(Map<String, dynamic> json) {
    return LearningSessionModel(
      idSesi: json['id_sesi'] ?? 0,
      idPengajaran: json['id_pengajaran'] ?? 0,
      date: json['date'] ?? '',
      qrToken: json['qr_token'] ?? '',
      jamMulai: json['jam_mulai'] ?? '00:00:00',
      jamSelesai: json['jam_selesai'] ?? '00:00:00',
    );
  }

  String get formattedTime => '${_formatTime(jamMulai)} - ${_formatTime(jamSelesai)}';
  String get displayQRToken => qrToken.isNotEmpty ? qrToken : 'QR Token tidak tersedia';
  
  String _formatTime(String time) {
    try {
      if (time.length >= 5) {
        return time.substring(0, 5);
      }
      return time;
    } catch (e) {
      return '00:00';
    }
  }

  String get formattedDate {
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  bool get isToday {
    try {
      final sessionDate = DateTime.parse(date);
      final today = DateTime.now();
      return sessionDate.year == today.year &&
             sessionDate.month == today.month &&
             sessionDate.day == today.day;
    } catch (e) {
      return false;
    }
  }
}