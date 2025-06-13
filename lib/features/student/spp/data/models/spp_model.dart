class SppBillModel {
  final int id;
  final int idSiswa;
  final String bulan;
  final String tahun;
  final double nominal;
  final double denda;
  final DateTime dueDate;
  final String status;

  SppBillModel({
    required this.id,
    required this.idSiswa,
    required this.bulan,
    required this.tahun,
    required this.nominal,
    required this.denda,
    required this.dueDate,
    required this.status,
  });

  factory SppBillModel.fromJson(Map<String, dynamic> json) {
    return SppBillModel(
      id: json['id'] ?? 0,
      idSiswa: json['id_siswa'] ?? 0,
      bulan: json['bulan'] ?? '',
      tahun: json['tahun'] ?? '',
      nominal: double.parse(json['nominal']?.toString() ?? '0'),
      denda: double.parse(json['denda']?.toString() ?? '0'),
      dueDate: DateTime.parse(json['due_date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? '',
    );
  }

  double get totalAmount => nominal + denda;
  
  String get monthName {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final monthIndex = int.tryParse(bulan) ?? 0;
    return monthIndex > 0 && monthIndex < months.length ? months[monthIndex] : bulan;
  }
}

class QrisPaymentModel {
  final String qrisId;
  final String referenceId;
  final double amount;
  final String qrString;
  final DateTime expiresAt;
  final String status;
  final QrisMetadata metadata;

  QrisPaymentModel({
    required this.qrisId,
    required this.referenceId,
    required this.amount,
    required this.qrString,
    required this.expiresAt,
    required this.status,
    required this.metadata,
  });

  factory QrisPaymentModel.fromJson(Map<String, dynamic> json) {
    return QrisPaymentModel(
      qrisId: json['qris_id'] ?? '',
      referenceId: json['reference_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      qrString: json['qr_string'] ?? '',
      expiresAt: DateTime.parse(json['expires_at'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? '',
      metadata: QrisMetadata.fromJson(json['metadata'] ?? {}),
    );
  }
}

class QrisMetadata {
  final int billId;
  final String month;
  final int studentId;
  final String year;

  QrisMetadata({
    required this.billId,
    required this.month,
    required this.studentId,
    required this.year,
  });

  factory QrisMetadata.fromJson(Map<String, dynamic> json) {
    return QrisMetadata(
      billId: json['bill_id'] ?? 0,
      month: json['month'] ?? '',
      studentId: json['student_id'] ?? 0,
      year: json['year'] ?? '',
    );
  }
}

class PaymentHistoryModel {
  final int idPembayaran;
  final String bulan;
  final String tahun;
  final double totalBayar;
  final String metodeBayar;
  final String status;
  final DateTime tanggalBayar;
  final int idTagihan;
  final String referenceId;

  PaymentHistoryModel({
    required this.idPembayaran,
    required this.bulan,
    required this.tahun,
    required this.totalBayar,
    required this.metodeBayar,
    required this.status,
    required this.tanggalBayar,
    required this.idTagihan,
    required this.referenceId,
  });

  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryModel(
      idPembayaran: json['id_pembayaran'] ?? 0,
      bulan: json['bulan'] ?? '',
      tahun: json['tahun'] ?? '',
      totalBayar: double.parse(json['total_bayar']?.toString() ?? '0'),
      metodeBayar: json['metode_bayar'] ?? '',
      status: json['status'] ?? '',
      tanggalBayar: DateTime.parse(json['tanggal_bayar'] ?? DateTime.now().toIso8601String()),
      idTagihan: json['id_tagihan'] ?? 0,
      referenceId: json['reference_id'] ?? '',
    );
  }

  String get monthName {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final monthIndex = int.tryParse(bulan) ?? 0;
    return monthIndex > 0 && monthIndex < months.length ? months[monthIndex] : bulan;
  }
}