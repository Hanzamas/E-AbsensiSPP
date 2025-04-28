# Roadmap Pemula
1. Setup project Flutter baru:
   ```bash
   flutter create e_absensispp
   ```
2. Tambahkan dependencies di `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter_riverpod: ^2.4.0
     dio: ^5.0.0
     go_router: ^12.0.0
     flutter_svg: ^2.0.0
     freezed_annotation: ^2.4.0
   dev_dependencies:
     build_runner: ^2.4.0
     freezed: ^2.4.0
   ```
3. Struktur folder minimal:
   ```text
   lib/
     main.dart
     app.dart
     core/
       api/dio_client.dart
       providers.dart
       router/app_router.dart
       theme/app_theme.dart
       widgets/splash_page.dart
     features/auth/
       data/auth_service.dart
       models/user_model.dart
       presentation/login_screen.dart
       presentation/login_provider.dart
     shared/
       widgets/custom_text_field.dart
   ```
4. Konfigurasi routing & tema (lib/core/router/app_router.dart, lib/core/theme/app_theme.dart).
5. Buat provider untuk semua dependency (lib/core/providers.dart):
   ```dart
   import 'package:dio/dio.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'dio_client.dart';
   import '../features/auth/data/auth_service.dart';

   final dioProvider = Provider<Dio>((ref) => Dio(
     BaseOptions(baseUrl: 'https://api.example.com/'),
   ));

   final dioClientProvider = Provider<DioClient>((ref) => DioClient(ref.watch(dioProvider)));

   final authServiceProvider = Provider<AuthService>((ref) =>
     AuthService(ref.watch(dioClientProvider))
   );
   ```

6. Implementasi fitur Authentication:
   - Model & service
   - Provider (`loginProvider`) dengan `StateNotifier`
   - UI (`LoginScreen`)
7. Tambah fitur Profil, Absensi, dan SPP satu per satu mengikuti pola:
   Data → Provider → UI
8. Testing: unit_test untuk model/usecase, widget_test untuk screen.
9. Build & deploy: `flutter build apk` / `flutter build ios`.

---

Berikut contoh kode untuk file-file penting dalam struktur tersebut:

**1. Core/Dio Client (lib/core/api/dio_client.dart):**
```dart
import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;

  DioClient(this._dio);

  Future<Response> get(String path) async => await _dio.get(path);
  Future<Response> post(String path, dynamic data) async => await _dio.post(path, data: data);
}
```

**2. Router (lib/core/router/app_router.dart):**
```dart
import 'package:go_router/go_router.dart';
import 'package:my_app/features/auth/presentation/login_screen.dart';
import 'package:my_app/features/home/presentation/home_screen.dart';

final goRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
  redirect: (context, state) {
    final isLoggedIn = false; // Check auth state
    if (!isLoggedIn && state.location != '/login') return '/login';
    return null;
  },
);
```

**3. Theme (lib/core/theme/colors.dart):**
```dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color secondary = Color(0xFF81C784);
  static const Color error = Color(0xFFD32F2F);
  static const Color background = Color(0xFFF5F5F5);
}
```

**4. Auth Service (lib/features/auth/data/auth_service.dart):**
```dart
import 'package:my_app/core/api/dio_client.dart';
import 'package:my_app/features/auth/models/user_model.dart';

class AuthService {
  final DioClient _dio;

  AuthService(this._dio);

  Future<UserModel> login(String email, String password) async {
    final response = await _dio.post('/login', {
      'email': email,
      'password': password,
    });
    return UserModel.fromJson(response.data);
  }
}
```

