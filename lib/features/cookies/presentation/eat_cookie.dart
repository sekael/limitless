import 'dart:math';

import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/error_snackbar.dart';
import 'package:limitless_flutter/components/text/icon.dart';
import 'package:limitless_flutter/components/text/title.dart';
import 'package:limitless_flutter/features/cookies/presentation/add_cookie.dart';
import 'package:limitless_flutter/supabase/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase database definitions
const _table = 'accomplishments';
const _textColumn = 'content';

Future<void> _eatCookie(BuildContext context) async {
  final client = getSupabaseClient();
  final user = getCurrentUser();

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      ErrorSnackbar(message: 'You must be logged in to add a cookie.').build(),
    );
    return;
  }

  final userId = user.id;

  try {
    final rows = await client
        .from(_table)
        .select('id, $_textColumn, created_at')
        .eq('user_id', userId);
    if (rows.isEmpty) {
      await _showCookieSheet(
        context,
        child: _EmptyJar(
          message:
              'Your cookie jar is empty.\nBake a cookie to celebrate a win!',
        ),
      );
      return;
    }

    final i = Random().nextInt(rows.length);
    final row = rows[i];
    final String cookieText = (row[_textColumn] ?? '').toString();
    final DateTime? createdAt = _tryParseDateTime(row['created_at']);

    await _showCookieSheet(
      context,
      child: _CookieView(text: cookieText, createdAt: createdAt),
    );
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
        message: 'Something went wrong trying to get your cookies.',
      ).build(),
    );
  }
}

DateTime? _tryParseDateTime(dynamic value) {
  if (value == null) return null;
  try {
    return DateTime.parse(value.toString());
  } catch (_) {
    return null;
  }
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
  const _CookieView({required this.text, this.createdAt});

  final String text;
  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const TextIcon(icon: '🍪', semanticLabel: 'Cookie'),
        const SizedBox(height: 12),
        TitleText(titleText: 'You ate a cookie!'),
        const SizedBox(height: 12),
        // The accomplishment itself
        Text(
          '“$text”',
          style: t.headlineSmall?.copyWith(
            fontStyle: FontStyle.italic,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),

          textAlign: TextAlign.center,
        ),
        if (createdAt != null) ...[
          const SizedBox(height: 8),
          Text(
            'Saved on ${_formatDate(createdAt!)}',
            style: t.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('Nice!'),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${_twoDigit(dt.day)}.${_twoDigit(dt.month)}.${dt.year}';
  }

  String _twoDigit(int value) => value < 10 ? '0$value' : '$value';
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
          'Cookie Jar Empty',
          style: t.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(message, style: t.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        AddCookieButton(),
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
      onPressed: () => _eatCookie(context),
      leadingIcon: const TextIcon(icon: '🍪', semanticLabel: 'Cookie'),
    );
  }
}
