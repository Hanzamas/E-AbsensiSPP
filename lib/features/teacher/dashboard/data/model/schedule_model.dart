import 'package:flutter/material.dart';

class ScheduleModel {
  final int id;
  final int idGuru;
  final int idMapel;
  final int idKelas;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String namaGuru;
  final String namaMapel;
  final String namaKelas;
  final String tahunAjaran;

  ScheduleModel({
    required this.id,
    required this.idGuru,
    required this.idMapel,
    required this.idKelas,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.createdAt,
    required this.updatedAt,
    required this.namaGuru,
    required this.namaMapel,
    required this.namaKelas,
    required this.tahunAjaran,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] ?? 0,
      idGuru: json['id_guru'] ?? 0,
      idMapel: json['id_mapel'] ?? 0,
      idKelas: json['id_kelas'] ?? 0,
      hari: json['hari'] ?? '',
      jamMulai: json['jam_mulai'] ?? '00:00:00',
      jamSelesai: json['jam_selesai'] ?? '00:00:00',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      namaGuru: json['nama_guru'] ?? '',
      namaMapel: json['nama_mapel'] ?? '',
      namaKelas: json['nama_kelas'] ?? '',
      tahunAjaran: json['tahun_ajaran'] ?? '',
    );
  }

  String get formattedTime => '${_formatTime(jamMulai)} - ${_formatTime(jamSelesai)}';
  String get classInfo => '$namaMapel - $namaKelas';
  
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
  
  bool get isToday {
    final now = DateTime.now();
    final dayNames = ['minggu', 'senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu'];
    final today = dayNames[now.weekday % 7];
    return hari.toLowerCase() == today.toLowerCase();
  }

  bool get isNow {
    if (!isToday) return false;
    
    try {
      final now = TimeOfDay.now();
      final startTime = TimeOfDay(
        hour: int.parse(jamMulai.split(':')[0]),
        minute: int.parse(jamMulai.split(':')[1]),
      );
      final endTime = TimeOfDay(
        hour: int.parse(jamSelesai.split(':')[0]),
        minute: int.parse(jamSelesai.split(':')[1]),
      );
      
      final nowMinutes = now.hour * 60 + now.minute;
      final startMinutes = startTime.hour * 60 + startTime.minute;
      final endMinutes = endTime.hour * 60 + endTime.minute;
      
      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    } catch (e) {
      return false;
    }
  }
}