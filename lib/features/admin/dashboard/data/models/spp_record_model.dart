class SppRecord {
  /// Field ini diasumsikan bernama 'status_bill' dari API.
  /// Bisa juga 'status' atau 'payment_status'. Sesuaikan di sini jika berbeda.
  final String statusBill;

  SppRecord({
    required this.statusBill,
    // Anda bisa menambahkan field lain di sini jika API mengembalikannya
    // contoh: final String studentName;
  });

  /// Factory constructor untuk membuat instance SppRecord dari JSON Map.
  factory SppRecord.fromJson(Map<String, dynamic> json) {
    // API mungkin mengembalikan 'status_bill' atau 'status'.
    // Kode ini mencoba keduanya untuk fleksibilitas.
    return SppRecord(
      statusBill: json['status_bill'] ?? json['status'] ?? '', 
    );
  }
}