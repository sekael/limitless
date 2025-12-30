import 'package:flutter/material.dart';
import 'package:limitless_flutter/app/user/user_service.dart';
import 'package:limitless_flutter/components/adaptive_display.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/text/body.dart';
import 'package:limitless_flutter/components/text/icon.dart';
import 'package:limitless_flutter/components/text/title.dart';
import 'package:limitless_flutter/components/theme_toggle.dart';
import 'package:limitless_flutter/config/constants.dart';
import 'package:limitless_flutter/features/cookie_jar/presentation/add_cookie.dart';
import 'package:limitless_flutter/features/cookie_jar/presentation/eat_cookie.dart';
import 'package:limitless_flutter/features/cookie_jar/presentation/public_cookie_feed.dart';
import 'package:limitless_flutter/pages/user_profile.dart';
import 'package:provider/provider.dart';

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
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0.75),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Cookie Jar'),
        backgroundColor: Theme.of(context).colorScheme.surfaceBright,
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
                    : await context.read<UserService>().handleSignOut();
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
              onMyProfile: () => showAdaptiveDialogOrPage(
                context,
                ProfileContent(currentUser: userProfile),
                UserProfilePage(),
              ),
              onLogout: () async {
                userService.signingOut
                    ? null
                    : await context.read<UserService>().handleSignOut();
              },
            ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SectionHeaderDelegate(
                    title: 'Community Cookies',
                    textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    height: 50,
                  ),
                  pinned: true,
                ),
                SliverToBoxAdapter(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: SMALL_SCREEN_THRESHOLD,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: PublicCookieFeed(),
                    ),
                  ),
                ),
                // Add padding for theme toggle
                SliverPadding(padding: EdgeInsetsGeometry.only(bottom: 80.0)),
              ],
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

class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final TextStyle? textStyle;
  final double height;

  _SectionHeaderDelegate({
    required this.title,
    this.textStyle,
    required this.height,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    const double fadeDistance = 50.0;
    final double opacity = (shrinkOffset / fadeDistance).clamp(0.0, 1.0);
    final cs = Theme.of(context).colorScheme;

    final backgroundColor = cs.surfaceBright.withValues(alpha: opacity);
    final shadowColor = cs.shadow.withValues(alpha: opacity * 0.1);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: shadowColor, width: 2.0)),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(title, style: textStyle),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _SectionHeaderDelegate oldDelegate) {
    return oldDelegate.title != title || oldDelegate.textStyle != textStyle;
  }
}
