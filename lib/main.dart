import 'package:flutter/material.dart';
import 'package:limitless_flutter/pages/home.dart';
import 'theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MainApp(lightTheme: lightMode, darkTheme: darkMode));
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
