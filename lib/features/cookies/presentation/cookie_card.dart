import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/text/icon.dart';

class CookieCard extends StatelessWidget {
  const CookieCard({
    super.key,
    required this.text,
    this.createdAt,
    this.onClose,
    this.onBake,
  });

  final String text;
  final DateTime? createdAt;
  final VoidCallback? onClose;
  final VoidCallback? onBake;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const TextIcon(icon: '🍪', semanticLabel: 'Cookie'),
        const SizedBox(height: 12),
        Text(
          '"$text"',
          style: t.titleLarge!.copyWith(
            fontStyle: FontStyle.italic,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          textAlign: TextAlign.center,
        ),
        if (createdAt != null) ...[
          const SizedBox(height: 8),
          Text(
            'You baked this cookie on ${_formatDate(createdAt!)}',
            style: t.bodySmall!.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            if (onBake != null)
              AdaptiveGlassButton.sync(
                buttonText: 'Bake Another',
                onPressed: onBake!,
              ),
            if (onClose != null)
              AdaptiveGlassButton.sync(
                buttonText: 'Finish Eating',
                onPressed: onClose!,
              ),
          ],
        ),
      ],
    );
  }

  static String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
}
