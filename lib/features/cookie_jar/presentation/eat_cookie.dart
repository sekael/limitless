import 'dart:async';

import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/error_snackbar.dart';
import 'package:limitless_flutter/components/text/icon.dart';
import 'package:limitless_flutter/features/cookie_jar/data/cookie_repository_adapter.dart';
import 'package:limitless_flutter/features/cookie_jar/domain/cookie.dart';
import 'package:limitless_flutter/features/cookie_jar/presentation/add_cookie.dart';
import 'package:limitless_flutter/features/cookie_jar/presentation/cookie_card.dart';
import 'package:limitless_flutter/supabase/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<Cookie?> _eatCookie(BuildContext context) async {
  final user = getCurrentUser();

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      ErrorSnackbar(message: 'You must be logged in to add a cookie.').build(),
    );
    return null;
  }

  try {
    return CookieRepositoryAdapter().getRandomCookieForUser(user.id);
  } on AuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      ErrorSnackbar(
        message:
            'We could not fetch your cookies because you are not authenticated.\n${e.message}',
      ).build(),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      ErrorSnackbar(
        message: 'Something went wrong trying to get your cookies.\n$e',
      ).build(),
    );
  }
  return null;
}

Future<void> _showCookieSheet(BuildContext context, {required Widget child}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: false,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: child,
      ),
    ),
  );
}

class _CookieView extends StatelessWidget {
  const _CookieView({required this.cookie});

  final Cookie cookie;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CookieCard(
          cookie: cookie,
          onClose: () => Navigator.of(context).maybePop(),
        ),
      ],
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
        const TextIcon(icon: '🥣', semanticLabel: 'Empty Jar'),
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
        // TODO: align width of buttons
        AddCookieButton(),
        AdaptiveGlassButton.sync(
          buttonText: 'Not Baking Today',
          onPressed: () => Navigator.of(context).maybePop(),
          leadingIcon: const TextIcon(icon: '💆', semanticLabel: 'Relax'),
        ),
      ],
    );
  }
}

class EatCookieButton extends StatelessWidget {
  const EatCookieButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveGlassButton.async(
      buttonText: 'Eat a Cookie',
      onPressed: () async {
        final cookie = await _eatCookie(context);
        if (!context.mounted) return;
        if (cookie == null) {
          unawaited(
            _showCookieSheet(
              context,
              child: _EmptyJar(message: 'Bake a cookie today!'),
            ),
          );
          return;
        }
        unawaited(
          _showCookieSheet(context, child: _CookieView(cookie: cookie)),
        );
      },
      leadingIcon: const TextIcon(icon: '🍪', semanticLabel: 'Cookie'),
    );
  }
}
