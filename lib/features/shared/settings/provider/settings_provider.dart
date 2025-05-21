import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static final SettingsProvider _instance = SettingsProvider._internal();
  
  bool _isNotificationEnabled = true;
  bool _isDarkMode = false;
  String _language = 'Indonesia';
  bool _isLoading = false;
  
  // Private constructor
  SettingsProvider._internal() {
    _loadSettings();
  }
  
  // Singleton factory
  factory SettingsProvider() => _instance;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isNotificationEnabled => _isNotificationEnabled;
  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  
  // Setters with notifications
  set isNotificationEnabled(bool value) {
    _isNotificationEnabled = value;
    _saveSettings();
    notifyListeners();
  }
  
  set isDarkMode(bool value) {
    _isDarkMode = value;
    _saveSettings();
    notifyListeners();
  }
  
  set language(String value) {
    _language = value;
    _saveSettings();
    notifyListeners();
  }
  
  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _isNotificationEnabled = prefs.getBool('notifications_enabled') ?? true;
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _language = prefs.getString('language') ?? 'Indonesia';
    } catch (e) {
      // Gagal memuat pengaturan, gunakan nilai default
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _isNotificationEnabled);
      await prefs.setBool('dark_mode', _isDarkMode);
      await prefs.setString('language', _language);
    } catch (e) {
      // Gagal menyimpan pengaturan
    }
  }
  
  // Reset settings to defaults
  Future<void> resetSettings() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('notifications_enabled');
      await prefs.remove('dark_mode');
      await prefs.remove('language');
      
      _isNotificationEnabled = true;
      _isDarkMode = false;
      _language = 'Indonesia';
    } catch (e) {
      // Gagal mereset pengaturan
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 