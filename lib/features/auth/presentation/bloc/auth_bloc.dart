import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<GoogleLoginRequested>(_onGoogleLogin);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
  CheckAuthStatus event,
  Emitter<AuthState> emit,
) async {
  final isLoggedIn = await _authRepository.isLoggedIn();
  if (isLoggedIn) {
    try {
      final user = await _authRepository.getCurrentUser(); // 👈 /auth/me ခေါ်ပြီး user data ယူမယ်
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthUnauthenticated()); // token invalid/expired ဖြစ်ရင်
    }
  } else {
    emit(AuthUnauthenticated());
  }
}

  Future<void> _onGoogleLogin(
    GoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.googleLogin();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}