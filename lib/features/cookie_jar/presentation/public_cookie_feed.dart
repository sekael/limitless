import 'dart:async';

import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/text/body.dart';
import 'package:limitless_flutter/components/text/icon.dart';
import 'package:limitless_flutter/features/cookie_jar/domain/cookie_service.dart';
import 'package:provider/provider.dart';

class PublicCookieFeed extends StatefulWidget {
  const PublicCookieFeed({super.key});

  @override
  State<PublicCookieFeed> createState() => _PublicCookieFeedState();
}

class _PublicCookieFeedState extends State<PublicCookieFeed> {
  // Use a FutureBuilder or a Provider for state management
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();

    // Set timer for refreshing public feed
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        context.read<CookieService>().refreshPublicFeed();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cookieService = context.watch<CookieService>();
    final publicCookies = cookieService.publicCookies;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (cookieService.loadingPublic && publicCookies.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }

    if (publicCookies.isEmpty) {
      return const CenterAlignedBodyText(
        bodyText: 'No public cookies yet. Be the first!',
      );
    }

    return ListView.separated(
      shrinkWrap: true, // Important if inside a Column/ScrollView
      physics: const NeverScrollableScrollPhysics(), // Let parent handle scroll
      itemCount: publicCookies.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final cookie = publicCookies[index];
        return Card(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.25),
          child: ListTile(
            leading: const TextIcon(icon: '🍪'),
            title: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
              child: Text(
                cookie.content,
                style: t.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: cs.primary,
                ),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Baked by ${cookie.username} • ${_timeAgo(cookie.createdAt)}',
                style: t.bodyMedium?.copyWith(
                  color: cs.tertiary.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _timeAgo(DateTime d) {
    // Simple helper or use 'timeago' package
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}
