enum FontScaleLevel { normal, large, extraLarge }

extension FontScaleLevelX on FontScaleLevel {
  bool get isLarge => this == FontScaleLevel.large || this == FontScaleLevel.extraLarge;

  static FontScaleLevel fromNativeValue(Object value) {
    final number = value is num ? value.toDouble() : double.tryParse(value.toString()) ?? 1;
    if (number >= 1.35) return FontScaleLevel.extraLarge;
    if (number >= 1.15) return FontScaleLevel.large;
    return FontScaleLevel.normal;
  }
}
