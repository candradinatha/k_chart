import 'package:flutter/material.dart';
import 'package:k_chart/flutter_k_chart.dart';

enum VerticalTextAlignment { left, right }

//For TrendLine
double? trendLineMax;
double? trendLineScale;
double? trendLineContentRec;

class MainRenderer extends BaseChartRenderer<CandleEntity> {
  late double mCandleWidth;
  late double mCandleLineWidth;
  MainState state;
  bool isLine;

  //绘制的内容区域
  late Rect _contentRect;
  double _contentPadding = 5.0;
  List<int> maDayList;
  final ChartStyle chartStyle;
  final ChartColors chartColors;
  final double mLineStrokeWidth = 1.0;
  double scaleX;
  late Paint mLinePaint;
  final VerticalTextAlignment verticalTextAlignment;
  final String decimalSeparator;
  final int? decimalPlaces;

  MainRenderer(
      Rect mainRect,
      double maxValue,
      double minValue,
      double topPadding,
      this.state,
      this.isLine,
      int fixedLength,
      this.chartStyle,
      this.chartColors,
      this.scaleX,
      this.verticalTextAlignment,
      this.decimalSeparator,
      this.decimalPlaces,
      [this.maDayList = const [5, 10, 20]])
      : super(
            chartRect: mainRect,
            maxValue: maxValue,
            minValue: minValue,
            topPadding: topPadding,
            fixedLength: fixedLength,
            gridColor: chartColors.gridColor) {
    mCandleWidth = this.chartStyle.candleWidth;
    mCandleLineWidth = this.chartStyle.candleLineWidth;
    mLinePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = mLineStrokeWidth
      ..color = this.chartColors.kLineColor;
    _contentRect = Rect.fromLTRB(
        chartRect.left,
        chartRect.top + _contentPadding,
        chartRect.right,
        chartRect.bottom - _contentPadding);
    if (maxValue == minValue) {
      maxValue *= 1.5;
      minValue /= 2;
    }
    scaleY = _contentRect.height / (maxValue - minValue);
  }

  @override
  void drawText(Canvas canvas, CandleEntity data, double x) {
    if (isLine == true) return;
    TextSpan? span;
    if (state == MainState.MA) {
      span = TextSpan(
        children: _createMATextSpan(data),
      );
    } else if (state == MainState.BOLL) {
      span = TextSpan(
        children: [
          if (data.up != 0)
            TextSpan(
                text:
                    "BOLL: ${format(NumberUtil.formatBigDecimal(data.mb ?? 0).toString(), decimalSeparator, decimal: decimalPlaces)}  ",
                style: getTextStyle(this.chartColors.ma5Color)),
          if (data.mb != 0)
            TextSpan(
                text:
                    "UB: ${format(NumberUtil.formatBigDecimal(data.up ?? 0).toString(), decimalSeparator, decimal: decimalPlaces)}  ",
                style: getTextStyle(this.chartColors.ma10Color)),
          if (data.dn != 0)
            TextSpan(
                text:
                    "LB: ${format(NumberUtil.formatBigDecimal(data.dn ?? 0).toString(), decimalSeparator, decimal: decimalPlaces)}  ",
                style: getTextStyle(this.chartColors.ma30Color)),
        ],
      );
    }
    if (span == null) return;
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  List<InlineSpan> _createMATextSpan(CandleEntity data) {
    List<InlineSpan> result = [];
    for (int i = 0; i < (data.maValueList?.length ?? 0); i++) {
      if (data.maValueList?[i] != 0) {
        var item = TextSpan(
            text:
                "MA${maDayList[i]}: ${format(NumberUtil.formatBigDecimal(data.maValueList![i]).toString(), decimalSeparator, decimal: decimalPlaces)}  ",
            style: getTextStyle(this.chartColors.getMAColor(i)));
        result.add(item);
      }
    }
    return result;
  }

  @override
  void drawChart(CandleEntity lastPoint, CandleEntity curPoint, double lastX,
      double curX, Size size, Canvas canvas) {
    if (isLine) {
      drawPolyline(lastPoint.close, curPoint.close, canvas, lastX, curX);
    } else {
      drawCandle(curPoint, canvas, curX);
      if (state == MainState.MA) {
        drawMaLine(lastPoint, curPoint, canvas, lastX, curX);
      } else if (state == MainState.BOLL) {
        drawBollLine(lastPoint, curPoint, canvas, lastX, curX);
      }
    }
  }

  Shader? mLineFillShader;
  Path? mLinePath, mLineFillPath;
  Paint mLineFillPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  //画折线图
  drawPolyline(double lastPrice, double curPrice, Canvas canvas, double lastX,
      double curX) {
//    drawLine(lastPrice + 100, curPrice + 100, canvas, lastX, curX, ChartColors.kLineColor);
    mLinePath ??= Path();

//    if (lastX == curX) {
//      mLinePath.moveTo(lastX, getY(lastPrice));
//    } else {
////      mLinePath.lineTo(curX, getY(curPrice));
//      mLinePath.cubicTo(
//          (lastX + curX) / 2, getY(lastPrice), (lastX + curX) / 2, getY(curPrice), curX, getY(curPrice));
//    }
    if (lastX == curX) lastX = 0; //起点位置填充
    mLinePath!.moveTo(lastX, getY(lastPrice));
    mLinePath!.cubicTo((lastX + curX) / 2, getY(lastPrice), (lastX + curX) / 2,
        getY(curPrice), curX, getY(curPrice));

    //画阴影
    mLineFillShader ??= LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      tileMode: TileMode.clamp,
      colors: [
        this.chartColors.lineFillColor,
        this.chartColors.lineFillInsideColor
      ],
    ).createShader(Rect.fromLTRB(
        chartRect.left, chartRect.top, chartRect.right, chartRect.bottom));
    mLineFillPaint..shader = mLineFillShader;

    mLineFillPath ??= Path();

    mLineFillPath!.moveTo(lastX, chartRect.height + chartRect.top);
    mLineFillPath!.lineTo(lastX, getY(lastPrice));
    mLineFillPath!.cubicTo((lastX + curX) / 2, getY(lastPrice),
        (lastX + curX) / 2, getY(curPrice), curX, getY(curPrice));
    mLineFillPath!.lineTo(curX, chartRect.height + chartRect.top);
    mLineFillPath!.close();

    canvas.drawPath(mLineFillPath!, mLineFillPaint);
    mLineFillPath!.reset();

    canvas.drawPath(mLinePath!,
        mLinePaint..strokeWidth = (mLineStrokeWidth / scaleX).clamp(0.1, 1.0));
    mLinePath!.reset();
  }

