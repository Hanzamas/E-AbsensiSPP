import 'package:intl/intl.dart';

class FormatUtil {
  /// Format angka ke Rupiah (Rp)
  static String toIdr(num number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  /// Format tanggal ke dd MMMM yyyy (contoh: 01 Januari 2023)
  static String date(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  /// Format waktu ke HH:mm
  static String time(DateTime time) {
    return DateFormat('HH:mm', 'id_ID').format(time);
  }
} 