import 'package:flutter/material.dart';
import 'package:limitless_flutter/app/user/user_service.dart';
import 'package:limitless_flutter/components/background_image.dart';
import 'package:limitless_flutter/components/sliding_page_transition.dart';
import 'package:limitless_flutter/config/theme/theme_provider.dart';
import 'package:limitless_flutter/core/supabase/bootstrap.dart';
import 'package:limitless_flutter/features/quotes/data/quotes_repository.dart';
import 'package:limitless_flutter/features/quotes/data/quotes_repository_adapter.dart';
import 'package:limitless_flutter/features/user_profile/data/user_profile_repository_adapter.dart';
import 'package:limitless_flutter/pages/dashboard_gate.dart';
import 'package:limitless_flutter/pages/email_authentication.dart';
import 'package:limitless_flutter/pages/home.dart';
import 'package:limitless_flutter/pages/login.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/theme/theme.dart';

// TODO: validators on profile data inputs
// TODO: edit/delete existing cookies
// TODO: better snackbar text after adding a cookie
// TODO: shorter text on registration page for mobile
// TODO: welcome banner on dashboard wording
// TODO: enable languages DE, JP

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SupabaseClient supabase = await initializeClientFromFile('prod.env');

  runApp(
    MultiProvider(
      providers: [
        Provider<QuotesRepository>(
          create: (_) => QuotesRepositoryAdapter(supabase),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              UserService(userProfileRepository: UserProfileRepositoryAdapter())
                ..init(),
        ),
      ],
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: provider.mode,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [AnimatedBackground(), child ?? const SizedBox.shrink()],
        );
      },
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return SlideRightToLeftPageRoute(
              builder: (_) => const HomePage(),
              settings: settings,
            );
          case '/login':
            return SlideRightToLeftPageRoute(
              builder: (_) => const LoginPage(),
              settings: settings,
            );
          case '/verify':
            return SlideRightToLeftPageRoute(
              builder: (_) => const EmailOtpVerificationPage(),
              settings: settings,
            );
          case '/dashboard':
            return SlideRightToLeftPageRoute(
              builder: (_) => const DashboardGate(),
              settings: settings,
            );
          default:
            return SlideRightToLeftPageRoute(
              builder: (_) => const HomePage(),
              settings: settings,
            );
        }
      },
    );
  }
}
