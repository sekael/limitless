import 'package:flutter/material.dart';
import 'package:limitless_flutter/app/user/user_service.dart';
import 'package:limitless_flutter/core/logging/app_logger.dart';
import 'package:limitless_flutter/main.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequireSessionGate extends StatefulWidget {
  const RequireSessionGate({
    super.key,
    required this.child,
    this.redirectRoute = '/',
    this.showLoginErrorWhenNotAuthenticated = false,
    this.loginErrorMessage,
  });

  final Widget child;
  final String redirectRoute;
  final bool showLoginErrorWhenNotAuthenticated;
  final String? loginErrorMessage;

  @override
  State<RequireSessionGate> createState() => _RequireSessionGateState();
}

class _RequireSessionGateState extends State<RequireSessionGate> {
  bool _redirectScheduled = false;

  void _scheduleRedirect({required bool showSnackBar}) {
    if (_redirectScheduled) return;
    _redirectScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = rootNavigatorKey.currentState;
      if (navigator == null) return;

      if (showSnackBar && widget.loginErrorMessage != null) {
        rootMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(widget.loginErrorMessage!)),
        );
      }
      navigator.pushNamedAndRemoveUntil(widget.redirectRoute, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session?>();
    final supabaseSession = Supabase.instance.client.auth.currentSession;
    final signingOut = context.select<UserService, bool>((s) => s.signingOut);

    // Fall back to in-memory session state if the StreamProvider has not updated yet
    final effectiveSession = session ?? supabaseSession;

    if (effectiveSession == null) {
      if (!_redirectScheduled) {
        logger.w(
          'No active user session available, scheduling redirect to ${widget.redirectRoute}',
        );
      }

      // If log out is intentional, do not show snackbar
      final showSnackBar =
          widget.showLoginErrorWhenNotAuthenticated && !signingOut;
      _scheduleRedirect(showSnackBar: showSnackBar);
      return const SizedBox.shrink();
    }
    // If session still extists or exists again, allow future redirects
    _redirectScheduled = false;

    return widget.child;
  }
}
