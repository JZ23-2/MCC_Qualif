import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier(this._themeData);

  ThemeData getTheme() => _themeData;

  void setDarkMode() {
    _themeData = ThemeData.dark();
    notifyListeners();
  }

  void setLightMode() {
    _themeData = ThemeData.light();
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData.brightness == Brightness.dark) {
      setLightMode();
    } else {
      setDarkMode();
    }
  }
}
