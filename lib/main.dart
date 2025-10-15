import 'package:flutter/material.dart';
import 'package:limitless_flutter/pages/home.dart';
import 'package:limitless_flutter/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
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
