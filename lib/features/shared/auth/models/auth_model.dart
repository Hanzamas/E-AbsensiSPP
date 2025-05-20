class AuthModel {
  final String token;
  final String username;
  final String role;
  final bool isProfileCompleted;

  AuthModel({
    required this.token,
    required this.username,
    required this.role,
    required this.isProfileCompleted,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return AuthModel(
      token: data['token'] ?? '',
      username: data['username'] ?? '',
      role: data['role'] ?? '',
      isProfileCompleted: data['isProfileCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'username': username,
      'role': role,
      'isProfileCompleted': isProfileCompleted,
    };
  }
} 