import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final String lightBackgroundImage;
  final String darkBackgroundImage;
  final Duration fadeDuration;
  final double peakOpacity;

  const AnimatedBackground({
    super.key,
    this.lightBackgroundImage = 'assets/images/background/light.jpg',
    this.darkBackgroundImage = 'assets/images/background/dark.jpg',
    this.fadeDuration = const Duration(milliseconds: 1500),
    this.peakOpacity = 1.0,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _coverAnimation;

  late String _currentAsset;
  String? _pendingAsset;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    );
    _coverAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Swap asset exactly at the midpoint (when fully covered)
    _controller.addListener(() {
      if (_pendingAsset != null &&
          _controller.value >= 0.5 &&
          _currentAsset != _pendingAsset) {
        _currentAsset = _pendingAsset!;
        // Keep revealing, no setState needed because rebuilding each tick
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      _currentAsset = isDark
          ? widget.darkBackgroundImage
          : widget.lightBackgroundImage;

      // Warm both images
      await precacheImage(AssetImage(widget.lightBackgroundImage), context);
      await precacheImage(AssetImage(widget.darkBackgroundImage), context);
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeStartTransition();
  }

  @override
  void didUpdateWidget(covariant AnimatedBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeStartTransition();
  }

  Future<void> _maybeStartTransition() async {
    if (!_initialized) return;

    final goingDark = Theme.of(context).brightness == Brightness.light;
    final desired = goingDark
        ? widget.darkBackgroundImage
        : widget.lightBackgroundImage;

    if (desired == _currentAsset && _pendingAsset == null) return;
    if (_pendingAsset == desired && _controller.isAnimating) return;
    _pendingAsset = desired;

    // Start: cover up image
    _controller.stop();
    _controller.value = 0.0;
    setState(() {});

    await _controller.animateTo(0.5, curve: Curves.easeOut);
    await precacheImage(AssetImage(desired), context);

    // Reveal second half
    if (mounted) {
      await _controller.animateTo(1.0, curve: Curves.easeIn);
      // Reset controller
      _controller.value = 0.0;
      _pendingAsset = null;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const SizedBox.expand();
    final goingDark = Theme.of(context).brightness == Brightness.light;
    final Color coverBase = goingDark ? Colors.black : Colors.white;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final opacity = (_coverAnimation.value * widget.peakOpacity).clamp(
          0.0,
          1.0,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            // Always render current image underneath and enable gapless playback
            Image.asset(
              _currentAsset,
              fit: BoxFit.cover,
              alignment: AlignmentGeometry.center,
              gaplessPlayback: true,
            ),
            IgnorePointer(
              child: Opacity(
                opacity: opacity,
                child: ColoredBox(color: coverBase),
              ),
            ),
          ],
        );
      },
    );
  }
}
