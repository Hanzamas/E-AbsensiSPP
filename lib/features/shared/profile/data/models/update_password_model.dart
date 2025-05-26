class UpdatePasswordModel {
  final String oldPassword;
  final String newPassword;

  UpdatePasswordModel({
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
  }

  // Validasi password
  bool validate() {
    // Tambahkan validasi sesuai kebutuhan
    if (oldPassword.isEmpty || newPassword.isEmpty) {
      return false;
    }

    // Contoh validasi panjang password minimal 6 karakter
    if (newPassword.length < 6) {
      return false;
    }

    return true;
  }
} 