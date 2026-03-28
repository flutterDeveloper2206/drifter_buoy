import 'package:flutter/material.dart';

/// Global factor applied to Material 3 text styles (1.0 = default).
/// Lower = smaller type app-wide. Used together with headline→title downgrades in widgets.
const double kAppTextScaleFactor = 0.76;

TextTheme _scaledTextTheme(TextTheme base, double factor) {
  TextStyle? scale(TextStyle? style) {
    if (style == null) return null;
    final size = style.fontSize;
    if (size == null) return style;
    return style.copyWith(fontSize: (size * factor).clamp(10.0, 200.0));
  }

  return TextTheme(
    displayLarge: scale(base.displayLarge),
    displayMedium: scale(base.displayMedium),
    displaySmall: scale(base.displaySmall),
    headlineLarge: scale(base.headlineLarge),
    headlineMedium: scale(base.headlineMedium),
    headlineSmall: scale(base.headlineSmall),
    titleLarge: scale(base.titleLarge),
    titleMedium: scale(base.titleMedium),
    titleSmall: scale(base.titleSmall),
    bodyLarge: scale(base.bodyLarge),
    bodyMedium: scale(base.bodyMedium),
    bodySmall: scale(base.bodySmall),
    labelLarge: scale(base.labelLarge),
    labelMedium: scale(base.labelMedium),
    labelSmall: scale(base.labelSmall),
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
    useMaterial3: true,
  );

  final text = _scaledTextTheme(base.textTheme, kAppTextScaleFactor);

  return base.copyWith(
    textTheme: text,
    primaryTextTheme: _scaledTextTheme(
      base.primaryTextTheme,
      kAppTextScaleFactor,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
