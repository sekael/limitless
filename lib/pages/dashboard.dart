import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/error_snackbar.dart';
import 'package:limitless_flutter/components/text/body.dart';
import 'package:limitless_flutter/components/text/icon.dart';
import 'package:limitless_flutter/components/text/title.dart';
import 'package:limitless_flutter/components/theme_toggle.dart';
import 'package:limitless_flutter/features/cookie_jar/presentation/eat_cookie.dart';
import 'package:limitless_flutter/features/cookie_jar/presentation/add_cookie.dart';
import 'package:limitless_flutter/core/supabase/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _signingOut = false;

  Future<void> _handleSignOut() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    try {
      await signOut();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorSnackbar(
          message: 'Error trying to log you out: ${e.message}',
        ).build(),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorSnackbar(message: 'Unexpected error during log out').build(),
      );
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(128),
      appBar: AppBar(
        title: const Text('Limitless'),
        backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(32),
        scrolledUnderElevation: 0,
        actions: [
          AdaptiveGlassButton.async(
            buttonText: _signingOut ? 'Signing out ...' : 'Log Out',
            onPressed: () async {
              _signingOut ? null : _handleSignOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: FractionalOffset(0.5, 0.25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const TitleText(titleText: 'Welcome to Limitless!'),
                    const SizedBox(height: 8),
                    const TextIcon(
                      icon: '🍯',
                      semanticLabel: 'Honey Jar',
                      fontSize: 32,
                    ),
                    const SizedBox(height: 16),
                    const CenterAlignedBodyText(
                      bodyText: 'This is your personal cookie jar!',
                    ),
                    const CenterAlignedBodyText(
                      bodyText:
                          'Eat a cookie if you are craving one or bake a new one whenever you feel inspired.',
                    ),
                    // Spacer between text and buttons
                    const SizedBox(height: 12),
                    SizedBox(width: 250, child: EatCookieButton()),
                    SizedBox(width: 250, child: AddCookieButton()),
                  ],
                ),
              ),
            ),
            PositionedDirectional(bottom: 0, end: 0, child: ThemeToggle()),
          ],
        ),
      ),
    );
  }
}
