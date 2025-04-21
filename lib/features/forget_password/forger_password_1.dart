import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genio_ai/features/forget_password/presentation/bloc/reset_password_bloc.dart';
import 'package:genio_ai/features/forget_password/presentation/widgets/reset_request_button.dart';
import '../login/presentation/widgets/text_auth.dart';
import '../login/presentation/widgets/text_form_field_auth.dart';
import 'data/repositry/reset_password_repository.dart';


class ForgetPassword1 extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  ForgetPassword1({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResetPasswordBloc(ResetPasswordRepository()),
      child: Scaffold(
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
                      text: 'Forget Password',
                      size: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 4),
                    const TextAuth(
                      text: 'Please enter your email address to receive a verification code',
                      size: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xffA3A3B5),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    TextFormFieldAuth(
                      controller: emailController,
                      label: 'Email',
                      hint: 'you@company.com',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email";
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    ResetRequestButton(
                      formKey: _formKey,
                      emailController: emailController,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
