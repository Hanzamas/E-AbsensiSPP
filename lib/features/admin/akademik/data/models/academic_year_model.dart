import 'package:intl/intl.dart';

class AcademicYearModel {
  final int? id;
  final String nama;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AcademicYearModel({
    this.id,
    required this.nama,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    this.createdAt,
    this.updatedAt,
  });

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearModel(
      id: json['id'],
      nama: json['nama'],
      tanggalMulai: DateTime.parse(json['tanggal_mulai']),
      tanggalSelesai: DateTime.parse(json['tanggal_selesai']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'tanggal_mulai': DateFormat('yyyy-MM-dd').format(tanggalMulai),
      'tanggal_selesai': DateFormat('yyyy-MM-dd').format(tanggalSelesai),
    };
  }
}