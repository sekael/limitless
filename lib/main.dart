import 'package:flutter/material.dart';
import 'package:limitless_flutter/features/quotes/data/repository.dart';
import 'package:limitless_flutter/features/quotes/data/repository_adapter.dart';
import 'package:limitless_flutter/pages/home.dart';
import 'package:limitless_flutter/theme/theme_provider.dart';
import 'package:limitless_flutter/supabase.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SupabaseClient supabase = await SupabaseBootstrap.initializeDevClient();

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
      home: const HomePage(),
    );
  }
}
