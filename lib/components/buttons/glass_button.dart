import 'package:flutter/material.dart';

enum GlassButtonIntent { primary, secondary }

class GlassButtonStyle {
  final Color baseColor;
  final Color glassColor;
  final Color borderColor;
  final Color highlightStroke;
  final BorderRadius radius;
  final EdgeInsets padding;

  const GlassButtonStyle({
    required this.baseColor,
    required this.glassColor,
    required this.borderColor,
    required this.highlightStroke,
    this.radius = const BorderRadius.all(Radius.circular(14)),
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  });

  factory GlassButtonStyle.fromScheme(
    ColorScheme cs,
    GlassButtonIntent intent,
  ) {
    final base = switch (intent) {
      GlassButtonIntent.primary => cs.primary,
      GlassButtonIntent.secondary => cs.inversePrimary,
    };

    final glass = switch (intent) {
      GlassButtonIntent.primary => base.withValues(alpha: 0.35),
      GlassButtonIntent.secondary => base.withValues(alpha: 0.05),
    };

    return GlassButtonStyle(
      baseColor: base,
      glassColor: glass,
      borderColor: base.withValues(alpha: 0.45),
      highlightStroke: Colors.white.withValues(alpha: 0.15),
    );
  }
}
