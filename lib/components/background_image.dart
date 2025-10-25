import 'package:flutter/material.dart';

class BackgroundImage {
  const BackgroundImage._();

  static BoxDecoration getBackgroundImage(BuildContext context) {
    final isDarkNow = Theme.of(context).brightness == Brightness.dark;
    String backgroundImage = isDarkNow ? 'dark.jpg' : 'light.jpg';

    // Darken or brighten image depending on theme
    final Color scrimColor = isDarkNow
        ? Colors.black.withAlpha(64)
        : Colors.white.withAlpha(64);

    final BlendMode blendMode = isDarkNow ? BlendMode.darken : BlendMode.screen;

    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage('images/background/$backgroundImage'),
        fit: BoxFit.cover,
        alignment: AlignmentGeometry.center,
        colorFilter: ColorFilter.mode(scrimColor, blendMode),
      ),
    );
  }
}
