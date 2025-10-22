import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:limitless_flutter/features/quotes/data/repository.dart';
import 'package:limitless_flutter/features/quotes/data/repository_adapter.dart';
import 'package:limitless_flutter/pages/home.dart';
import 'package:limitless_flutter/theme/theme_provider.dart';
import 'package:limitless_flutter/supabase.dart';
import 'package:provider/provider.dart';
import 'package:talker/talker.dart';
import 'theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: implement user login flow
final talker = Talker(
  settings: TalkerSettings(
    enabled: true,
    useHistory: true,
    maxHistoryItems: 10000,
    useConsoleLogs: true,
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    talker.error('Flutter error', details.exception, details.stack);
    FlutterError.presentError(details);
  };

  SupabaseClient supabase = await SupabaseBootstrap.initializeDevClient();

  runZonedGuarded(
    () {
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
    },
    (error, stack) {
      talker.handle(error, stack, 'Uncaught zone error');
    },
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
      home: const HomePage(),
    );
  }
}
