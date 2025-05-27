import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static final SettingsProvider _instance = SettingsProvider._internal();
  
  // Pengaturan yang sudah ada
  bool _isNotificationEnabled = true;
  bool _isDarkMode = false;
  String _language = 'Indonesia';
  bool _isLoading = false;
  
  // Pengaturan baru untuk konteks E-AbsensiSPP
  bool _isAutoLogoutEnabled = false;
  bool _isSPPNotificationEnabled = true;
  bool _isAttendanceNotificationEnabled = true;
  String _textSize = 'Normal';
  
  // Private constructor
  SettingsProvider._internal() {
    _loadSettings();
  }
  
  // Singleton factory
  factory SettingsProvider() => _instance;
  
  // Getters yang sudah ada
  bool get isLoading => _isLoading;
  bool get isNotificationEnabled => _isNotificationEnabled;
  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  
  // Getter baru
  bool get isAutoLogoutEnabled => _isAutoLogoutEnabled;
  bool get isSPPNotificationEnabled => _isSPPNotificationEnabled;
  bool get isAttendanceNotificationEnabled => _isAttendanceNotificationEnabled;
  String get textSize => _textSize;
  
  // Setters yang sudah ada dengan notifikasi
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
  
  // Setters baru
  set isAutoLogoutEnabled(bool value) {
    _isAutoLogoutEnabled = value;
    _saveSettings();
    notifyListeners();
  }
  
  set isSPPNotificationEnabled(bool value) {
    _isSPPNotificationEnabled = value;
    _saveSettings();
    notifyListeners();
  }
  
  set isAttendanceNotificationEnabled(bool value) {
    _isAttendanceNotificationEnabled = value;
    _saveSettings();
    notifyListeners();
  }
  
  set textSize(String value) {
    _textSize = value;
    _saveSettings();
    notifyListeners();
  }
  
  // Load settings dari SharedPreferences
  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      // Pengaturan yang sudah ada
      _isNotificationEnabled = prefs.getBool('notifications_enabled') ?? true;
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _language = prefs.getString('language') ?? 'Indonesia';
      
      // Pengaturan baru
      _isAutoLogoutEnabled = prefs.getBool('auto_logout_enabled') ?? false;
      _isSPPNotificationEnabled = prefs.getBool('spp_notification_enabled') ?? true;
      _isAttendanceNotificationEnabled = prefs.getBool('attendance_notification_enabled') ?? true;
      _textSize = prefs.getString('text_size') ?? 'Normal';
    } catch (e) {
      // Gagal memuat pengaturan, gunakan nilai default
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Save settings ke SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Simpan pengaturan yang sudah ada
      await prefs.setBool('notifications_enabled', _isNotificationEnabled);
      await prefs.setBool('dark_mode', _isDarkMode);
      await prefs.setString('language', _language);
      
      // Simpan pengaturan baru
      await prefs.setBool('auto_logout_enabled', _isAutoLogoutEnabled);
      await prefs.setBool('spp_notification_enabled', _isSPPNotificationEnabled);
      await prefs.setBool('attendance_notification_enabled', _isAttendanceNotificationEnabled);
      await prefs.setString('text_size', _textSize);
    } catch (e) {
      // Gagal menyimpan pengaturan
      debugPrint('Error saving settings: $e');
    }
  }
  
  // Reset settings ke nilai default
  Future<void> resetSettings() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      // Hapus pengaturan yang sudah ada
      await prefs.remove('notifications_enabled');
      await prefs.remove('dark_mode');
      await prefs.remove('language');
      
      // Hapus pengaturan baru
      await prefs.remove('auto_logout_enabled');
      await prefs.remove('spp_notification_enabled');
      await prefs.remove('attendance_notification_enabled');
      await prefs.remove('text_size');
      
      // Set ke nilai default
      _isNotificationEnabled = true;
      _isDarkMode = false;
      _language = 'Indonesia';
      _isAutoLogoutEnabled = false;
      _isSPPNotificationEnabled = true;
      _isAttendanceNotificationEnabled = true;
      _textSize = 'Normal';
    } catch (e) {
      // Gagal mereset pengaturan
      debugPrint('Error resetting settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}