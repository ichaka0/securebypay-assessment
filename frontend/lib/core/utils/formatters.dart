import 'package:intl/intl.dart';

abstract final class Formatters {
  static final _currency = NumberFormat.currency(
    locale: 'en_US',
    symbol: '₦',
    decimalDigits: 2,
  );
  static final _currencyWhole = NumberFormat.currency(
    locale: 'en_US',
    symbol: '₦',
    decimalDigits: 0,
  );
  static final _compact = NumberFormat.compact(locale: 'en');

  /// `3000000.28` -> `₦3,000,000.28`
  static String currency(num value) => _currency.format(value);

  /// `3000` -> `₦3,000` (used on shipment cards).
  static String currencyWhole(num value) => _currencyWhole.format(value);

  /// `120000` -> `120K` (chart axis labels).
  static String compact(num value) => _compact.format(value);

  static String hours(int hours) => hours == 1 ? '1 hour' : '$hours hours';
}
