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

class UserData {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String role;
  final String? phoneNumber;
  final String? address;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.role,
    this.phoneNumber,
    this.address,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      role: json['role'] as String,
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'role': role,
      'phone_number': phoneNumber,
      'address': address,
    };
  }
} 