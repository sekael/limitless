import 'package:flutter/material.dart';

class TextIcon extends StatelessWidget {
  final String icon;
  final String? semanticLabel;

  // Visual size in logical pixels
  final double fontSize;

  const TextIcon({
    super.key,
    required this.icon,
    this.semanticLabel,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fontSize + 2,
      height: fontSize + 2,
      child: Text(
        icon,
        semanticsLabel: semanticLabel,
        style: TextStyle(fontSize: fontSize, height: 1),
      ),
    );
  }
}
