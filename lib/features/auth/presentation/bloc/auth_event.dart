abstract class AuthEvent {}

class GoogleLoginRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}