import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

TextTheme buildTextTheme(Brightness brightness) {
  // Start from Material defaults (M3). Don’t set fontFamily here so iOS can keep SF in Cupertino areas.
  final base = brightness == Brightness.dark
      ? Typography
            .blackMountainView // M3 dark base (uses good contrast)
      : Typography.whiteMountainView; // M3 light base

  // Scale & refine a few roles you actually use
  return base.copyWith(
    displayLarge: base.displayLarge?.copyWith(fontWeight: FontWeight.w700),
    headlineMedium: base.headlineMedium?.copyWith(letterSpacing: 0.15),
    titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    bodyLarge: base.bodyLarge?.copyWith(height: 1.3),
    labelLarge: base.labelLarge?.copyWith(letterSpacing: 0.2),
  );
}
