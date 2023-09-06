extension StringExt on String? {
  String get removeTrailingZeros =>
      this != null ? this!.replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "") : "";
}