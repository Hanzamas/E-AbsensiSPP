// lib/core/utils/currency_util.dart
import 'package:intl/intl.dart';

class CurrencyUtil {
  static String formatToIdr(num number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }
}