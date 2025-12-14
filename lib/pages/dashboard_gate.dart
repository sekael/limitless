import 'package:flutter/material.dart';
import 'package:limitless_flutter/app/user/user_service.dart';
import 'package:limitless_flutter/core/logging/app_logger.dart';
import 'package:limitless_flutter/pages/dashboard.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardGate extends StatefulWidget {
  const DashboardGate({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardGateState();
}

class _DashboardGateState extends State<DashboardGate> {
  String? _lastUserId;
  bool _redirectScheduled = false;
  bool _refreshScheduled = false;

  void _scheduleProfileRefresh() {
    if (_refreshScheduled) return;
    _refreshScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _refreshScheduled = false;
      await context.read<UserService>().refreshProfile();
    });
  }

  void _scheduleRedirect(String routeName) {
    if (_redirectScheduled) return;
    _redirectScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session?>();
    final userService = context.watch<UserService>();

    // Check that user is logged in
    if (session == null) {
      _scheduleRedirect('/login');
      return const SizedBox.shrink();
    }

    if (userService.profileData == null && !userService.loadingProfile) {
      _scheduleProfileRefresh();
    }

    // Wait until latest profile data is completely fetched
    if (userService.loadingProfile || userService.signingOut) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final profile = userService.profileData;
    if (profile == null || !profile.isComplete()) {
      logger.i('Redirecting to registration page');
      _scheduleRedirect('/register');
      return const SizedBox.shrink();
    }

    logger.i('Opening dashboard');
    return const DashboardPage();
  }
}
