import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

import '../../models/user_signup_model.dart';

// --- Events ---
abstract class RegisterEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final UserSignupModel user;

  RegisterSubmitted(this.user);

  @override
  List<Object> get props => [user];
}

// --- States ---
abstract class RegisterState extends Equatable {
  @override
  List<Object> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final String message;

  RegisterSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class RegisterFailure extends RegisterState {
  final String error;

  RegisterFailure({required this.error});

  @override
  List<Object> get props => [error];
}

// --- BLoC ---
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(RegisterSubmitted event, Emitter<RegisterState> emit) async {
    emit(RegisterLoading());
    const String url = "https://genio-rust.vercel.app/api/signup";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(event.user.toJson()),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        emit(RegisterSuccess(message: "Account created successfully!"));
      } else {
        emit(RegisterFailure(error: responseData["message"] ?? "Something went wrong!"));
      }
    } catch (error) {
      emit(RegisterFailure(error: "Failed to connect to the server!"));
    }
  }
}
