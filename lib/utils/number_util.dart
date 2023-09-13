import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:k_chart/extension/string_ext.dart';

class NumberUtil {
  static String formatVol(String n, String decimalSeparator) {
    String stringNumber = n.replaceAll(',', '');

    // Convert number into double to be formatted.
    // Default to zero if unable to do so
    double doubleNumber = double.tryParse(stringNumber) ?? 0;

    // Set number format to use
    NumberFormat numberFormat = NumberFormat.compactCurrency(
      locale: 'en_US',
      symbol: "",
      decimalDigits: 2,
    );

    final formattedNumber = numberFormat.format(doubleNumber);
    if (decimalSeparator == ',') {
      return formattedNumber.replaceAll(".", ",");
    }
    return formattedNumber;
  }

  static String format(String? n, String decimalSeparator, {int? decimal}) {
    String stringNumber = n.toString().replaceAll(',', '');

    if (stringNumber.contains("e")) {
      Decimal decimalNumber = Decimal.tryParse(stringNumber) ?? Decimal.zero;
      stringNumber = decimalNumber.toString();
    }

    final splitDecimal = stringNumber.split(".");
    int mDecimal = 0;

    if (decimal != null) {
      if (splitDecimal.length > 1) {
        if (splitDecimal[1].length <= decimal) {
          mDecimal = splitDecimal[1].removeTrailingZeros.length;
        } else {
          mDecimal = decimal;
        }
      }
    } else {
      if (splitDecimal.length > 1) {
        mDecimal = splitDecimal[1].removeTrailingZeros.length;
      }
    }

    // Convert number into double to be formatted.
    // Default to zero if unable to do so
    double doubleNumber = double.tryParse(stringNumber) ?? 0;

    // Set number format to use
    NumberFormat numberFormat = NumberFormat.currency(
      locale: decimalSeparator == ',' ? 'id_ID' : 'en_US',
      symbol: "",
      decimalDigits: mDecimal,
    );
    String formattedNumber = numberFormat.format(doubleNumber);
    if (formattedNumber.split(decimalSeparator).length > 1) {
      RegExp regex = RegExp(r"([,|.]*0+)(?!.*\d)");
      return formattedNumber.replaceAll(regex, '');
    }
    return formattedNumber;
  }

  static double formatBigDecimal(double value) {
    if (!value.isNegative) {
      if (value < 0.0001) {
        return roundDown(value, 10);
      } else if (value < 0.1) {
        return roundDown(value, 6);
      } else {
        return roundDown(value, 4);
      }
    } else {
      if (value > -0.0001) {
        return roundDown(value, 10);
      } else if (value > -0.1) {
        return roundDown(value, 6);
      } else {
        return roundDown(value, 4);
      }
    }
  }

  static double roundDown(double value, int precision) {
    final isNegative = value.isNegative;
    final mod = pow(10.0, precision);
    final roundDown = (((value.abs() * mod).floor()) / mod);
    return isNegative ? -roundDown : roundDown;
  }

  static int getDecimalLength(double b) {
    String s = b.toString();
    int dotIndex = s.indexOf(".");
    if (dotIndex < 0) {
      return 0;
    } else {
      return s.length - dotIndex - 1;
    }
  }

  static int getMaxDecimalLength(double a, double b, double c, double d) {
    int result = max(getDecimalLength(a), getDecimalLength(b));
    result = max(result, getDecimalLength(c));
    result = max(result, getDecimalLength(d));
    return result;
  }

  static bool checkNotNullOrZero(double? a) {
    if (a == null || a == 0) {
      return false;
    } else if (a.abs().toStringAsFixed(4) == "0.0000") {
      return false;
    } else {
      return true;
    }
  }
}
