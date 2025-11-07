import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/glass_surface.dart';

class SecondaryAdaptiveAsyncButton extends StatefulWidget {
  const SecondaryAdaptiveAsyncButton({
    super.key,
    required this.buttonText,
    required this.onPressedAsync,
    this.loadingText,
    this.compact = true,
  });

  final String buttonText;
  final Future<void> Function() onPressedAsync;
  final String? loadingText;
  final bool compact;

  @override
  State<SecondaryAdaptiveAsyncButton> createState() =>
      _AdaptiveAsyncButtonState();
}

class _AdaptiveAsyncButtonState extends State<SecondaryAdaptiveAsyncButton> {
  bool _loading = false;

  bool get _isCupertino =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  Future<void> _handlePress() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await widget.onPressedAsync();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final baseColor = cs.inversePrimary;
    final glassColor = baseColor.withValues(alpha: 0.05);
    final borderColor = baseColor.withValues(alpha: 0.45);
    final highlightStroke = Colors.white.withValues(alpha: 0.15);
    final radius = BorderRadius.circular(14);

    if (_isCupertino) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: glassSurface(
          CupertinoButton(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            borderRadius: radius,
            onPressed: _loading ? null : _handlePress,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // spinner when loading
                if (_loading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CupertinoActivityIndicator(radius: 9),
                  )
                else
                  const SizedBox(width: 18, height: 18), // spacer
                Center(
                  child: Text(
                    widget.buttonText,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          radius,
          borderColor,
          glassColor,
          highlightStroke,
        ),
      );
    }

    // Material
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: glassSurface(
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: _loading ? null : _handlePress,
            highlightColor: baseColor.withValues(alpha: 0.1),
            splashColor: baseColor.withValues(alpha: 0.12),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: _loading
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _loading
                        ? (widget.loadingText ?? widget.buttonText)
                        : widget.buttonText,
                  ),
                ],
              ),
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
