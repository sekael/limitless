import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({super.key, required this.buttonText, this.onPressed});

  final String buttonText;
  final VoidCallback? onPressed;

  bool get _isCupertino =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  Widget build(BuildContext context) {
    final callback = onPressed ?? () => debugPrint("Button tapped");
    final cs = Theme.of(context).colorScheme;

    // Glass-like colors
    final baseColor = cs.primary;
    final glassColor = baseColor.withValues(alpha: 0.2);
    final borderColor = baseColor.withValues(alpha: 0.25);
    final highlightStroke = Colors.white.withValues(alpha: 0.05);
    final radius = BorderRadius.circular(12);

    Widget glassSurface(Widget child) {
      return ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [glassColor, glassColor.withValues(alpha: 0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: radius,
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: highlightStroke,
                  blurRadius: 0,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          ),
        ),
      );
    }

    // TODO: make button text nice
    final label = Text(
      buttonText,
      style: Theme.of(context).textTheme.labelLarge,
      textAlign: TextAlign.center,
    );

    if (_isCupertino) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: glassSurface(
          CupertinoButton(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            borderRadius: radius,
            onPressed: callback,
            color: Colors.transparent,
            disabledColor: Colors.transparent,
            child: label,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FilledButton(
        onPressed: callback,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        child: Text(buttonText),
      ),
    );
  }
}
