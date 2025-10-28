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

    if (_isCupertino) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: CupertinoButton.filled(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          borderRadius: BorderRadius.circular(12),
          onPressed: callback,
          child: Text(buttonText),
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
