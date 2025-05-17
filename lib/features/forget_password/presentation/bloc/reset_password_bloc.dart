import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositry/reset_password_repository.dart';

abstract class ResetPasswordEvent {}
class SendResetRequest extends ResetPasswordEvent {
  final String email;
  SendResetRequest(this.email);
}

abstract class ResetPasswordState {}
class ResetPasswordInitial extends ResetPasswordState {}
class ResetPasswordLoading extends ResetPasswordState {}
class ResetPasswordSuccess extends ResetPasswordState {
  final String message;
  ResetPasswordSuccess(this.message);
}
class ResetPasswordFailure extends ResetPasswordState {
  final String error;
  ResetPasswordFailure(this.error);
}

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final ResetPasswordRepository repository;

  ResetPasswordBloc(this.repository) : super(ResetPasswordInitial()) {
    on<SendResetRequest>((event, emit) async {
      emit(ResetPasswordLoading());

      final result = await repository.sendResetRequest(event.email);
      if (result == "Password reset email sent successfully") {
        emit(ResetPasswordSuccess(result));
      } else {
        emit(ResetPasswordFailure(result));
      }
    });
  }
}
