import 'package:flutter/material.dart';
import 'package:limitless_flutter/app/user/user_service.dart';
import 'package:limitless_flutter/core/logging/app_logger.dart';
import 'package:limitless_flutter/features/cookie_jar/data/cookie_repository_adapter.dart';
import 'package:limitless_flutter/features/cookie_jar/domain/cookie_collection.dart';
import 'package:limitless_flutter/pages/dashboard.dart';
import 'package:limitless_flutter/pages/registration.dart';
import 'package:provider/provider.dart';

class DashboardGate extends StatefulWidget {
  const DashboardGate({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardGateState();
}

class _DashboardGateState extends State<DashboardGate> {
  bool _requestedProfile = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_requestedProfile) {
      _requestedProfile = true;
      final userService = context.read<UserService>();

      if (userService.isLoggedIn) {
        userService.refreshProfile();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final profile = userService.profileData;

    if (userService.loadingProfile || userService.signingOut) {
      logger.i(
        'loadingProfile = ${userService.loadingProfile}, signingOut = ${userService.signingOut}',
      );
      return Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (!userService.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      });
      return const SizedBox.shrink();
    }

    if (profile == null || !profile.isComplete()) {
      return const RegistrationPage();
    }

    return ChangeNotifierProvider(
      create: (_) => CookieCollection(
        repository: CookieRepositoryAdapter(),
        userId: profile.id,
      )..init(),
      child: const DashboardPage(),
    );
  }
}
