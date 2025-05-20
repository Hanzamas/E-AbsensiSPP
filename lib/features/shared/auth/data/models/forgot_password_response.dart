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