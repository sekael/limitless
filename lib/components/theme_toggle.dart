import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:limitless_flutter/config/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkNow = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      minimum: const EdgeInsets.only(right: 16, bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 6,
              ),
              child: Switch(
                value: isDarkNow,
                onChanged: (m) => context.read<ThemeProvider>().setMode(
                  m ? ThemeMode.dark : ThemeMode.light,
                ),
                thumbIcon: WidgetStateProperty.resolveWith(
                  (_) => Icon(
                    isDarkNow
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
