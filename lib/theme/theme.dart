import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'typography.dart';
import 'tokens.dart';

bool get _isCupertinoPlatform {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
}

final ColorScheme lightScheme = ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: const Color(0xFFFF9800),
);

final ColorScheme darkScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 41, 41, 184),
);

ThemeData themeFrom(ColorScheme scheme) {
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
          _isCupertinoPlatform, // centers titles on iOS like UINavigationBar
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

ThemeData lightMode = themeFrom(lightScheme);
ThemeData darkMode = themeFrom(darkScheme);
