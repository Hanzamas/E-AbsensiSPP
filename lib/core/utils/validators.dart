class Validators {
  static String? validateNIS(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIS tidak boleh kosong';
    }
    
    // Format NIS: 8 digit angka
    if (!RegExp(r'^\d{8}$').hasMatch(value)) {
      return 'NIS harus 8 digit angka';
    }
    
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username tidak boleh kosong';
    }
    
    // Username: 5-20 karakter, huruf, angka, underscore
    if (!RegExp(r'^[a-zA-Z0-9_]{5,20}$').hasMatch(value)) {
      return 'Username harus 5-20 karakter (huruf, angka, underscore)';
    }
    
    return null;
  }

  static String? validateWhatsApp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor WhatsApp tidak boleh kosong';
    }
    
    // Format: +62 atau 08, diikuti 9-12 digit
    String cleanNumber = value.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (!cleanNumber.startsWith('+62') && !cleanNumber.startsWith('08')) {
      return 'Nomor harus diawali dengan +62 atau 08';
    }
    
    if (cleanNumber.startsWith('+62')) {
      cleanNumber = cleanNumber.substring(3);
    } else if (cleanNumber.startsWith('08')) {
      cleanNumber = cleanNumber.substring(2);
    }
    
    if (cleanNumber.length < 9 || cleanNumber.length > 12) {
      return 'Panjang nomor tidak valid';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(cleanNumber)) {
      return 'Nomor hanya boleh berisi angka';
    }
    
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(value)) {
      return 'Password harus mengandung huruf dan angka';
    }
    
    return null;
  }
} 