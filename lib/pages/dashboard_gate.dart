import 'package:flutter/material.dart';
import 'package:limitless_flutter/app/user/user_service.dart';
import 'package:limitless_flutter/core/logging/app_logger.dart';
import 'package:limitless_flutter/core/require_session.dart';
import 'package:limitless_flutter/main.dart';
import 'package:limitless_flutter/pages/dashboard.dart';
import 'package:provider/provider.dart';

class DashboardGate extends StatefulWidget {
  const DashboardGate({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardGateState();
}

class _DashboardGateState extends State<DashboardGate> {
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

  void _scheduleRegisterRedirect(String routeName) {
    if (_redirectScheduled) return;
    _redirectScheduled = true;

    logger.i('Scheduling redirect to registration page');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = rootNavigatorKey.currentState;
      if (navigator == null) return;
      navigator.pushReplacementNamed('/register');
    });
  }

  @override
  Widget build(BuildContext context) {
    return RequireSessionGate(
      redirectRoute: '/',
      showLoginErrorWhenNotAuthenticated: true,
      loginErrorMessage:
          'Sorry, we could not log you in correctly. Please try again.',
      child: Builder(
        builder: (context) {
          final userService = context.watch<UserService>();

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
            _scheduleRegisterRedirect('/register');
            return const SizedBox.shrink();
          }

          logger.i('Opening dashboard');
          _redirectScheduled = false;
          return const DashboardPage();
        },
      ),
    );
  }
}
