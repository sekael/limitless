import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'typography.dart';
import 'tokens.dart';

class AppTheme {
  // If you don’t use the generator yet, uncomment this instead:
  static final ColorScheme lightScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF8C5A1E),
    brightness: Brightness.light,
  );
  static final ColorScheme darkScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF8C5A1E),
    brightness: Brightness.dark,
  );

  static ThemeData themeFrom(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // Let Material pick platform-appropriate defaults (density, scroll physics)
      visualDensity: VisualDensity.adaptivePlatformDensity,
      // Typography tailored in a separate file (keeps platform nuance)
      textTheme: buildTextTheme(scheme.brightness),
      // Example surface/tint tweaks
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle:
            Platform.isIOS, // centers titles on iOS like UINavigationBar
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        backgroundColor: scheme.surface,
        type: BottomNavigationBarType.fixed,
      ),
      // Custom tokens (spacing, radii, etc.)
      extensions: const <ThemeExtension<dynamic>>[
        SpacingTokens(),
        RadiusTokens(),
      ],
      // Make Cupertino children look native inside Material widgets
      cupertinoOverrideTheme:
          const NoDefaultCupertinoThemeData(), // inherits iOS system fonts/colors
    );
  }

  /// Builds a pair of light/dark ThemeData, optionally harmonized with Android Dynamic Colors.
  static Future<(ThemeData light, ThemeData dark)> buildAdaptiveThemes() async {
    // Dynamic colors only available on Android 12+; on others, falls back gracefully.
    if (!kIsWeb && (Platform.isAndroid)) {
      final corePalette = await DynamicColorPlugin.getCorePalette();
      if (corePalette != null) {
        final androidLight = corePalette.toColorScheme(
          brightness: Brightness.light,
        );
        final androidDark = corePalette.toColorScheme(
          brightness: Brightness.dark,
        );
        return (themeFrom(androidLight), themeFrom(androidDark));
      }
    }
    // Fallback: fixed schemes
    return (themeFrom(lightScheme), themeFrom(darkScheme));
  }
}
