import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/glass_surface.dart';

class AdaptiveAsyncButton extends StatefulWidget {
  const AdaptiveAsyncButton({
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
  State<AdaptiveAsyncButton> createState() => _AdaptiveAsyncButtonState();
}

class _AdaptiveAsyncButtonState extends State<AdaptiveAsyncButton> {
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

  // Widget _content(BuildContext context) {
  //   final text = _loading
  //       ? (widget.loadingText ?? widget.buttonText)
  //       : widget.buttonText;

  //   // Keep width stable: reserve space where spinner goes
  //   const spinnerBox = SizedBox.square(dimension: 18);

  //   if (_loading) {
  //     return Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [spinnerBox, const SizedBox(width: 8), label],
  //     );
  //   }

  //   // No spinner when idle, but keep layout consistent
  //   return Row(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       spinnerBox, // empty spacer to avoid layout shift
  //       const SizedBox(width: 8),
  //       label,
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final baseColor = cs.primary;
    final glassColor = baseColor.withValues(alpha: 0.35);
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
