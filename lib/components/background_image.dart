import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final String lightBackgroundImage;
  final String darkBackgroundImage;
  final Duration fadeDuration;

  const AnimatedBackground({
    super.key,
    this.lightBackgroundImage = 'assets/images/background/light.jpg',
    this.darkBackgroundImage = 'assets/images/background/dark.jpg',
    this.fadeDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _coverAnimation;

  late String _currentAsset;
  String? _nextAsset;
  bool _swapped = false;

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

    // Initial asset based on current theme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      _currentAsset = isDark
          ? widget.darkBackgroundImage
          : widget.lightBackgroundImage;

      // Warm images to reduce flashes
      precacheImage(AssetImage(widget.lightBackgroundImage), context);
      precacheImage(AssetImage(widget.darkBackgroundImage), context);
      setState(() {});
    });

    _controller.addListener(() {
      // Swap images once past the midpoint of the animation
      if (!_swapped && _controller.value >= 0.5 && _nextAsset != null) {
        _currentAsset = _nextAsset!;
        _swapped = true;
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final desired = isDark
          ? widget.darkBackgroundImage
          : widget.lightBackgroundImage;

      if (_currentAsset == desired || _controller.isAnimating) return;

      _nextAsset = desired;
      _swapped = false;

      // Make sure the next image is decoded before the animation
      await precacheImage(AssetImage(desired), context);

      if (!mounted) return;
      _controller.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkNow = Theme.of(context).brightness == Brightness.dark;

    // Colors for animation
    final fullCover = isDarkNow ? Colors.black : Colors.white;
    // final scrimColor = isDarkNow
    //     ? Colors.black.withAlpha(64)
    //     : Colors.white.withAlpha(64);

    const double peakOpacity = 1.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _currentAsset,
              key: ValueKey(_currentAsset),
              fit: BoxFit.cover,
              alignment: Alignment.center,
              gaplessPlayback: true,
            ),
          ],
        );
      },
    );
  }
}
