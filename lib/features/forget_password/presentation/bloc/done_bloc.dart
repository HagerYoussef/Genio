import 'package:flutter_bloc/flutter_bloc.dart';

//Events
import 'package:equatable/equatable.dart';

import '../../data/repositry/done_repository.dart';

abstract class DoneEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ResetPasswordEvent extends DoneEvent {
  final String userId;
  final String password;
  final String confirmPassword;

  ResetPasswordEvent({required this.userId, required this.password, required this.confirmPassword});

  @override
  List<Object> get props => [userId, password, confirmPassword];
}

//Status
abstract class DoneState extends Equatable {
  @override
  List<Object> get props => [];
}

class DoneInitial extends DoneState {}

class DoneLoading extends DoneState {}

class DoneSuccess extends DoneState {
  final String message;

  DoneSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class DoneFailure extends DoneState {
  final String error;

  DoneFailure(this.error);

  @override
  List<Object> get props => [error];
}

//Bloc
class DoneBloc extends Bloc<DoneEvent, DoneState> {
  final DoneRepository repository;

  DoneBloc({required this.repository}) : super(DoneInitial()) {
    on<ResetPasswordEvent>((event, emit) async {
      emit(DoneLoading());
      try {
        final response = await repository.resetPassword(
          userId: event.userId,
          password: event.password,
          confirmPassword: event.confirmPassword,
        );
        emit(DoneSuccess(response.message));
      } catch (e) {
        emit(DoneFailure(e.toString()));
      }
    });
  }
}
