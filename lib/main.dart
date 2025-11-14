import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/background_image.dart';
import 'package:limitless_flutter/components/sliding_page_transition.dart';
import 'package:limitless_flutter/features/quotes/data/quotes_repository.dart';
import 'package:limitless_flutter/features/quotes/data/quotes_repository_adapter.dart';
import 'package:limitless_flutter/pages/email_authentication.dart';
import 'package:limitless_flutter/pages/home.dart';
import 'package:limitless_flutter/pages/login.dart';
import 'package:limitless_flutter/pages/dashboard.dart';
import 'package:limitless_flutter/config/theme/theme_provider.dart';
import 'package:limitless_flutter/core/supabase/bootstrap.dart';
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
      child: const MainApp(),
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
              builder: (_) => const DashboardPage(),
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
