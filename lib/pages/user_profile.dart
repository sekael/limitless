import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:limitless_flutter/app/user/user_service.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/buttons/glass_button.dart';
import 'package:limitless_flutter/config/constants.dart';
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

  final UserProfileData currentUser;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final country = Country.tryParse(currentUser.country!);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withValues(alpha: 0.12),
                colorScheme.secondary.withValues(alpha: 0.06),
              ],
            ),
          ),
          child: Row(
            children: [
              // Simple avatar with initials
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
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
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
        const SizedBox(height: 24),
        // Account details card
        Card(
          elevation: 0,
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Details',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 12),
                _ProfileFieldTile(
                  label: 'Username',
                  value: currentUser.username!,
                ),
                _ProfileFieldTile(
                  label: 'First Name',
                  value: currentUser.firstName!,
                ),
                _ProfileFieldTile(
                  label: 'Last Name',
                  value: currentUser.lastName!,
                ),
                _ProfileFieldTile(
                  label: 'Date of Birth',
                  value: currentUser.prettyPrintBirthday(),
                ),
                _ProfileFieldTile(
                  label: 'Country of Residence',
                  value: country == null ? currentUser.country! : country.name,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileFieldTile extends StatelessWidget {
  const _ProfileFieldTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.7,
                    ),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showAdaptiveUserProfilePage(BuildContext context) async {
  final isWide = MediaQuery.sizeOf(context).width > SMALL_SCREEN_THRESHOLD;
  if (isWide) {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: SMALL_SCREEN_THRESHOLD,
            maxWidth: SMALL_SCREEN_MAX_WIDTH,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
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
