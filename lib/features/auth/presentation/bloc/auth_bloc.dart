import 'package:dio/dio.dart';
import 'package:expense_tracker/core/connectivity/connectivity_service.dart';
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
  if (!isLoggedIn) {
    emit(AuthUnauthenticated());
    return;
  }
 
  final isOnline = await ConnectivityService.instance.checkConnection();
 
  if (!isOnline) {
  final cachedUser = await _authRepository.getCachedUser();
  emit(AuthAuthenticated(cachedUser ?? <String, dynamic>{}));
  return;
}
  try {
    final user = await _authRepository.getCurrentUser();
    emit(AuthAuthenticated(user));
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      await _authRepository.clearSession();
      emit(AuthUnauthenticated());
    } else {
      final cachedUser = await _authRepository.getCachedUser();
      emit(cachedUser != null ? AuthAuthenticated(cachedUser) : AuthUnauthenticated());
    }
  } catch (e) {
    final cachedUser = await _authRepository.getCachedUser();
    emit(cachedUser != null ? AuthAuthenticated(cachedUser) : AuthUnauthenticated());
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

