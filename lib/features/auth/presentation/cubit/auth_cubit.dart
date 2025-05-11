import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';
import '../../models/auth_model.dart';

// Events
abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  LoginEvent({required this.username, required this.password});
}

class RegisterEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;

  RegisterEvent({
    required this.username,
    required this.email,
    required this.password,
  });
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  ForgotPasswordEvent({required this.email});
}

class VerifyOtpEvent extends AuthEvent {
  final String token;
  final String otp;

  VerifyOtpEvent({required this.token, required this.otp});
}

class ChangePasswordEvent extends AuthEvent {
  final String token;
  final String password;

  ChangePasswordEvent({required this.token, required this.password});
}

class LogoutEvent extends AuthEvent {}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthModel auth;

  AuthSuccess(this.auth);
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final auth = await _authRepository.login(username, password);
      emit(AuthSuccess(auth));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      await _authRepository.register(
        username: username,
        email: email,
        password: password,
      );
      emit(AuthSuccess(AuthModel(
        token: '',
        username: username,
        role: '',
      )));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());
    try {
      await _authRepository.forgotPassword(email);
      emit(AuthSuccess(AuthModel(
        token: '',
        username: '',
        role: '',
      )));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> verifyOtp(String token, String otp) async {
    emit(AuthLoading());
    try {
      await _authRepository.verifyOtp(token, otp);
      emit(AuthSuccess(AuthModel(
        token: token,
        username: '',
        role: '',
      )));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> changePassword(String token, String password) async {
    emit(AuthLoading());
    try {
      await _authRepository.resetPassword(token, password);
      emit(AuthSuccess(AuthModel(
        token: '',
        username: '',
        role: '',
      )));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
} 