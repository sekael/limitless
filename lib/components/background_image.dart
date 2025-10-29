import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final String lightBackgroundImage;
  final String darkBackgroundImage;
  final Duration fadeDuration;

  const AnimatedBackground({
    super.key,
    this.lightBackgroundImage = 'assets/images/background/light.jpg',
    this.darkBackgroundImage = 'assets/images/background/dark.jpg',
    this.fadeDuration = const Duration(milliseconds: 750),
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _fadeOut;

  late String _currentAsset;
  late String _nextAsset;
  ImageStream? _stream;
  ImageInfo? _info;
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _fadeOut = ReverseAnimation(_fadeIn);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDark = Theme.of(context).brightness == Brightness.dark;
    _currentAsset = _isDark
        ? widget.darkBackgroundImage
        : widget.lightBackgroundImage;
    _nextAsset = _currentAsset;
    precacheImage(AssetImage(widget.lightBackgroundImage), context);
    precacheImage(AssetImage(widget.darkBackgroundImage), context);
  }

  @override
  void didUpdateWidget(covariant AnimatedBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIsDark = Theme.of(context).brightness == Brightness.dark;
    final desired = newIsDark
        ? widget.darkBackgroundImage
        : widget.lightBackgroundImage;
    if (desired != _currentAsset) {
      _startTransition(desired);
    }
  }

  void _startTransition(String desiredAsset) {
    // Stop previous stream
    _stream?.removeListener(ImageStreamListener(_onImage));
    _info = null;

    _nextAsset = desiredAsset;
    final provider = AssetImage(_nextAsset);
    _stream = provider.resolve(createLocalImageConfiguration(context));
    _stream!.addListener(ImageStreamListener(_onImage));
  }

  void _onImage(ImageInfo info, bool _) {
    _info = info;
    _controller
      ..reset()
      ..forward().whenComplete(() {
        setState(() {
          _currentAsset = _nextAsset;
        });
      });
    _stream?.removeListener(ImageStreamListener(_onImage));
  }

  @override
  Widget build(BuildContext context) {
    final current = Image.asset(
      _currentAsset,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      gaplessPlayback: true,
    );
    final next = Image.asset(
      _nextAsset,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      gaplessPlayback: true,
    );

    // Darken or brighten image depending on theme
    final Color scrimColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withAlpha(64)
        : Colors.white.withAlpha(64);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Outgoing background
        FadeTransition(opacity: _fadeOut, child: current),
        // Incoming background (only visible while animating new asset)
        if (_nextAsset != _currentAsset)
          FadeTransition(opacity: _fadeIn, child: next),

        AnimatedContainer(
          duration: _controller.duration ?? const Duration(milliseconds: 750),
          curve: Curves.easeInOut,
          color: scrimColor,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _stream?.removeListener(ImageStreamListener(_onImage));
    _controller.dispose();
    super.dispose();
  }
}
