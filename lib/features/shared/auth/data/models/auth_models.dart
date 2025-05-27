// Semua model untuk fitur auth

// ----- REQUEST MODELS -----

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

class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String role;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    this.role = 'siswa',
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'role': role,
    };
  }
}

class PasswordResetRequest {
  final String email;
  
  PasswordResetRequest({required this.email});
  
  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class OtpVerificationRequest {
  final String otp;
  
  OtpVerificationRequest({required this.otp});
  
  Map<String, dynamic> toJson() {
    return {'otp': otp};
  }
}

class PasswordChangeRequest {
  final String newPassword;
  final String confirmPassword;
  
  PasswordChangeRequest({
    required this.newPassword, 
    required this.confirmPassword,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}

// ----- RESPONSE MODELS -----

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

class UserInfoResponse {
  final bool status;
  final String message;
  final UserInfo data;
  
  UserInfoResponse({
    required this.status,
    required this.message,
    required this.data,
  });
  
  factory UserInfoResponse.fromJson(Map<String, dynamic> json) {
    return UserInfoResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: UserInfo.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

// ----- DATA MODELS -----

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

class UserInfo {
  final int id;
  final String username;
  final String email;
  final String namaLengkap;
  final String role;
  final String? profilePict;

  UserInfo({
    required this.id,
    required this.username,
    required this.email,
    required this.namaLengkap,
    required this.role,
    this.profilePict,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      namaLengkap: json['nama_lengkap']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      profilePict: json['profile_pict']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'nama_lengkap': namaLengkap,
      'role': role,
      'profile_pict': profilePict,
    };
  }
}