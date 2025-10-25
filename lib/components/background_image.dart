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

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  @override
  void didChangeDependencies() {
    precacheImage(AssetImage(widget.lightBackgroundImage), context);
    precacheImage(AssetImage(widget.darkBackgroundImage), context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkNow = Theme.of(context).brightness == Brightness.dark;
    final backgroundImage = isDarkNow
        ? widget.darkBackgroundImage
        : widget.lightBackgroundImage;

    // Darken or brighten image depending on theme
    final Color scrimColor = isDarkNow
        ? Colors.black.withAlpha(64)
        : Colors.white.withAlpha(64);

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: widget.fadeDuration,
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          layoutBuilder: (currentChild, previousChildren) => Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          ),
          child: Image.asset(
            backgroundImage,
            key: ValueKey(backgroundImage),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),

        // Animate the overlay color
        TweenAnimationBuilder(
          tween: ColorTween(end: scrimColor),
          duration: widget.fadeDuration,
          builder: (_, color, _) => Container(color: color),
        ),
      ],
    );
  }
}
