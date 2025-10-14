import 'package:flutter/material.dart';
import 'package:limitless_flutter/pages/home.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final (light, dark) = await AppTheme.buildAdaptiveThemes();

  runApp(MainApp(lightTheme: light, darkTheme: dark));
}

class MainApp extends StatelessWidget {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  const MainApp({super.key, required this.lightTheme, required this.darkTheme});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
