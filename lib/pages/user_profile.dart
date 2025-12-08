import 'package:flutter/material.dart';
import 'package:limitless_flutter/app/user/user_service.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/buttons/glass_button.dart';
import 'package:limitless_flutter/features/user_profile/domain/user_profile_data.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final user = userService.profileData;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('My Profile Data')),
      body: SafeArea(
        child: user == null
            ? Center(child: CircularProgressIndicator.adaptive())
            : _ProfileContent(currentUser: user),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.currentUser});

  final UserProfileData? currentUser;

  @override
  Widget build(BuildContext context) {
    return ListView();
  }
}

// TODO: limit for isWide (720) should be constant instead of magic number
Future<void> showAdaptiveUserProfilePage(BuildContext context) async {
  final isWide = MediaQuery.sizeOf(context).width > 720;
  if (isWide) {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 720, maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: UserProfilePage(),
          ),
        ),
      ),
    );
  } else {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return UserProfilePage();
        },
      ),
    );
  }
}

class MyProfileButton extends StatelessWidget {
  const MyProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveGlassButton.sync(
      buttonText: 'My Profile',
      intent: GlassButtonIntent.secondary,
      onPressed: () => showAdaptiveUserProfilePage(context),
    );
  }
}
