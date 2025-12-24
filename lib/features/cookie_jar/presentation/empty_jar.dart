import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/buttons/glass_button.dart';
import 'package:limitless_flutter/components/text/icon.dart';
import 'package:limitless_flutter/features/cookie_jar/presentation/add_cookie.dart';

class EmptyJar extends StatelessWidget {
  const EmptyJar({super.key});

  final String message = 'Bake a cookie today!';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const TextIcon(icon: '🫙', semanticLabel: 'Empty Jar', fontSize: 32),
        const SizedBox(height: 12),
        Text(
          'Your cookie jar is empty',
          style: t.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: t.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AddCookieButton(),
              AdaptiveGlassButton.sync(
                buttonText: 'Not Baking Today',
                onPressed: () => Navigator.of(context).pop(),
                intent: GlassButtonIntent.secondary,
                leadingIcon: const TextIcon(
                  icon: '️🧘🏽‍♀️',
                  semanticLabel: 'Relax',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EmptyJarPageView extends StatelessWidget {
  const EmptyJarPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Cookie Jar'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(child: Center(child: EmptyJar())),
    );
  }
}
