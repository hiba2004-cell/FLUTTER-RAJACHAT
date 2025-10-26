import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Key for saving the preference
const String THEME_KEY = "theme_preference";

class ThemeProvider with ChangeNotifier {
  // Initial state (defaults to light mode)
  bool _darkTheme = false;

  bool get dark => _darkTheme;

  ThemeProvider() {
    // Load preference when the provider is created
    _loadFromPrefs();
  }

  // --- Core Functions ---

  // 1. Toggles the theme and saves the new value
  void toggleTheme() {
    _darkTheme = !_darkTheme;
    _saveToPrefs();
    notifyListeners();
  }

  // 2. Loads the theme preference from storage
  void _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // Get the saved boolean; default to false (light mode) if no preference is found
    _darkTheme = prefs.getBool(THEME_KEY) ?? false;
    notifyListeners();
  }

  // 3. Saves the current theme preference to storage
  void _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(THEME_KEY, _darkTheme);
  }
}
