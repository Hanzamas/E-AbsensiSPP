// ----- REQUEST MODELS -----
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };
}

class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String passwordConfirmation;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'password': password,
    'password_confirmation': passwordConfirmation,
    'role': 'siswa', // Default role
  };
}

class PasswordResetRequest {
  final String email;
  
  PasswordResetRequest({required this.email});
  
  Map<String, dynamic> toJson() => {'email': email};
}

class OtpVerificationRequest {
  final String otp;
  
  OtpVerificationRequest({required this.otp});
  
  Map<String, dynamic> toJson() => {'otp': otp};
}

class PasswordChangeRequest {
  final String newPassword;
  final String confirmPassword;
  
  PasswordChangeRequest({
    required this.newPassword, 
    required this.confirmPassword,
  });
  
  Map<String, dynamic> toJson() => {
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
  };
}

// ----- SIMPLE RESPONSE MODELS -----
class LoginResponse {
  final bool status;
  final String message;
  final String token;
  final String role;
  final UserData user;

  LoginResponse({
    required this.status,
    required this.message,
    required this.token,
    required this.role,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return LoginResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      token: data['token'] as String,
      role: data['role'] as String,
      user: UserData.fromJson(data),
    );
  }
}

class UserData {
  final int id;
  final String username;
  final String email;
  final String namaLengkap;

  UserData({
    required this.id,
    required this.username,
    required this.email,
    required this.namaLengkap,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id_user'] as int,
      username: json['username'] as String,
      email: json['email'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? json['username'],
    );
  }
}

// Simple response untuk operations
class SimpleResponse {
  final bool status;
  final String message;
  
  SimpleResponse({required this.status, required this.message});
  
  factory SimpleResponse.fromJson(Map<String, dynamic> json) {
    return SimpleResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
    );
  }
}