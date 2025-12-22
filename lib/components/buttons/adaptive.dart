import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/glass_button.dart';
import 'package:limitless_flutter/components/buttons/glass_surface.dart';

class AdaptiveGlassButton extends StatefulWidget {
  final String buttonText;
  final bool showSpinner;
  final String? loadingText;
  final GlassButtonIntent intent;
  final bool compact;

  final Widget? leadingIcon;

  final Future<void> Function()? onPressedAsync;

  const AdaptiveGlassButton._internal({
    super.key,
    required this.buttonText,
    required this.showSpinner,
    required this.intent,
    this.onPressedAsync,
    this.loadingText,
    this.compact = true,
    this.leadingIcon,
  });

  factory AdaptiveGlassButton.async({
    Key? key,
    required String buttonText,
    required Future<void> Function() onPressed,
    GlassButtonIntent intent = GlassButtonIntent.primary,
    bool showSpinner = true,
    String? loadingText,
    bool compact = true,
    Widget? leadingIcon,
  }) {
    return AdaptiveGlassButton._internal(
      key: key,
      buttonText: buttonText,
      showSpinner: showSpinner,
      onPressedAsync: onPressed,
      intent: intent,
      loadingText: loadingText,
      compact: compact,
      leadingIcon: leadingIcon,
    );
  }

  factory AdaptiveGlassButton.sync({
    Key? key,
    required String buttonText,
    required void Function()? onPressed,
    GlassButtonIntent intent = GlassButtonIntent.primary,
    bool compact = true,
    Widget? leadingIcon,
  }) {
    return AdaptiveGlassButton._internal(
      key: key,
      buttonText: buttonText,
      showSpinner: false,
      // Wrap VoidCallBack into a Future
      onPressedAsync: onPressed != null ? () async => onPressed() : null,
      intent: intent,
      compact: compact,
      leadingIcon: leadingIcon,
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

    // Don't trigger rebuild if not showing a spinner
    if (widget.showSpinner) {
      setState(() => _loading = true);
    }

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
    Widget content({required bool cupertino, required Widget? leadingIcon}) {
      const double kSpin = 18;
      final spinner = cupertino
          ? const CupertinoActivityIndicator(radius: 9)
          : const SizedBox(
              width: kSpin,
              height: kSpin,
              child: CircularProgressIndicator(strokeWidth: 2),
            );

      // Cupertino style
      if (cupertino) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showSpinner) ...[
              SizedBox(
                width: kSpin,
                height: kSpin,
                child: _loading ? spinner : null,
              ),
              const SizedBox(width: 8),
            ],
            // Optional leading icon
            if (leadingIcon != null) ...[leadingIcon, const SizedBox(width: 8)],
            Flexible(child: label),
            if (widget.showSpinner) ...[
              // Ghost box to keep label centered
              const SizedBox(width: kSpin, height: kSpin),
            ],
          ],
        );
      }

      // Material style
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showSpinner) ...[
            SizedBox(
              width: kSpin,
              height: kSpin,
              child: _loading ? spinner : null,
            ),
            const SizedBox(width: 8),
          ],
          // Optional leading icon
          if (leadingIcon != null) ...[leadingIcon, const SizedBox(width: 8)],
          Flexible(child: label),
          if (widget.showSpinner) ...[
            const SizedBox(width: kSpin, height: kSpin),
          ],
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
            child: content(
              cupertino: true,
              leadingIcon: widget.leadingIcon == null
                  ? null
                  : IconTheme(
                      data: IconThemeData(size: 18, color: style.baseColor),
                      child: widget.leadingIcon!,
                    ),
            ),
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
              child: content(
                cupertino: false,
                leadingIcon: widget.leadingIcon == null
                    ? null
                    : IconTheme(
                        data: IconThemeData(size: 18, color: style.baseColor),
                        child: widget.leadingIcon!,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
