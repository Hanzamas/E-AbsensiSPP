import 'package:flutter/material.dart';

class AcademicDatePickerHelper {
  static Future<DateTime?> selectDate({
    required BuildContext context,
    DateTime? currentDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final DateTime today = DateTime.now();
    final DateTime defaultFirstDate = firstDate ?? DateTime(1980);
    final DateTime defaultLastDate = lastDate ?? DateTime(today.year + 5, 12, 31);

    DateTime initialDate;

    // Tentukan tanggal awal yang akan ditampilkan di kalender
    if (currentDate != null) {
      initialDate = currentDate;
    } else {
      // Jika tidak ada tanggal saat ini, gunakan tanggal hari ini
      initialDate = today;
    }

    // Pastikan initialDate tidak pernah lebih awal dari tanggal minimum (firstDate).
    // Jika lebih awal, maka samakan initialDate dengan firstDate.
    if (initialDate.isBefore(defaultFirstDate)) {
      initialDate = defaultFirstDate;
    }

    // Pastikan juga initialDate tidak melebihi tanggal maksimum (lastDate)
    if (initialDate.isAfter(defaultLastDate)) {
      initialDate = defaultLastDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: defaultFirstDate,
      lastDate: defaultLastDate,
    );

    return picked;
  }

  static String formatDateIndonesian(DateTime date) {
    List<String> months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}