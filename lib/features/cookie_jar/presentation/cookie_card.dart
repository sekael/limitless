import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/buttons/glass_button.dart';
import 'package:limitless_flutter/components/text/icon.dart';
import 'package:limitless_flutter/features/cookie_jar/domain/cookie.dart';

class CookieCard extends StatelessWidget {
  const CookieCard({super.key, required this.cookie});

  final Cookie cookie;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const TextIcon(icon: '🍪', semanticLabel: 'Cookie', fontSize: 32),
        const SizedBox(height: 12),
        Text(
          cookie.content,
          style: t.titleLarge!.copyWith(
            fontStyle: FontStyle.normal,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'You baked this cookie on ${_formatDate(cookie.createdAt)}',
          style: t.bodySmall!.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              child: AdaptiveGlassButton.sync(
                buttonText: 'Edit this Cookie',
                leadingIcon: Icon(Icons.edit),
                onPressed: () {},
              ),
            ),
            SizedBox(
              width: 200,
              child: AdaptiveGlassButton.sync(
                buttonText: 'Delete this Cookie',
                leadingIcon: Icon(Icons.delete_forever_outlined),
                onPressed: () {},
                intent: GlassButtonIntent.secondary,
              ),
            ),
            SizedBox(
              width: 200,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close Cookie'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
}
