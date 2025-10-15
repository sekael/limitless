import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  // Getter
  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  // Toggle state
  void toggle() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
