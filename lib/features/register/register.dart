import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genio_ai/features/register/presentation/bloc/register_bloc.dart';
import 'package:genio_ai/features/register/presentation/widgets/phone_number.dart';
import 'package:genio_ai/features/register/presentation/widgets/register_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../login/presentation/login.dart';
import '../login/presentation/widgets/text_auth.dart';
import '../login/presentation/widgets/text_form_field_auth.dart';
import 'models/user_signup_model.dart';

class Register extends StatelessWidget {
  Register({super.key});
  static String routeName = 'Register';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void _register(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final user = UserSignupModel(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      context.read<RegisterBloc>().add(RegisterSubmitted(user));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterBloc(),
      child: Scaffold(
        backgroundColor: const Color(0xffF0F8FF),
        body: SafeArea(
          child: BlocListener<RegisterBloc, RegisterState>(
            listener: (context, state) {
              if (state is RegisterSuccess) {
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.success,
                  text: state.message,
                  confirmBtnText: 'Continue',
                  onConfirmBtnTap: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(context, Login.routeName);
                  },
                    confirmBtnColor : Color(0xFF0047AB),
                    confirmBtnTextStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                );
              } else if (state is RegisterFailure) {
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.error,
                  title: 'Registration Failed',
                  widget: Text(
                    state.error,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  cancelBtnText: 'Try again',
                  cancelBtnTextStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  onConfirmBtnTap: () => Navigator.of(context).pop(),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 15),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TextAuth(
                          text: 'Create\nNew Account',
                          size: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                      Row(
                        children: [
                          SizedBox(
                            width: 155,
                            child: TextFormFieldAuth(
                              controller: firstNameController,
                              label: "First name",
                              hint: "First name",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your first name";
                                } else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                                  return "First name must contain only letters";
                                } else if (value.length < 3) {
                                  return "First name must be at least 3 characters";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 15),
                          SizedBox(
                            width: 155,
                            child: TextFormFieldAuth(
                              controller: lastNameController,
                              label: "Last name",
                              hint: "Last name",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your first name";
                                } else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                                  return "First name must contain only letters";
                                } else if (value.length < 3) {
                                  return "First name must be at least 3 characters";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      TextFormFieldAuth(
                        controller: emailController,
                        label: "Email",
                        hint: "you@company.com",
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      const TextAuth(
                          text: 'Phone number',
                          size: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                      const SizedBox(height: 8),
                      PhoneNumber(phoneController: phoneNumberController),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      TextFormFieldAuth(
                        controller: passwordController,
                        label: "Password",
                        hint: "Password",
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your password";
                          } else if (value.length < 8) {
                            return "Password must be at least 8 characters";
                          } else if (!RegExp(r'^(?=.*[A-Z])(?=.*\W).+$').hasMatch(value)) {
                            return "Password must have at least one uppercase letter and one special character";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      TextFormFieldAuth(
                        controller: confirmPasswordController,
                        label: "Confirm Password",
                        hint: "Confirm password",
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
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      RegisterButton(
                        formKey: _formKey,
                        firstNameController: firstNameController,
                        lastNameController: lastNameController,
                        emailController: emailController,
                        phoneNumberController: phoneNumberController,
                        passwordController: passwordController,
                        confirmPasswordController: confirmPasswordController,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const TextAuth(
                            text: "Already have an account ?",
                            size: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => Login()),
                              );
                            },
                            child: const TextAuth(
                              text: ' Sign in',
                              size: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF0047AB),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
