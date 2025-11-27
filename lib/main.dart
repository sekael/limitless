import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/background_image.dart';
import 'package:limitless_flutter/components/sliding_page_transition.dart';
import 'package:limitless_flutter/core/supabase/auth.dart';
import 'package:limitless_flutter/features/cookie_jar/data/cookie_repository_adapter.dart';
import 'package:limitless_flutter/features/cookie_jar/domain/cookie_collection.dart';
import 'package:limitless_flutter/features/quotes/data/quotes_repository.dart';
import 'package:limitless_flutter/features/quotes/data/quotes_repository_adapter.dart';
import 'package:limitless_flutter/features/user_profile/domain/user_profile_data.dart';
import 'package:limitless_flutter/pages/dashboard_gate.dart';
import 'package:limitless_flutter/pages/email_authentication.dart';
import 'package:limitless_flutter/pages/home.dart';
import 'package:limitless_flutter/pages/login.dart';
import 'package:limitless_flutter/pages/dashboard.dart';
import 'package:limitless_flutter/config/theme/theme_provider.dart';
import 'package:limitless_flutter/core/supabase/bootstrap.dart';
import 'package:limitless_flutter/pages/registration.dart';
import 'package:provider/provider.dart';
import 'config/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
              builder: (context) => DashboardGate(
                dashboardBuilder: (_) {
                  final userId = getCurrentUser()!.id;
                  return ChangeNotifierProvider(
                    create: (_) => CookieCollection(
                      repository: CookieRepositoryAdapter(),
                      userId: userId,
                    )..init(),
                    child: const DashboardPage(),
                  );
                },
              ),
              settings: settings,
            );
          case '/registration':
            final args = settings.arguments as UserProfileData?;
            final authenticatedUser = getCurrentUser();
            if (authenticatedUser == null) {
              return SlideRightToLeftPageRoute(
                builder: (_) => const HomePage(),
                settings: settings,
              );
            }
            final registeringUser =
                args ?? UserProfileData(id: authenticatedUser.id);
            return SlideRightToLeftPageRoute(
              builder: (_) =>
                  RegistrationPage(registeringUser: registeringUser),
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
