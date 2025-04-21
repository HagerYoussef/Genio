import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genio_ai/features/forget_password/presentation/widgets/done_button.dart';
import '../../login/presentation/widgets/text_auth.dart';
import '../../login/presentation/widgets/text_form_field_auth.dart';
import '../back_to_login.dart';
import 'bloc/done_bloc.dart';


class ResetPassword extends StatelessWidget {
  final String userId;

  ResetPassword({required this.userId, super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F8FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 90, horizontal: 15),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextAuth(
                    text: 'Reset Password',
                    size: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 4),
                  const TextAuth(
                    text: 'Enter a new password to reset your account',
                    size: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xffA3A3B5),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  TextFormFieldAuth(
                    controller: passwordController,
                    label: "Password",
                    hint: "Enter your new password",
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      } else if (value.length < 8) {
                        return "Password must be at least 8 characters";
                      } else if (!RegExp(r'^(?=.*[A-Z])(?=.*\W).+$')
                          .hasMatch(value)) {
                        return "Password must have at least one uppercase letter and one special character";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormFieldAuth(
                    controller: confirmPasswordController,
                    label: "Confirm Password",
                    hint: "Confirm new password",
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm your password";
                      } else if (value != passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  BlocConsumer<DoneBloc, DoneState>(
                    listener: (context, state) {
                      if (state is DoneSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        Future.delayed(const Duration(seconds: 2), () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const BackToLogin()));
                        });
                      } else if (state is DoneFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.error)),
                        );
                      }
                    },
                    builder: (context, state) {
                      return DoneButton(
                        isLoading: state is DoneLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<DoneBloc>().add(
                                  ResetPasswordEvent(
                                    userId: userId,
                                    password: passwordController.text.trim(),
                                    confirmPassword:
                                        confirmPasswordController.text.trim(),
                                  ),
                                );
                          }
                        }, text: 'Done',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
