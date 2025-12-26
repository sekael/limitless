import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/buttons/glass_button.dart';
import 'package:limitless_flutter/components/text/icon.dart';
import 'package:limitless_flutter/core/logging/app_logger.dart';
import 'package:limitless_flutter/features/cookie_jar/domain/cookie.dart';
import 'package:limitless_flutter/features/cookie_jar/domain/cookie_service.dart';
import 'package:limitless_flutter/main.dart';
import 'package:provider/provider.dart';

class CookieCard extends StatelessWidget {
  const CookieCard({
    super.key,
    required this.cookie,
    this.onEditCookie,
    this.onDisplayNext,
    this.displayClose = false,
  });

  final Cookie cookie;
  final VoidCallback? onEditCookie;
  final Future<void> Function()? onDisplayNext;
  final bool displayClose;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        if (displayClose)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              tooltip: 'Close',
              style: IconButton.styleFrom(
                backgroundColor: cs.surfaceContainerHighest,
                foregroundColor: cs.onSurfaceVariant,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Column(
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
                cookie.isPublic
                    ? 'This cookie is shared with other users'
                    : 'Only you can eat this cookie',
                style: t.bodyMedium!.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.tertiary,
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
                      onPressed: onEditCookie,
                      intent: GlassButtonIntent.secondary,
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: AdaptiveGlassButton.sync(
                      buttonText: 'Delete this Cookie',
                      leadingIcon: Icon(Icons.delete_forever_outlined),
                      onPressed: () => _deleteCurrentCookie(context),
                      intent: GlassButtonIntent.secondary,
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: AdaptiveGlassButton.sync(
                      buttonText: 'Eat another Cookie',
                      leadingIcon: Icon(Icons.replay_rounded),
                      onPressed: onDisplayNext,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _deleteCurrentCookie(BuildContext context) async {
    try {
      logger.i('Deleting current cookie with id ${cookie.id}');
      await context.read<CookieService>().deleteCookie(cookie);
    } finally {
      logger.i('Successfully deleted cookie');
      rootMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Your cookie was successfully deleted.')),
      );
      rootNavigatorKey.currentState?.pop();
    }
  }

  static String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
}
