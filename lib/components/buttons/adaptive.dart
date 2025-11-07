import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/glass_surface.dart';

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
    final glassColor = baseColor.withValues(alpha: 0.35);
    final borderColor = baseColor.withValues(alpha: 0.45);
    final highlightStroke = Colors.white.withValues(alpha: 0.15);
    final radius = BorderRadius.circular(14);

    final label = Text(
      buttonText,
      style: Theme.of(context).textTheme.labelLarge!.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.5,
        color: cs.primary,
      ),
      textAlign: TextAlign.center,
    );

    if (_isCupertino) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: glassSurface(
          CupertinoButton(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            borderRadius: radius,
            onPressed: callback,
            color: Colors.transparent,
            disabledColor: Colors.transparent,
            child: label,
          ),
          radius,
          borderColor,
          glassColor,
          highlightStroke,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: glassSurface(
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: callback,
            highlightColor: baseColor.withValues(alpha: 0.1),
            splashColor: baseColor.withValues(alpha: 0.12),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: label,
            ),
          ),
        ),
        radius,
        borderColor,
        glassColor,
        highlightStroke,
      ),
    );
  }
}