  void drawMaLine(CandleEntity lastPoint, CandleEntity curPoint, Canvas canvas,
      double lastX, double curX) {
    for (int i = 0; i < (curPoint.maValueList?.length ?? 0); i++) {
      if (i == 3) {
        break;
      }
      if (lastPoint.maValueList?[i] != 0) {
        drawLine(lastPoint.maValueList?[i], curPoint.maValueList?[i], canvas,
            lastX, curX, this.chartColors.getMAColor(i));
      }
    }
  }

  void drawBollLine(CandleEntity lastPoint, CandleEntity curPoint,
      Canvas canvas, double lastX, double curX) {
    if (lastPoint.up != 0) {
      drawLine(lastPoint.up, curPoint.up, canvas, lastX, curX,
          this.chartColors.ma10Color);
    }
    if (lastPoint.mb != 0) {
      drawLine(lastPoint.mb, curPoint.mb, canvas, lastX, curX,
          this.chartColors.ma5Color);
    }
    if (lastPoint.dn != 0) {
      drawLine(lastPoint.dn, curPoint.dn, canvas, lastX, curX,
          this.chartColors.ma30Color);
    }
  }

  void drawCandle(CandleEntity curPoint, Canvas canvas, double curX) {
    var high = getY(curPoint.high);
    var low = getY(curPoint.low);
    var open = getY(curPoint.open);
    var close = getY(curPoint.close);
    double r = mCandleWidth / 2;
    double lineR = mCandleLineWidth / 2;
    if (open >= close) {
      // 实体高度>= CandleLineWidth
      if (open - close < mCandleLineWidth) {
        open = close + mCandleLineWidth;
      }
      chartPaint.color = this.chartColors.upColor;
      canvas.drawRect(
          Rect.fromLTRB(curX - r, close, curX + r, open), chartPaint);
      canvas.drawRect(
          Rect.fromLTRB(curX - lineR, high, curX + lineR, low), chartPaint);
    } else if (close > open) {
      // 实体高度>= CandleLineWidth
      if (close - open < mCandleLineWidth) {
        open = close - mCandleLineWidth;
      }
      chartPaint.color = this.chartColors.dnColor;
      canvas.drawRect(
          Rect.fromLTRB(curX - r, open, curX + r, close), chartPaint);
      canvas.drawRect(
          Rect.fromLTRB(curX - lineR, high, curX + lineR, low), chartPaint);
    }
  }

