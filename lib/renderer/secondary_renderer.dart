import 'package:flutter/material.dart';
import 'package:k_chart/flutter_k_chart.dart';

class SecondaryRenderer extends BaseChartRenderer<MACDEntity> {
  late double mMACDWidth;
  SecondaryState state;
  final ChartStyle chartStyle;
  final ChartColors chartColors;
  final String decimalSeparator;

  SecondaryRenderer(
    Rect mainRect,
    double maxValue,
    double minValue,
    double topPadding,
    this.state,
    int fixedLength,
    this.chartStyle,
    this.chartColors,
    this.decimalSeparator,
  ) : super(
          chartRect: mainRect,
          maxValue: maxValue,
          minValue: minValue,
          topPadding: topPadding,
          fixedLength: fixedLength,
          gridColor: chartColors.gridColor,
        ) {
    mMACDWidth = this.chartStyle.macdWidth;
  }

  @override
  void drawChart(MACDEntity lastPoint, MACDEntity curPoint, double lastX,
      double curX, Size size, Canvas canvas) {
    switch (state) {
      case SecondaryState.MACD:
        drawMACD(curPoint, canvas, curX, lastPoint, lastX);
        break;
      case SecondaryState.KDJ:
        drawLine(lastPoint.k, curPoint.k, canvas, lastX, curX,
            this.chartColors.kColor);
        drawLine(lastPoint.d, curPoint.d, canvas, lastX, curX,
            this.chartColors.dColor);
        drawLine(lastPoint.j, curPoint.j, canvas, lastX, curX,
            this.chartColors.jColor);
        break;
      case SecondaryState.RSI:
        drawLine(lastPoint.rsi, curPoint.rsi, canvas, lastX, curX,
            this.chartColors.rsiColor);
        break;
      case SecondaryState.WR:
        drawLine(lastPoint.r, curPoint.r, canvas, lastX, curX,
            this.chartColors.rsiColor);
        break;
      case SecondaryState.CCI:
        drawLine(lastPoint.cci, curPoint.cci, canvas, lastX, curX,
            this.chartColors.rsiColor);
        break;
      default:
        break;
    }
  }

  void drawMACD(MACDEntity curPoint, Canvas canvas, double curX,
      MACDEntity lastPoint, double lastX) {
    final macd = curPoint.macd ?? 0;
    double macdY = getY(macd);
    double r = mMACDWidth / 2;
    double zeroy = getY(0);
    if (macd > 0) {
      canvas.drawRect(Rect.fromLTRB(curX - r, macdY, curX + r, zeroy),
          chartPaint..color = this.chartColors.upColor);
    } else {
      canvas.drawRect(Rect.fromLTRB(curX - r, zeroy, curX + r, macdY),
          chartPaint..color = this.chartColors.dnColor);
    }
    if (lastPoint.dif != 0) {
      drawLine(lastPoint.dif, curPoint.dif, canvas, lastX, curX,
          this.chartColors.difColor);
    }
    if (lastPoint.dea != 0) {
      drawLine(lastPoint.dea, curPoint.dea, canvas, lastX, curX,
          this.chartColors.deaColor);
    }
  }

  @override
  void drawText(Canvas canvas, MACDEntity data, double x) {
    List<TextSpan>? children;
    switch (state) {
      case SecondaryState.MACD:
        children = [
          TextSpan(
              text: "MACD(12,26,9)  ",
              style: getTextStyle(this.chartColors.macdColor)),
          if (data.dif != 0)
            TextSpan(
                text:
                    "DIF: ${format(NumberUtil.formatBigDecimal(data.dif ?? 0).toString(), decimalSeparator)}  ",
                style: getTextStyle(this.chartColors.difColor)),
          if (data.dea != 0)
            TextSpan(
                text:
                    "DEA: ${format(NumberUtil.formatBigDecimal(data.dea ?? 0).toString(), decimalSeparator)}  ",
                style: getTextStyle(this.chartColors.deaColor)),
          if (data.macd != 0)
            TextSpan(
                text:
                    "MACD: ${format(NumberUtil.formatBigDecimal(data.macd ?? 0).toString(), decimalSeparator)}  ",
                style: getTextStyle(this.chartColors.macdColor)),
        ];
        break;
      case SecondaryState.KDJ:
        children = [
          TextSpan(
              text: "KDJ(9,1,3)    ",
              style: getTextStyle(this.chartColors.defaultTextColor)),
          if (data.macd != 0)
            TextSpan(
                text: "K: ${format(data.k?.toString(), decimalSeparator)}    ",
                style: getTextStyle(this.chartColors.kColor)),
          if (data.dif != 0)
            TextSpan(
                text: "D: ${format(data.d?.toString(), decimalSeparator)}    ",
                style: getTextStyle(this.chartColors.dColor)),
          if (data.dea != 0)
            TextSpan(
                text: "J: ${format(data.j?.toString(), decimalSeparator)}    ",
                style: getTextStyle(this.chartColors.jColor)),
        ];
        break;
      case SecondaryState.RSI:
        children = [
          TextSpan(
              text:
                  "RSI(14): ${format(NumberUtil.formatBigDecimal(data.rsi ?? 0).toString(), decimalSeparator)}    ",
              style: getTextStyle(this.chartColors.rsiColor)),
        ];
        break;
      case SecondaryState.WR:
        children = [
          TextSpan(
              text:
                  "WR(14): ${format(data.r?.toString(), decimalSeparator)}    ",
              style: getTextStyle(this.chartColors.rsiColor)),
        ];
        break;
      case SecondaryState.CCI:
        children = [
          TextSpan(
              text:
                  "CCI(14): ${format(data.cci?.toString(), decimalSeparator)}    ",
              style: getTextStyle(this.chartColors.rsiColor)),
        ];
        break;
      default:
        break;
    }
    TextPainter tp = TextPainter(
        text: TextSpan(children: children ?? []),
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  @override
  void drawVerticalText(canvas, textStyle, int gridRows) {
    TextPainter maxTp = TextPainter(
        text: TextSpan(
            text:
                "${format(NumberUtil.formatBigDecimal(maxValue).toString(), decimalSeparator)}",
            style: textStyle),
        textDirection: TextDirection.ltr);
    maxTp.layout();
    TextPainter minTp = TextPainter(
        text: TextSpan(
            text:
                "${format(NumberUtil.formatBigDecimal(minValue).toString(), decimalSeparator)}",
            style: textStyle),
        textDirection: TextDirection.ltr);
    minTp.layout();

    maxTp.paint(canvas,
        Offset(chartRect.width - maxTp.width, chartRect.top - topPadding));
    minTp.paint(canvas,
        Offset(chartRect.width - minTp.width, chartRect.bottom - minTp.height));
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    canvas.drawLine(Offset(0, chartRect.top),
        Offset(chartRect.width, chartRect.top), gridPaint);
    canvas.drawLine(Offset(0, chartRect.bottom),
        Offset(chartRect.width, chartRect.bottom), gridPaint);
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      //mSecondaryRect垂直线
      canvas.drawLine(Offset(columnSpace * i, chartRect.top - topPadding),
          Offset(columnSpace * i, chartRect.bottom), gridPaint);
    }
  }
}
