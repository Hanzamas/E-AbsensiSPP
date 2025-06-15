// widgets/date_picker_helper.dart
import 'package:flutter/material.dart';

class DatePickerHelper {
  static Future<DateTime?> selectDate({
    required BuildContext context,
    DateTime? currentDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final DateTime today = DateTime.now();
    final DateTime defaultFirstDate = firstDate ?? DateTime(1980);
    final DateTime defaultLastDate = lastDate ?? DateTime(today.year + 1, 12, 31);

    // Pastikan initialDate tidak melebihi lastDate
    DateTime initialDate;
    if (currentDate != null) {
      if (currentDate.isAfter(defaultLastDate)) {
        initialDate = today;
      } else if (currentDate.isBefore(defaultFirstDate)) {
        initialDate = defaultFirstDate;
      } else {
        initialDate = currentDate;
      }
    } else {
      initialDate = today;
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
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month]} ${date.year}';
  }

  static DateTime? parseDateSafely(String dateString) {
    try {
      final DateTime parsedDate = DateTime.parse(dateString);
      final DateTime today = DateTime.now();
      final DateTime maxDate = DateTime(today.year + 1, 12, 31);
      final DateTime minDate = DateTime(1980);

      // Jika tanggal di luar rentang yang wajar, return null
      if (parsedDate.isAfter(maxDate) || parsedDate.isBefore(minDate)) {
        print('Tanggal tidak valid: $dateString. Reset ke null.');
        return null;
      }
      return parsedDate;
    } catch (e) {
      print('Error parsing tanggal: $dateString. Error: $e');
      return null;
    }
  }
}