  void drawBuy(CandleEntity lastPoint, CandleEntity curPoint, double lastX,
      double curX, Size size, Canvas canvas, MarkerStyle markerStyle) {
    if (markerStyle.isShowBuyMarks == false) return;
    final buyMarkerPaint = Paint()
      ..color = markerStyle.buyMarkColor
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'B',
        style: markerStyle.markerBuyTextStyle ??
            const TextStyle(
              color: Colors.black,
              fontSize: 16 * 0.7,
              fontWeight: FontWeight.bold,
            ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final offsetInCanvas = Offset(
      curX,
      getY(curPoint.low) + markerStyle.sellMarkMargin,
    );

    // Draw shadow behind the marker
    final markerRect = Rect.fromCenter(
      center: offsetInCanvas,
      width: markerStyle.markerSize,
      height: markerStyle.markerSize,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        markerRect.shift(const Offset(-1, 3)), // Offset the shadow
        const Radius.circular(4),
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.53) // Shadow color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
        ..style = PaintingStyle.fill,
    );

    final trianglePath = Path();
    trianglePath.moveTo(markerRect.center.dx, markerRect.top - 4);
    trianglePath.lineTo(markerRect.left, markerRect.top + 5);
    trianglePath.lineTo(markerRect.right, markerRect.top + 5);
    trianglePath.close();
    canvas.drawPath(trianglePath, buyMarkerPaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(markerRect, Radius.circular(4)),
      buyMarkerPaint,
    );

    textPainter.paint(
      canvas,
      Offset(
        markerRect.left + (markerRect.width - textPainter.width) / 2,
        markerRect.top + (markerRect.height - textPainter.height) / 2,
      ),
    );
  }

  void drawSell(CandleEntity lastPoint, CandleEntity curPoint, double lastX,
      double curX, Size size, Canvas canvas, MarkerStyle markerStyle) {
    if (markerStyle.isShowSellMarks == false) return;
    final sellMarkerPaint = Paint()
      ..color = markerStyle.sellMarkColor
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'S',
        style: markerStyle.markerSellTextStyle ??
            const TextStyle(
              color: Colors.white,
              fontSize: 16 * 0.7,
              fontWeight: FontWeight.bold,
            ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final offsetInCanvas = Offset(
      curX,
      getY(curPoint.high) - markerStyle.sellMarkMargin,
    );

    final markerRect = Rect.fromCenter(
      center: offsetInCanvas,
      width: markerStyle.markerSize,
      height: markerStyle.markerSize,
    );

    // Draw shadow behind the marker

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        markerRect.shift(const Offset(-1, 3)), // Offset the shadow
        const Radius.circular(4),
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.53) // Shadow color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
        ..style = PaintingStyle.fill,
    );

    final trianglePath = Path()
      ..moveTo(markerRect.center.dx, markerRect.bottom + 4)
      ..lineTo(markerRect.left, markerRect.bottom - 5)
      ..lineTo(markerRect.right, markerRect.bottom - 5)
      ..close();

    canvas
      ..drawPath(trianglePath, sellMarkerPaint)
      ..drawRRect(
        RRect.fromRectAndRadius(markerRect, const Radius.circular(4)),
        sellMarkerPaint,
      );

    textPainter.paint(
      canvas,
      Offset(
        markerRect.left + (markerRect.width - textPainter.width) / 2,
        markerRect.top + (markerRect.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  void drawVerticalText(canvas, textStyle, int gridRows) {
    double rowSpace = chartRect.height / gridRows;
    for (var i = 0; i <= gridRows; ++i) {
      double value = (gridRows - i) * rowSpace / scaleY + minValue;
      TextSpan span = TextSpan(
          text:
              "${format(NumberUtil.formatBigDecimal(value).toString(), decimalSeparator, decimal: decimalPlaces)}",
          style: textStyle);
      TextPainter tp =
          TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();

      double offsetX;
      switch (verticalTextAlignment) {
        case VerticalTextAlignment.left:
          offsetX = 0;
          break;
        case VerticalTextAlignment.right:
          offsetX = chartRect.width - tp.width;
          break;
      }

      if (i == 0) {
        tp.paint(canvas, Offset(offsetX, topPadding));
      } else {
        tp.paint(
            canvas, Offset(offsetX, rowSpace * i - tp.height + topPadding));
      }
    }
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
//    final int gridRows = 4, gridColumns = 4;
    double rowSpace = chartRect.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      canvas.drawLine(Offset(0, rowSpace * i + topPadding),
          Offset(chartRect.width, rowSpace * i + topPadding), gridPaint);
    }
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      canvas.drawLine(Offset(columnSpace * i, topPadding / 3),
          Offset(columnSpace * i, chartRect.bottom), gridPaint);
    }
  }

  @override
  double getY(double y) {
    //For TrendLine
    updateTrendLineData();
    return (maxValue - y) * scaleY + _contentRect.top;
  }

  void updateTrendLineData() {
    trendLineMax = maxValue;
    trendLineScale = scaleY;
    trendLineContentRec = _contentRect.top;
  }
}
