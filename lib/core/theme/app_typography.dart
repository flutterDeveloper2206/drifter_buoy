import 'package:flutter/material.dart';

/// Compact type for setup / “Add New” style screens and future forms.
/// Prefer these over [titleLarge] / [titleMedium] so titles and body stay small.
extension AppCompactTypography on TextTheme {
  /// Section / card titles (e.g. “Bluetooth Setup”).
  TextStyle? compactSectionTitle(Color color) =>
      titleSmall?.copyWith(color: color, fontWeight: FontWeight.w700);

  /// App bar title on add-new / detail pages.
  TextStyle? compactAppBarTitle(Color color) =>
      titleSmall?.copyWith(color: color, fontWeight: FontWeight.w700);

  /// Supporting text under a section title.
  TextStyle? compactSupportingText(Color color) =>
      bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600);

  /// Emphasized inline actions (e.g. “Continue…”).
  TextStyle? compactActionText(Color color) =>
      titleSmall?.copyWith(color: color, fontWeight: FontWeight.w700);

  /// Dense values in grids / metrics.
  TextStyle? compactValueText(Color color) =>
      labelLarge?.copyWith(color: color, fontWeight: FontWeight.w700);

  /// Form field labels.
  TextStyle? compactFieldLabel(Color color) =>
      titleSmall?.copyWith(color: color, fontWeight: FontWeight.w600);

  /// Form field input text.
  TextStyle? compactFieldInput(Color color) =>
      bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600);
}