**5. Auth Model (lib/features/auth/models/user_model.dart):**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  factory UserModel({
    required String id,
    required String name,
    required String email,
    @Default('user') String role,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

**6. Login Provider (lib/features/auth/presentation/login_provider.dart):**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/features/auth/data/auth_service.dart';

final loginProvider = StateNotifierProvider<LoginNotifier, AsyncValue<void>>((ref) {
  return LoginNotifier(ref.watch(authServiceProvider));
});

class LoginNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  
  LoginNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authService.login(email, password);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
```

**7. Login Screen (lib/features/auth/presentation/login_screen.dart):**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/widgets/custom_text_field.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              controller: emailController,
              label: 'Email',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: passwordController,
              label: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(loginProvider.notifier).login(
                emailController.text,
                passwordController.text,
              ),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**8. Main App (lib/app.dart):**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/core/router/app_router.dart';
import 'package:my_app/core/theme/theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    
    return MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: child,
      ),
    );
  }
}
```

**9. Main Entry (lib/main.dart):**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

**Core Providers (lib/core/providers.dart):**
```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_client.dart';
import '../features/auth/data/auth_service.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: 'https://api.example.com/'));
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref.watch(dioProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(dioClientProvider));
});
```

**Tips untuk Memahami:**
1. **Alur Data**:
   - UI (Screen) → Panggil Provider → Service → API → Response → Update State → UI Update

2. **Pola Umum**:
   - Setiap fitur punya 3 bagian utama:
     1. **Data**: API calls & database
     2. **Presentation**: UI + State management
     3. **Domain**: Business logic & models

3. **Cara Menjalankan**:
   - Buat file `build.yaml` untuk konfigurasi code generator
   - Jalankan command:
   ```bash
   flutter pub run build_runner watch --delete-conflicting-outputs
   ```

4. **Mulai Development**:
   - Buat model dulu → Service → Provider → Screen
   - Gunakan snippet code di atas sebagai template

Struktur ini akan membantu Anda: 
- Memisahkan tanggung jawab tiap layer
- Memudahkan testing
- Mempercepat debugging
- Memungkinkan kolaborasi tim

Berikut roadmap manual yang disesuaikan dengan struktur dan dependency‑injection berbasis Riverpod di #codebase Anda. Urutannya dari yang paling mudah hingga yang paling kompleks:

1. Persiapan & Setup
  • Pastikan Flutter SDK aktif, IDE siap.
  • Jalankan flutter pub get setelah menambah dependency di pubspec.yaml.
  • Struktur folder minimal sudah ada di mfs.md.

2. Core Providers & API Client
  • Tulis dio_client.dart (sudah ada).
  • Tulis lib/core/providers.dart untuk men‑register:
   – dioProvider
   – dioClientProvider
   – authServiceProvider
  • Pastikan ProviderScope membungkus runApp di main.dart.

3. Splash Screen & Routing Dasar
  • Implement lib/core/widgets/splash_page.dart yang delay 2 detik lalu go('/login').
  • Definisikan app_router.dart dengan rute /splash, /login, /register, /profile.
  • Gunakan MaterialApp.router(routerConfig: goRouter) di app.dart.

4. Tema Global
  • Atur lib/core/theme/app_theme.dart (warna primer, Material 3).
  • Pastikan theme: AppTheme.light di MaterialApp.

5. Fitur Authentication (Basic)
  • Buat model UserModel di features/auth/models/.
  • Service AuthService.login() memanggil /login.
  • Provider loginProvider (StateNotifier) untuk state loading/success/error.
  • UI LoginScreen pakai ConsumerWidget, ref.read(loginProvider.notifier).login(...).

6. Fitur Register & Logout
  • Tambah endpoint /register di AuthService.
  • Tambah registerProvider dan RegisterScreen.
  • Implement logout: AuthService.logout(), provider & tombol Logout di UI.

7. Fitur Profil
  • Model UserProfileModel, service getProfile(), provider profileProvider.
  • Bikin ProfileScreen—fetch data di initState() (atau FutureProvider).
  • Tambah form edit profil + update via ProfileService.updateProfile().

8. Fitur Absensi
  • Model Attendance, service markAttendance() (QR/tombol).
  • Provider attendanceProvider.
  • UI sederhana: tombol “Absen Sekarang”, tampilkan hasil response.

9. Fitur Pembayaran SPP
  • Model Payment, service paySpp(), provider paymentProvider.
  • UI list tagihan: ListView, tombol “Bayar”, panggil provider.

10. Testing
  • Unit test untuk model & service (test).
  • Widget test untuk LoginScreen, ProfileScreen.
  • Jalankan flutter test.

11. Polishing & Deployment
  • Tambah validasi form, error handling global (snackbar).
  • Optimasi theme (dark mode, typography).
  • Build release:
   – flutter build apk --release
   – flutter build ios --release

Setelah menyelesaikan tiap poin, commit perubahan, cek integrasi melalui manual QA atau emulator. Dengan urutan ini, Anda menguasai dasar dulu (DI, routing, tema), lalu feature stack mulai dari yang paling ringan (login) hingga alur bisnis lengkap (absensi & pembayaran). Semoga membantu!