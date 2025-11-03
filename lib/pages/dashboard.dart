import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/button.dart';
import 'package:limitless_flutter/components/error_snackbar.dart';
import 'package:limitless_flutter/components/text/title.dart';
import 'package:limitless_flutter/supabase/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: implement dashboard
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
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(12),
      appBar: AppBar(
        title: const Text('Welcome to Limitless!'),
        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(12),
        scrolledUnderElevation: 0,
        actions: [
          AdaptiveButton(
            buttonText: _signingOut ? 'Signing out ...' : 'Log Out',
            onPressed: () {
              _signingOut ? null : _handleSignOut();
            },
          ),
        ],
      ),
      body: Center(child: const TitleText(titleText: 'Welcome to Limitless!')),
    );
  }
}
