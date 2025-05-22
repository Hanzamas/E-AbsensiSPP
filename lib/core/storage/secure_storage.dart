// core/storage/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory SecureStorage() => _instance;
  SecureStorage._internal();

  /// Simpan token autentikasi
  Future<void> saveToken(String token) async => await _storage.write(key: 'token', value: token);

  /// Ambil token autentikasi
  Future<String?> getToken() async => await _storage.read(key: 'token');

  /// Hapus token autentikasi
  Future<void> deleteToken() async => await _storage.delete(key: 'token');

  /// Simpan role user
  Future<void> saveUserRole(String role) async => await _storage.write(key: 'user_role', value: role);

  /// Ambil role user
  Future<String?> getUserRole() async => await _storage.read(key: 'user_role');

  /// Baca data dengan key custom
  Future<String?> read(String key) async => await _storage.read(key: key);

  /// Simpan data dengan key custom
  Future<void> write(String key, String value) async => await _storage.write(key: key, value: value);

  /// Hapus data dengan key custom
  Future<void> delete(String key) async => await _storage.delete(key: key);

  /// Hapus semua data di storage
  Future<void> clearAll() async => await _storage.deleteAll();
}