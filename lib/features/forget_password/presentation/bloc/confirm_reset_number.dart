import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositry/reset_code_repository.dart';

// Events
abstract class ResetCodeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SubmitResetCode extends ResetCodeEvent {
  final String userId;
  final String resetCode;

  SubmitResetCode({required this.userId, required this.resetCode});

  @override
  List<Object> get props => [userId, resetCode];
}

// States
abstract class ResetCodeState extends Equatable {
  @override
  List<Object> get props => [];
}

class ResetCodeInitial extends ResetCodeState {}
class ResetCodeLoading extends ResetCodeState {}
class ResetCodeSuccess extends ResetCodeState {}
class ResetCodeFailure extends ResetCodeState {
  final String errorMessage;

  ResetCodeFailure({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

// Bloc
class ResetCodeBloc extends Bloc<ResetCodeEvent, ResetCodeState> {
  final ResetCodeRepository repository;

  ResetCodeBloc({required this.repository}) : super(ResetCodeInitial()) {
    on<SubmitResetCode>((event, emit) async {
      emit(ResetCodeLoading());
      try {
        final result = await repository.verifyResetCode(event.userId, event.resetCode);
        if (result == "success") {
          emit(ResetCodeSuccess());
        } else {
          emit(ResetCodeFailure(errorMessage: result));
        }
      } catch (e) {
        emit(ResetCodeFailure(errorMessage: "Invalid or expired reset code"));
      }
    });
  }
}
