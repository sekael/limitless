import 'package:flutter/material.dart';
import 'package:limitless_flutter/app/user/user_service.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/buttons/glass_button.dart';
import 'package:limitless_flutter/config/constants.dart';
import 'package:limitless_flutter/features/user_profile/domain/user_profile_data.dart';
import 'package:limitless_flutter/features/user_profile/presentation/account_details.dart';
import 'package:provider/provider.dart';

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

Future<void> showAdaptiveUserProfilePage(BuildContext context) async {
  final isWide = MediaQuery.sizeOf(context).width > SMALL_SCREEN_THRESHOLD;

  if (isWide) {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const UserDialog(),
    );
  } else {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return const UserProfilePage();
        },
      ),
    );
  }
}

class UserDialog extends StatelessWidget {
  const UserDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final user = userService.profileData;

    return Dialog(
      insetPadding: EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: SMALL_SCREEN_THRESHOLD,
          maxWidth: SMALL_SCREEN_MAX_WIDTH,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: user == null
              ? SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              : _ProfileContent(currentUser: user),
        ),
      ),
    );
  }
}

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
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: _ProfileContent(currentUser: user),
              ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.currentUser});

  final UserProfileData currentUser;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withValues(alpha: 0.25),
                colorScheme.secondary.withValues(alpha: 0.15),
              ],
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.primary,
                child: Text(
                  currentUser.firstName!.isNotEmpty
                      ? currentUser.firstName![0].toUpperCase()
                      : '?',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hey ${currentUser.firstName}!',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'We are happy to have you on Limitless.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const AccountDetails(),
      ],
    );
  }
}
