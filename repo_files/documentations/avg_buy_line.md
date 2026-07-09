# Avg. Buy reference line + pill

A horizontal dashed reference line at an "average buy" price, with a styled
widget label ("pill") sitting exactly on the line, plus high/low labels at the
chart corners. Positioning uses the chart's own value→pixel transform — no
hand-rolled geometry. Mirrors the fl_chart `HorizontalLine` feature for the
candlestick chart.

## API

### `HorizontalLine` (`lib/entity/horizontal_line.dart`)

| Field | Type | Default | Meaning |
|---|---|---|---|
| `value` | `double` | required | Value on the **external** scale (not a candle price). |
| `axisLow` | `double` | required | Low bound of the external scale → maps to chart bottom. |
| `axisHigh` | `double` | required | High bound of the external scale → maps to chart top. |
| `color` | `Color` | `0xFF00E5FF` (cyan) | Line color. |
| `strokeWidth` | `double` | `2.0` | Line thickness. |
| `dashArray` | `List<double>` | `[8, 6]` | Dash `[on, off]`; empty = solid. |
| `labelWidgetBuilder` | `Widget Function(HorizontalLine)?` | `null` | Pill builder; chart centers it vertically on the line. |
| `labelWidgetAlignment` | `Alignment` | `centerLeft` | Horizontal anchor (only `.x` used). |
| `showAxisLabels` | `bool` | `false` | Draw `axisHigh` (top-right) / `axisLow` (bottom-right) corner labels. |
| `axisLabelColor` | `Color` | `white70` | Corner-label color. |

Supports `copyWith`, `lerp`, `props`, `==`/`hashCode`.

### Value → pixel mapping

The value comes from external trade data on its own scale, mapped into the
chart's visible candle Y domain (`mMainMinValue`..`mMainMaxValue`):

```dart
ratio    = ((value - axisLow) / (axisHigh - axisLow)).clamp(0, 1);
chartVal = minY + ratio * (maxY - minY);
pixelY   = getMainY(chartVal);
```

- `value >= axisHigh` → pins to the top edge.
- `value <= axisLow` → pins to the bottom edge.

Because `ratio` is clamped, the line is always inside the chart; the drawn
pixel is further clamped by half the stroke width so an edge line is never
half-clipped.

### `KChartWidget`

```dart
KChartWidget(
  datas, chartStyle, chartColors,
  isTrendLine: false,
  horizontalLines: [
    HorizontalLine(
      value: 50000,
      axisLow: 20000,
      axisHigh: 80000,
      showAxisLabels: true,
      labelWidgetBuilder: (line) => AvgBuyPill(value: _fmt(line.value)),
    ),
  ],
)
```

The chart's overlay `Stack` uses `clipBehavior: Clip.none`, so a pill pinned to
an extreme can overhang the edge without being clipped.

### `AvgBuyPill` (`lib/components/avg_buy_pill.dart`)

Reusable, theme-aware pill. Rounded bordered box (radius 20), cyan border,
background black in dark / white in light, two-tone text ("Avg. Buy" in the
on-surface color + value in accent, bold). Every color is overridable; defaults
come from `Theme.of(context).brightness`.

```dart
AvgBuyPill(
  label: 'Avg. Buy',
  value: '50,000',
  accentColor: Colors.cyan,      // border + value
  backgroundColor: null,          // theme-aware default
  labelColor: null,               // theme on-surface default
)
```

## How it works internally

- **Line (canvas):** `ChartPainter.drawHorizontalLines` draws the dashed line
  in screen space after the candle transform is restored.
- **Corner labels (canvas):** `_drawAxisCornerLabels` draws `axisHigh`/`axisLow`
  at the top-right / bottom-right of the main rect (not hand-positioned in a
  Stack).
- **Pill (widget):** `_KChartWidgetState._buildHorizontalLineLabels` calls
  `ChartPainter.horizontalLinePixelYForSize(line, size)` at build time (it runs
  the same layout pass as `paint`), then positions the pill with
  `Positioned(top: lineY) → FractionalTranslation(0, -0.5)` so its vertical
  center lands exactly on the line.
