import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/glass_button.dart';
import 'package:limitless_flutter/components/buttons/glass_surface.dart';

class AdaptiveGlassButton extends StatefulWidget {
  final String buttonText;
  final String? loadingText;
  final GlassButtonIntent intent;
  final bool compact;

  final Future<void> Function()? onPressedAsync;

  const AdaptiveGlassButton._internal({
    super.key,
    required this.buttonText,
    required this.intent,
    this.onPressedAsync,
    this.loadingText,
    this.compact = true,
  }) : assert(onPressedAsync != null, 'Use .sync or .async factories.');

  factory AdaptiveGlassButton.async({
    Key? key,
    required String buttonText,
    required Future<void> Function() onPressed,
    GlassButtonIntent intent = GlassButtonIntent.primary,
    String? loadingText,
    bool compact = true,
  }) {
    return AdaptiveGlassButton._internal(
      key: key,
      buttonText: buttonText,
      onPressedAsync: onPressed,
      intent: intent,
      loadingText: loadingText,
      compact: compact,
    );
  }

  factory AdaptiveGlassButton.sync({
    Key? key,
    required String buttonText,
    required VoidCallback onPressed,
    GlassButtonIntent intent = GlassButtonIntent.primary,
    bool compact = true,
  }) {
    return AdaptiveGlassButton._internal(
      key: key,
      buttonText: buttonText,
      // Wrap VoidCallBack into a Future
      onPressedAsync: () async => onPressed(),
      intent: intent,
      compact: compact,
    );
  }

  @override
  State<AdaptiveGlassButton> createState() => _AdaptiveGlassButtonState();
}

class _AdaptiveGlassButtonState extends State<AdaptiveGlassButton> {
  bool _loading = false;
  bool get _isCupertino =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  Future<void> _handlePress() async {
    if (_loading || widget.onPressedAsync == null) return;
    setState(() => _loading = true);
    try {
      await widget.onPressedAsync!.call();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = GlassButtonStyle.fromScheme(cs, widget.intent);

    final labelStyle = Theme.of(context).textTheme.labelLarge!.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      height: 1.5,
      color: style.baseColor,
    );
    final label = Text(
      _loading ? (widget.loadingText ?? widget.buttonText) : widget.buttonText,
      style: labelStyle,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );

    // Common content (row with optional spinner)
    Widget content({required bool cupertino}) {
      final spinner = cupertino
          ? const CupertinoActivityIndicator(radius: 9)
          : const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            );

      // Cupertino style
      if (cupertino) {
        return Stack(
          alignment: AlignmentGeometry.centerLeft,
          children: [
            SizedBox(width: 18, height: 18, child: _loading ? spinner : null),
            if (_loading) const SizedBox(width: 8),
            if (_loading) Flexible(child: label) else label,
          ],
        );
      }

      // Material style
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 18, height: 18, child: _loading ? spinner : null),
          if (_loading) const SizedBox(width: 8),
          if (_loading) Flexible(child: label) else label,
        ],
      );
    }

    final childPadding = widget.compact
        ? style.padding
        : const EdgeInsets.symmetric(horizontal: 18, vertical: 14);

    Widget wrapGlass(Widget inner) => glassSurface(
      inner,
      style.radius,
      style.borderColor,
      style.glassColor,
      style.highlightStroke,
    );

    if (_isCupertino) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: wrapGlass(
          CupertinoButton(
            padding: childPadding,
            borderRadius: style.radius,
            onPressed: _loading ? null : _handlePress,
            color: Colors.transparent,
            disabledColor: Colors.transparent,
            child: content(cupertino: true),
          ),
        ),
      );
    }

    final highlightColor = style.baseColor.withValues(alpha: 0.10);
    final splashColor = style.baseColor.withValues(alpha: 0.12);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: wrapGlass(
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: style.radius,
            onTap: _loading ? null : _handlePress,
            highlightColor: highlightColor,
            splashColor: splashColor,
            child: Padding(
              padding: childPadding,
              child: content(cupertino: false),
            ),
          ),
        ),
      ),
    );
  }
}
