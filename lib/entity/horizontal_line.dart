import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// A horizontal reference line drawn across the candlestick main chart at a
/// value coming from an *external* scale (e.g. average-buy price on its own
/// `[axisLow, axisHigh]` domain), independent of the candle data.
///
/// The value is mapped into the chart's own Y domain by the painter:
/// ```
/// ratio    = ((value - axisLow) / (axisHigh - axisLow)).clamp(0, 1);
/// chartY   = minY + ratio * (maxY - minY);   // minY/maxY = visible candle range
/// pixelY   = getMainY(chartY);
/// ```
/// so `value >= axisHigh` pins to the top edge and `value <= axisLow` pins to
/// the bottom edge. This mirrors fl_chart's `HorizontalLine`.
class HorizontalLine {
  /// Raw value on the external scale (NOT a candle price).
  final double value;

  /// Low bound of the external scale. Maps to the bottom of the chart.
  final double axisLow;

  /// High bound of the external scale. Maps to the top of the chart.
  final double axisHigh;

  /// Line color. Defaults to accent cyan.
  final Color color;

  /// Line thickness in logical pixels.
  final double strokeWidth;

  /// Dash pattern `[on, off]`. Empty list draws a solid line.
  final List<double> dashArray;

  /// Optional widget label ("pill") positioned so its vertical center sits
  /// exactly on the line. The chart supplies this [HorizontalLine] back to the
  /// builder so the label can render the value.
  final Widget Function(HorizontalLine line)? labelWidgetBuilder;

  /// Horizontal anchor for [labelWidgetBuilder]. Only the `.x` component is
  /// used; the vertical position is always centered on the line.
  final Alignment labelWidgetAlignment;

  /// When true the painter draws the external `axisHigh` at the top-right
  /// corner and `axisLow` at the bottom-right corner of the main chart.
  final bool showAxisLabels;

  /// Color for the corner axis labels. Defaults to a muted on-surface color.
  final Color axisLabelColor;

  const HorizontalLine({
    required this.value,
    required this.axisLow,
    required this.axisHigh,
    this.color = const Color(0xFF00E5FF),
    this.strokeWidth = 2.0,
    this.dashArray = const [8, 6],
    this.labelWidgetBuilder,
    this.labelWidgetAlignment = Alignment.centerLeft,
    this.showAxisLabels = false,
    this.axisLabelColor = Colors.white70,
  });

  HorizontalLine copyWith({
    double? value,
    double? axisLow,
    double? axisHigh,
    Color? color,
    double? strokeWidth,
    List<double>? dashArray,
    Widget Function(HorizontalLine line)? labelWidgetBuilder,
    Alignment? labelWidgetAlignment,
    bool? showAxisLabels,
    Color? axisLabelColor,
  }) {
    return HorizontalLine(
      value: value ?? this.value,
      axisLow: axisLow ?? this.axisLow,
      axisHigh: axisHigh ?? this.axisHigh,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      dashArray: dashArray ?? this.dashArray,
      labelWidgetBuilder: labelWidgetBuilder ?? this.labelWidgetBuilder,
      labelWidgetAlignment: labelWidgetAlignment ?? this.labelWidgetAlignment,
      showAxisLabels: showAxisLabels ?? this.showAxisLabels,
      axisLabelColor: axisLabelColor ?? this.axisLabelColor,
    );
  }

  /// Linearly interpolate between two lines. Numeric + color fields are
  /// tweened; the builder/alignment are taken from [b].
  static HorizontalLine lerp(HorizontalLine a, HorizontalLine b, double t) {
    return HorizontalLine(
      value: lerpDouble(a.value, b.value, t)!,
      axisLow: lerpDouble(a.axisLow, b.axisLow, t)!,
      axisHigh: lerpDouble(a.axisHigh, b.axisHigh, t)!,
      color: Color.lerp(a.color, b.color, t)!,
      strokeWidth: lerpDouble(a.strokeWidth, b.strokeWidth, t)!,
      dashArray: t < 0.5 ? a.dashArray : b.dashArray,
      labelWidgetBuilder: b.labelWidgetBuilder,
      labelWidgetAlignment: b.labelWidgetAlignment,
      showAxisLabels: b.showAxisLabels,
      axisLabelColor: Color.lerp(a.axisLabelColor, b.axisLabelColor, t)!,
    );
  }

  List<Object?> get props => [
        value,
        axisLow,
        axisHigh,
        color,
        strokeWidth,
        dashArray,
        labelWidgetBuilder,
        labelWidgetAlignment,
        showAxisLabels,
        axisLabelColor,
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HorizontalLine &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          axisLow == other.axisLow &&
          axisHigh == other.axisHigh &&
          color == other.color &&
          strokeWidth == other.strokeWidth &&
          _listEq(dashArray, other.dashArray) &&
          labelWidgetBuilder == other.labelWidgetBuilder &&
          labelWidgetAlignment == other.labelWidgetAlignment &&
          showAxisLabels == other.showAxisLabels &&
          axisLabelColor == other.axisLabelColor;

  @override
  int get hashCode => Object.hash(
        value,
        axisLow,
        axisHigh,
        color,
        strokeWidth,
        Object.hashAll(dashArray),
        labelWidgetBuilder,
        labelWidgetAlignment,
        showAxisLabels,
        axisLabelColor,
      );

  static bool _listEq(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
