import 'dart:async';

import 'package:flutter/material.dart';
import 'package:limitless_flutter/app/user/user_service.dart';
import 'package:limitless_flutter/components/background_image.dart';
import 'package:limitless_flutter/components/sliding_page_transition.dart';
import 'package:limitless_flutter/config/theme/theme_provider.dart';
import 'package:limitless_flutter/core/supabase/bootstrap.dart';
import 'package:limitless_flutter/features/cookie_jar/data/cookie_repository.dart';
import 'package:limitless_flutter/features/cookie_jar/data/cookie_repository_adapter.dart';
import 'package:limitless_flutter/features/cookie_jar/domain/cookie_service.dart';
import 'package:limitless_flutter/features/quotes/data/quotes_repository.dart';
import 'package:limitless_flutter/features/quotes/data/quotes_repository_adapter.dart';
import 'package:limitless_flutter/features/user_profile/data/user_profile_repository_adapter.dart';
import 'package:limitless_flutter/pages/dashboard_gate.dart';
import 'package:limitless_flutter/pages/email_authentication.dart';
import 'package:limitless_flutter/pages/home.dart';
import 'package:limitless_flutter/pages/login.dart';
import 'package:limitless_flutter/pages/registration_gate.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/theme/theme.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> rootMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeClientFromFile('prod.env');

  runApp(
    MultiProvider(
      providers: [
        StreamProvider<Session?>(
          create: (_) => Supabase.instance.client.auth.onAuthStateChange.map(
            (data) => data.session,
          ),
          initialData: Supabase.instance.client.auth.currentSession,
          catchError: (context, error) => null,
        ),
        Provider<QuotesRepository>(create: (_) => QuotesRepositoryAdapter()),
        Provider<CookieRepository>(create: (_) => CookieRepositoryAdapter()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              UserService(userProfileRepository: UserProfileRepositoryAdapter())
                ..init(),
        ),
        // CookieService depends on the user being logged in (hence the proxy provider with Session)
        ChangeNotifierProxyProvider<Session?, CookieService>(
          create: (context) =>
              CookieService(repository: context.read<CookieRepository>()),
          update: (context, session, cookieService) {
            // If cookieService is currently null, initialize it with CookieRepository
            cookieService ??= CookieService(
              repository: context.read<CookieRepository>(),
            );
            unawaited(cookieService.setUser(session?.user.id));
            return cookieService;
          },
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
      navigatorKey: rootNavigatorKey,
      scaffoldMessengerKey: rootMessengerKey,
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
          case '/register':
            return SlideRightToLeftPageRoute(
              builder: (_) => const RegistrationGate(),
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
