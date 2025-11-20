import 'package:flutter/material.dart';

class CenterAlignedBodyText extends StatelessWidget {
  final String bodyText;
  final Color? colorOverride;
  final TextStyle? styleOverride;

  const CenterAlignedBodyText({
    super.key,
    required this.bodyText,
    this.colorOverride,
    this.styleOverride,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      bodyText,
      textAlign: TextAlign.center,
      style:
          styleOverride ??
          Theme.of(context).textTheme.bodyLarge?.copyWith(
            color:
                colorOverride ?? Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}
