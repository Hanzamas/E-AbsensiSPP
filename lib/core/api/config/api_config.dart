// core/api/config/api_config.dart
class ApiConfig {
  static const Duration timeout = Duration(seconds: 30);
  
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}