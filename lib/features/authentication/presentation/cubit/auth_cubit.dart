
import 'package:e_signature/core/usecase/usecase.dart';
import 'package:e_signature/features/authentication/domain/repositories/auth_repository.dart';
import 'package:e_signature/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:e_signature/features/authentication/domain/usecases/sign_in_usecase.dart';
import 'package:e_signature/features/authentication/domain/usecases/sign_out_usecase.dart';
import 'package:e_signature/features/authentication/domain/usecases/sign_up_usecase.dart';
import 'package:e_signature/features/authentication/presentation/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final AuthRepository authRepository;

  AuthCubit({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    _checkAuthStatus();
    _listenToAuthChanges();
  }

  void _checkAuthStatus() async {
    emit(AuthLoading());
    final result = await getCurrentUserUseCase(NoParams());
    result.fold(
          (failure) => emit(AuthUnauthenticated()),
          (user) => emit(AuthAuthenticated(user)),
    );
  }

  void _listenToAuthChanges() {
    authRepository.authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    final result = await signInUseCase(SignInParams(
      email: email,
      password: password,
    ));

    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> signUp(String email, String password) async {
    emit(AuthLoading());
    final result = await signUpUseCase(SignUpParams(
      email: email,
      password: password,
    ));

    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    final result = await signOutUseCase(NoParams());

    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (_) => emit(AuthUnauthenticated()),
    );
  }
}
