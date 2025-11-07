import 'dart:ui';
import 'package:flutter/material.dart';

Widget glassSurface(
  Widget child,
  BorderRadius radius,
  Color borderColor,
  Color glassColor,
  Color highlightStroke,
) {
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
            BoxShadow(color: highlightStroke, blurRadius: 0, spreadRadius: 1),
          ],
        ),
        child: child,
      ),
    ),
  );
}
