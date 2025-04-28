Berikut struktur lengkap **step-by-step** yang dioptimalkan untuk pemula dengan penjelasan tiap komponen:

```markdown
my_app/
├─ android/
├─ ios/
├─ lib/
│   ├─ core/
│   │   ├─ api/
│   │   │   ├─ dio_client.dart         # Setup DIO (base URL, headers, dll)
│   │   │   └─ interceptors/           # Interceptor untuk auth/logging
│   │   │       ├─ auth_interceptor.dart
│   │   │       └─ logger_interceptor.dart
│   │   │
│   │   ├─ router/
│   │   │   ├─ app_router.dart         # Daftar semua route
│   │   │   └─ route_guards.dart       # Cek login sebelum masuk halaman
│   │   │
│   │   ├─ theme/
│   │   │   ├─ colors.dart             # Warna aplikasi
│   │   │   ├─ text_styles.dart        # Style text global
│   │   │   └─ theme.dart              # ThemeData utama
│   │   │
│   │   ├─ widgets/                    # Widget reusable
│   │   │   ├─ loading.dart            # Loading indicator
│   │   │   ├─ error_retry.dart        # Tampilan error + tombol retry
│   │   │   └─ custom_appbar.dart      # AppBar custom
│   │   │
│   │   ├─ constants/
│   │   │   ├─ custom_appbar.dart      # AppBar custom
│   │   │   ├─ strings.dart            # Teks untuk seluruh app
│   │   │   ├─ assets.dart             # Path ke gambar/icons
│   │   │   └─ enums.dart              # Enum global (Role, Status, dll)
│   │   │
│   │   └─injection.dart               # Provider
│   │   
│   │
│   │
│   ├─ features/                       # Modul fitur
│   │   ├─ auth/                       # Fitur Autentikasi
│   │   │   ├─ data/
│   │   │   │   ├─ auth_service.dart   # API calls untuk login/logout
│   │   │   │   └─ auth_repository.dart # Business logic auth
│   │   │   │
│   │   │   ├─ presentation/
│   │   │   │   ├─ login/
│   │   │   │   │   ├─ login_screen.dart   # Tampilan UI
│   │   │   │   │   └─ login_provider.dart # State management
│   │   │   │   │
│   │   │   │   └─ register/
│   │   │   │       ├─ register_screen.dart
│   │   │   │       └─ register_provider.dart
│   │   │   │
│   │   │   └─ models/                 # Model khusus auth
│   │   │       ├─ user_model.dart
│   │   │       └─ login_request.dart
│   │   │
│   │   ├─ attendance/                 # Fitur Absensi
│   │   │   ├─ data/
│   │   │   │   └─ attendance_service.dart
│   │   │   │
│   │   │   ├─ presentation/
│   │   │   │   ├─ attendance_screen.dart
│   │   │   │   └─ attendance_provider.dart
│   │   │   │
│   │   │   └─ models/
│   │   │       └─ attendance_model.dart
│   │   │
│   │   ├─ profile/                    # Fitur Profil (digunakan semua role)
│   │   │   ├─ presentation/
│   │   │   │   ├─ profile_screen.dart
│   │   │   │   └─ profile_provider.dart
│   │   │   │
│   │   │   └─ models/
│   │   │       └─ profile_model.dart
│   │   │
│   │   └─ ...                         # Fitur lainnya (spp, akademik, dll)
│   │
│   ├─ shared/                         # Komponen shared antar fitur
│   │   ├─ utils/                      # Utilities
│   │   │   ├─ helpers/
│   │   │   │   ├─ context_extension.dart # MediaQuery shortcut
│   │   │   │   └─ date_formatter.dart
│   │   │   │
│   │   │   └─ validators/             # Validator form
│   │   │       └─ auth_validator.dart
│   │   │
│   │   └─ domain/                     # Model shared
│   │       └─ api_response.dart       # Format response API standar
│   │
│   ├─ main.dart                       # Entry point aplikasi
│   └─ app.dart                        # Konfigurasi utama (theme, router)
│
├─ assets/
│   ├─ images/                         # Gambar statis
│   │   ├─ icons/                      # Icon SVG
│   │   └─ illustrations/              # Ilustrasi
│   │
│   └─ translations/                   # File lokalisasi (JSON)
│
├─ test/                              # Testing
│   └─ features/
│       └─ auth/
│           └─ auth_test.dart         # Test untuk fitur auth
│
├─ .gitignore
├─ pubspec.yaml                       # Dependencies
├─ README.md                          # Dokumentasi
└─ build.yaml                         # Konfigurasi build_runner
```

**Penjelasan File Penting untuk Pemula:**

1. **lib/core/api/dio_client.dart** - Setup HTTP Client
```dart
class DioClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
  ));

  // Tambahkan interceptor
  DioClient() {
    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(LoggerInterceptor());
  }
  
  // Method GET/POST umum
  Future<Response> get(String path) => _dio.get(path);
}
```

2. **lib/features/auth/presentation/login_provider.dart** - Contoh State Management
```dart
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(
    authRepository: ref.watch(authRepositoryProvider),
  );
});

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier({required this.authRepository}) : super(LoginInitial());

  final AuthRepository authRepository;

  Future<void> login(String email, String password) async {
    state = LoginLoading();
    try {
      final user = await authRepository.login(email, password);
      state = LoginSuccess(user);
    } catch (e) {
      state = LoginError(e.toString());
    }
  }
}
```

3. **lib/shared/utils/context_extension.dart** - Helper untuk Akses Cepat
```dart
extension ContextExtension on BuildContext {
  // Akses media query tanpa menulis panjang
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  // Akses theme colors
  Color get primaryColor => Theme.of(this).primaryColor;
}
```

**Alur Kerja untuk Pemula:**

1. **Buat Screen Baru**:
   - Tambah folder di `features/namafitur`
   - Buat file `namafitur_screen.dart` untuk UI
   - Buat `namafitur_provider.dart` untuk logika bisnis

2. **Hubungkan ke API**:
   - Buat `namafitur_service.dart` di folder data
   - Panggil service dari provider

3. **Tambahkan Routing**:
   - Daftarkan route di `app_router.dart`
   ```dart
   GoRoute(
     path: '/login',
     builder: (context, state) => const LoginScreen(),
   ),
   ```

**Tips untuk Tidak Bingung:**

1. **Pattern Konsisten**:
   - Screen: `[nama]_screen.dart`
   - Provider: `[nama]_provider.dart`
   - Model: `[nama]_model.dart`

2. **Gunakan Diagram Ini**:
```
Feature
├─ Data Layer (API/RoomDB)
├─ Business Logic (Provider)
└─ UI Layer (Screen)
```

3. **Mulai dari Yang Simple**:
   - Buat 1 fitur lengkap (auth) dulu
   - Duplikat struktur untuk fitur berikutnya

**Dependencies yang Direkomendasikan di pubspec.yaml**:
```yaml
dependencies:
  flutter:
    sdk: flutter
  riverpod: ^2.4.0
  dio: ^5.0.0
  go_router: ^12.0.0
  freezed: ^2.4.0
  flutter_svg: ^2.0.0

dev_dependencies:
  build_runner: ^2.4.0
  freezed_annotation: ^2.4.0
```

Struktur ini sudah digunakan di banyak projek Flutter skala menengah dan terbukti:
- **Mudah dipahami** untuk pemula
- **Cepat dikembangkan** (1 fitur/hari untuk pemula)
- **Minimal konflik** saat kerja tim
- **Mudah di-maintain** walau projek membesar