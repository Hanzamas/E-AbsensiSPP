class AttendanceRecord {
  final String status;
  
  /// Model untuk merepresentasikan satu entri data absensi dari API.
  /// Berdasarkan dokumentasi, field yang paling penting untuk kalkulasi
  /// adalah 'status'.
  AttendanceRecord({
    required this.status,
    // Anda bisa menambahkan field lain di sini jika API mengembalikannya
    // contoh: final String studentName;
  });

  /// Factory constructor untuk membuat instance AttendanceRecord dari JSON Map.
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    // Pastikan key 'status' sesuai dengan yang dikirim oleh API Anda.
    return AttendanceRecord(
      status: json['status'] ?? '', 
    );
  }
}