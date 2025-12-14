import 'package:flutter/material.dart';
import 'package:limitless_flutter/app/user/user_service.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/text/body.dart';
import 'package:limitless_flutter/components/text/icon.dart';
import 'package:limitless_flutter/components/text/title.dart';
import 'package:limitless_flutter/components/theme_toggle.dart';
import 'package:limitless_flutter/config/constants.dart';
import 'package:limitless_flutter/features/cookie_jar/presentation/add_cookie.dart';
import 'package:limitless_flutter/features/cookie_jar/presentation/eat_cookie.dart';
import 'package:limitless_flutter/pages/user_profile.dart';
import 'package:provider/provider.dart';

// TODO: debug issues with login/registration page
// TODO: implement display of public cookies in dashboard (feed)
// TODO: edit/delete existing cookies
// TODO: enforce username uniqueness
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > SMALL_SCREEN_THRESHOLD;
    final userService = context.watch<UserService>();
    final userProfile = userService.getLoggedInUserProfile();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(128),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Cookie Jar'),
        backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(32),
        scrolledUnderElevation: 0,
        actions: [
          if (isWide) ...[
            MyProfileButton(),
            AdaptiveGlassButton.async(
              buttonText: userService.signingOut
                  ? 'Signing out ...'
                  : 'Log Out',
              onPressed: () async {
                userService.signingOut
                    ? null
                    : userService.handleSignOut(context);
              },
            ),
          ] else
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
        ],
      ),
      endDrawer: isWide
          ? null
          : _DashboardMenuDrawer(
              onMyProfile: () => showAdaptiveUserProfilePage(context),
              onLogout: () async {
                userService.signingOut
                    ? null
                    : userService.handleSignOut(context);
              },
            ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                // Give some breathing room at bottom becaue of ThemeToggle
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TitleText(
                      titleText:
                          'Welcome to Limitless, ${userProfile.firstName}!',
                    ),
                    const SizedBox(height: 8),
                    ..._dashboardText(context),
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

List<Widget> _dashboardText(BuildContext context) {
  return [
    const CenterAlignedBodyText(bodyText: 'This is your personal'),
    const SizedBox(height: 16),
    const TextIcon(icon: '🍯', semanticLabel: 'Honey Jar', fontSize: 32),
    const SizedBox(height: 8),
    CenterAlignedBodyText(
      bodyText: 'Cookie Jar',
      styleOverride: Theme.of(context).textTheme.titleMedium!.copyWith(
        fontStyle: FontStyle.italic,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.secondary,
      ),
    ),
    const SizedBox(height: 8),
    const CenterAlignedBodyText(
      bodyText:
          'where you can keep the sweet memories of accomplishments you have made!\n'
          'Eat a cookie if you are craving one or need a little pick-me-up.\n'
          'Bake a new one whenever you feel inspired.',
    ),
  ];
}

class _DashboardMenuDrawer extends StatelessWidget {
  const _DashboardMenuDrawer({
    required this.onMyProfile,
    required this.onLogout,
  });

  final VoidCallback onMyProfile;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 4.0),
              child: Text(
                'Dashboard',
                style: textTheme.titleLarge!.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.of(context).pop();
                onMyProfile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
                onLogout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
