import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/text/body.dart';
import 'package:limitless_flutter/core/logging/app_logger.dart';
import 'package:limitless_flutter/core/supabase/auth.dart';
import 'package:limitless_flutter/features/user_profile/data/user_profile_repository.dart';
import 'package:limitless_flutter/features/user_profile/data/user_profile_repository_adapter.dart';
import 'package:limitless_flutter/features/user_profile/domain/user_profile_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardGate extends StatefulWidget {
  const DashboardGate({super.key, required this.dashboardBuilder});

  final WidgetBuilder dashboardBuilder;

  @override
  State<StatefulWidget> createState() => _DashboardGateState();
}

class _DashboardGateState extends State<DashboardGate> {
  final UserProfileRepository _userProfileRepository =
      UserProfileRepositoryAdapter();
  late final Future<UserProfileData?> _userProfileFuture;
  late final User? _authenticatedUser;
  bool _redirecting = false;

  @override
  void initState() {
    super.initState();
    _authenticatedUser = getCurrentUser();
    if (_authenticatedUser == null) {
      logger.e('Current user is not authenticated');
      throw Exception('Current user is not authenticated');
    }
    _userProfileFuture = _loadUserProfile();
  }

  Future<UserProfileData?> _loadUserProfile() async {
    return await _userProfileRepository.getUserById(_authenticatedUser!.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfileData?>(
      future: _userProfileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: CenterAlignedBodyText(
                bodyText: 'Sorry, something went wrong loading your profile.',
              ),
            ),
          );
        }

        final userProfileData = snapshot.data;

        // Incomplete or missing profile -> redirect to registration
        if (userProfileData == null || !userProfileData.isComplete()) {
          if (!_redirecting) {
            _redirecting = true;
            final registeringUser =
                userProfileData ?? UserProfileData(id: _authenticatedUser!.id);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed(
                '/registration',
                arguments: registeringUser,
              );
            });
          }

          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        // Profile complete -> render the dashboard
        return widget.dashboardBuilder(context);
      },
    );
  }
}
