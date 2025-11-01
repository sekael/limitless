import 'package:flutter/material.dart';

class SlideRightToLeftPageRoute<T> extends PageRoute<T> {
  SlideRightToLeftPageRoute({
    required this.builder,
    super.settings,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
  });

  final WidgetBuilder builder;
  final Duration duration;
  final Curve curve;

  @override
  Duration get transitionDuration => duration;
  @override
  bool get opaque => true;
  @override
  bool get barrierDismissible => false;
  @override
  Color? get barrierColor => null;
  @override
  String? get barrierLabel => null;
  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final inAnim = CurvedAnimation(parent: animation, curve: curve);
    final outAnim = CurvedAnimation(parent: secondaryAnimation, curve: curve);

    // Incoming: from right → center
    final inSlide = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(inAnim);

    // Outgoing (when a new route is pushed on top of THIS one):
    // from center → left (fully off-screen)
    final outSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(outAnim);

    // When this route is *incoming*, secondaryAnimation is 0,
    // so only the first SlideTransition has effect.
    // When another route is pushed, this route’s buildTransitions
    // runs again and the second SlideTransition moves it out.
    return SlideTransition(
      position: inSlide,
      child: SlideTransition(position: outSlide, child: child),
    );
  }
}
