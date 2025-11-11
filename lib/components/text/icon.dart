import 'package:flutter/material.dart';

class TextIcon extends StatelessWidget {
  final String icon;
  final String? semanticLabel;

  // Visual size in logical pixels
  final double size;

  const TextIcon({
    super.key,
    required this.icon,
    this.semanticLabel,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Text(
        icon,
        semanticsLabel: semanticLabel,
        style: TextStyle(fontSize: 16, height: 1),
      ),
    );
  }
}
