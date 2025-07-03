import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k_chart/extension/string_ext.dart';

export '../chart_style.dart';

abstract class BaseChartRenderer<T> {
  double maxValue, minValue;
  late double scaleY;
  double topPadding;
  Rect chartRect;
  int fixedLength;
  Paint chartPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 1.0
    ..color = Colors.red;
  Paint gridPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 0.5
    ..color = Color(0xff4c5c74);

  BaseChartRenderer({
    required this.chartRect,
    required this.maxValue,
    required this.minValue,
    required this.topPadding,
    required this.fixedLength,
    required Color gridColor,
  }) {
    if (maxValue == minValue) {
      maxValue *= 1.5;
      minValue /= 2;
    }
    scaleY = chartRect.height / (maxValue - minValue);
    gridPaint.color = gridColor;
    // print("maxValue=====" + maxValue.toString() + "====minValue===" + minValue.toString() + "==scaleY==" + scaleY.toString());
  }

  double getY(double y) => (maxValue - y) * scaleY + chartRect.top;

  String format(String? n, String decimalSeparator, {int? decimal}) {
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

  void drawGrid(Canvas canvas, int gridRows, int gridColumns);

  void drawText(Canvas canvas, T data, double x);

  void drawVerticalText(canvas, textStyle, int gridRows);

  // void drawBuy(T lastPoint, T curPoint, double lastX, double curX, Size size,
  //     Canvas canvas, MarkerStyle markerStyle);

  // void drawSell(T lastPoint, T curPoint, double lastX, double curX, Size size,
  //     Canvas canvas, MarkerStyle markerStyle);

  void drawChart(T lastPoint, T curPoint, double lastX, double curX, Size size,
      Canvas canvas);

  void drawLine(double? lastPrice, double? curPrice, Canvas canvas,
      double lastX, double curX, Color color) {
    if (lastPrice == null || curPrice == null) {
      return;
    }
    //("lasePrice==" + lastPrice.toString() + "==curPrice==" + curPrice.toString());
    double lastY = getY(lastPrice);
    double curY = getY(curPrice);
    //print("lastX-----==" + lastX.toString() + "==lastY==" + lastY.toString() + "==curX==" + curX.toString() + "==curY==" + curY.toString());
    canvas.drawLine(
        Offset(lastX, lastY), Offset(curX, curY), chartPaint..color = color);
  }

  TextStyle getTextStyle(Color color) {
    return TextStyle(fontSize: 10.0, color: color);
  }
}
