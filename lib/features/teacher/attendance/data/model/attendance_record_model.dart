class AttendanceRecordModel {
  final int idAbsensi;
  final String namaMapel;
  final String namaKelas;
  final DateTime tanggal;
  final String jamMulai;
  final String jamSelesai;
  final String nis;
  final String namaSiswa;
  final String status;
  final String? keterangan;
  final String? waktuScan;

  AttendanceRecordModel({
    required this.idAbsensi,
    required this.namaMapel,
    required this.namaKelas,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.nis,
    required this.namaSiswa,
    required this.status,
    this.keterangan,
    this.waktuScan,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      idAbsensi: json['id_absensi'] ?? 0,
      namaMapel: json['nama_mapel'] ?? '',
      namaKelas: json['nama_kelas'] ?? '',
      tanggal: json['tanggal'] != null 
          ? DateTime.parse(json['tanggal']) 
          : DateTime.now(),
      jamMulai: json['jam_mulai'] ?? '00:00:00',
      jamSelesai: json['jam_selesai'] ?? '00:00:00',
      nis: json['nis'] ?? '',
      namaSiswa: json['nama_siswa'] ?? '',
      status: json['status'] ?? '',
      keterangan: json['keterangan'],
      waktuScan: json['waktu_scan'],
    );
  }

  // Helper methods
  String get formattedDate => '${tanggal.day.toString().padLeft(2, '0')}/${tanggal.month.toString().padLeft(2, '0')}/${tanggal.year}';
  
  String get formattedTime => '${_formatTime(jamMulai)} - ${_formatTime(jamSelesai)}';
  
  String get formattedWaktuScan {
    if (waktuScan == null) return '-';
    try {
      final time = DateTime.parse(waktuScan!);
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return waktuScan!;
    }
  }

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

  String get studentInfo => '$namaSiswa ($nis)';
  String get subjectInfo => '$namaMapel - $namaKelas';
  
  bool get isPresent => status.toLowerCase() == 'hadir';
  bool get isAbsent => status.toLowerCase() == 'alpha';
  bool get isSick => status.toLowerCase() == 'sakit';
  bool get isPermission => status.toLowerCase() == 'izin';
  bool get hasScanned => waktuScan != null;
  
  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'hadir': return 'Hadir';
      case 'alpha': return 'Alpha';
      case 'sakit': return 'Sakit';
      case 'izin': return 'Izin';
      default: return status;
    }
  }

  // Update payload for API
  Map<String, dynamic> toUpdatePayload(String newStatus, String? newKeterangan) {
    return {
      'status': newStatus,
      'keterangan': newKeterangan,
    };
  }
}