import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repository/login_repository.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String userId;

  AuthSuccess({required this.userId});
}

class AuthFailure extends AuthState {
  final String error;

  AuthFailure(this.error);

  @override
  List<Object> get props => [error];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.login(event.email, event.password);
      if (response['success']) {
        String userId = response['userId'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("userId", userId);
        print("Stored userId: $userId");

        emit(AuthSuccess(userId: userId));
      } else {
        emit(AuthFailure('Invalid Email or Password'));
      }
    } catch (e) {
      emit(AuthFailure("Unexpected error: ${e.toString()}"));
    }
  }

}
