// Semua model untuk fitur auth

class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class LoginResponse {
  final bool status;
  final String message;
  final LoginData data;

  LoginResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: LoginData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class LoginData {
  final String token;
  final int idUser;
  final String username;
  final String role;
  final bool isProfileCompleted;

  LoginData({
    required this.token,
    required this.idUser,
    required this.username,
    required this.role,
    required this.isProfileCompleted,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'] as String,
      idUser: json['id_user'] as int,
      username: json['username'] as String,
      role: json['role'] as String,
      isProfileCompleted: json['isProfileCompleted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'id_user': idUser,
      'username': username,
      'role': role,
      'isProfileCompleted': isProfileCompleted,
    };
  }
}

class ForgotPasswordResponse {
  final bool status;
  final String message;
  final String? token;

  ForgotPasswordResponse({
    required this.status,
    required this.message,
    this.token,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      token: json['token'] as String?,
    );
  }
} 