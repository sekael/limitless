import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/text/icon.dart';

class EatCookieButton extends StatelessWidget {
  const EatCookieButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveGlassButton.async(
      buttonText: 'Eat a Cookie',
      onPressed: () async => debugPrint('Would eat a cookie!'),
      leadingIcon: const TextIcon(icon: '🍪', semanticLabel: 'Cookie'),
    );
  }
}
