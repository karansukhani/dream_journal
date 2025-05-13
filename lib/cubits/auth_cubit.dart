import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dream_journal/models/user_model.dart';
import 'package:dream_journal/services/supabase_service.dart';

// States
abstract class AuthenticationState {}

class AuthInitial extends AuthenticationState {}

class AuthLoading extends AuthenticationState {}

class AuthAuthenticated extends AuthenticationState {
  final UserData user;

  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthenticationState {}

class SignupSuccess extends AuthenticationState {}

class AuthError extends AuthenticationState {
  final String message;

  AuthError(this.message);
}

// Cubit
class AuthCubit extends Cubit<AuthenticationState> {
  final SupabaseService _supabaseService;

  AuthCubit(this._supabaseService) : super(AuthInitial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    final user = await _supabaseService.getCurrentUser();

    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(AuthLoading());

    final response = await _supabaseService.signUp(email, password);

    if (response.isSuccess) {
      emit(SignupSuccess());
    } else {
      emit(AuthError(
          response.message ?? 'Failed to sign up. Please try again.'));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());

    final response = await _supabaseService.signIn(email, password);

    if (response.isSuccess) {
      final user = response.data;
      emit(AuthAuthenticated(user ??
          UserData(
              id: '',
              email: email,
              createdAt: DateTime.now(),
              lastLogin: DateTime.now())));
    } else {
      emit(
          AuthError(response.message ?? 'An error occurred while signing in.'));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());

    await _supabaseService.signOut();

    emit(AuthUnauthenticated());
  }
}
