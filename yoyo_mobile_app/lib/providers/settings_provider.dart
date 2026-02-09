import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode;
  String _language;
  
  SettingsProvider({
    required bool isDarkMode,
    required String language,
  }) : 
    _isDarkMode = isDarkMode,
    _language = language;
  
  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  
  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      notifyListeners();
      _saveSettings();
    }
  }
  
  void setLanguage(String value) {
    if (_language != value) {
      _language = value;
      notifyListeners();
      _saveSettings();
    }
  }
  
  Future<void> _saveSettings() async {
    // Utilisation de SharedPreferences pour sauvegarder les paramètres
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setString('language', _language);
  }
}
