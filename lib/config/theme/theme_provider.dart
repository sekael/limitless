import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  // Getter
  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  // Set mode explicitly
  void setMode(ThemeMode m) {
    if (m != _mode) {
      _mode = m;
      notifyListeners();
    }
  }
}
