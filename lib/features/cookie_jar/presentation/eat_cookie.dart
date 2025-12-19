import 'dart:async';

import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/error_snackbar.dart';
import 'package:limitless_flutter/components/text/icon.dart';
import 'package:limitless_flutter/features/cookie_jar/domain/cookie.dart';
import 'package:limitless_flutter/features/cookie_jar/domain/cookie_service.dart';
import 'package:limitless_flutter/features/cookie_jar/presentation/add_cookie.dart';
import 'package:limitless_flutter/features/cookie_jar/presentation/cookie_card.dart';
import 'package:limitless_flutter/features/cookie_jar/presentation/cookie_dialog.dart';
import 'package:provider/provider.dart';

class EatCookieButton extends StatelessWidget {
  const EatCookieButton({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = context.watch<CookieService>();

    return AdaptiveGlassButton.async(
      buttonText: 'Eat a Cookie',
      showSpinner: false,
      onPressed: () async {
        final cookie = await _eatCookie(context);
        if (!context.mounted) return;
        unawaited(
          showAdaptiveDialogOrPage(
            context,
            cookie == null
                ? _EmptyJar(message: 'Bake a cookie today!')
                : _CookieView(cookie: cookie),
            null,
          ),
        );
      },
      leadingIcon: const TextIcon(icon: '🍪', semanticLabel: 'Cookie'),
    );
  }
}

Future<Cookie?> _eatCookie(BuildContext context) async {
  try {
    return await context.read<CookieService>().next();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      ErrorSnackbar(
        message: 'Something went wrong trying to get your cookies.\n$e',
      ).build(),
    );
  }
  return null;
}

class _CookieView extends StatelessWidget {
  const _CookieView({required this.cookie});

  final Cookie cookie;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [CookieCard(cookie: cookie)],
    );
  }
}

class _EmptyJar extends StatelessWidget {
  const _EmptyJar({required this.message});

  final String message;

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
                onPressed: () => Navigator.of(context).maybePop(),
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
