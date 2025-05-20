// lib/core/utils/date_util.dart
import 'package:intl/intl.dart';

class DateUtil {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm', 'id_ID').format(time);
  }
}