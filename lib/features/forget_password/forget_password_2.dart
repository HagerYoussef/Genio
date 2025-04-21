import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genio_ai/features/forget_password/presentation/bloc/confirm_reset_number.dart';
import 'package:genio_ai/features/forget_password/presentation/widgets/confirm_button.dart';
import 'package:genio_ai/features/forget_password/presentation/widgets/text_form_field_password.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login/presentation/widgets/text_auth.dart';
import 'data/repositry/reset_code_repository.dart';

class ForgetPassword2 extends StatefulWidget {
  final String email;

  const ForgetPassword2({super.key, required this.email});

  @override
  _ForgetPassword2State createState() => _ForgetPassword2State();
}

class _ForgetPassword2State extends State<ForgetPassword2> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController controller1 = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  final TextEditingController controller3 = TextEditingController();
  final TextEditingController controller4 = TextEditingController();

  String? userId;

  final FocusNode focus1 = FocusNode();
  final FocusNode focus2 = FocusNode();
  final FocusNode focus3 = FocusNode();
  final FocusNode focus4 = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString("userId"); // ✅ Retrieve userId from SharedPreferences
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResetCodeBloc(repository: ResetCodeRepository()),
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
                    const TextAuth(text: 'Verification', size: 22, fontWeight: FontWeight.w500, color: Colors.black),
                    const SizedBox(height: 4),
                    TextAuth(
                      text: 'Enter the 4-digit code we have sent to ${widget.email}',
                      size: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xffA3A3B5),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormFieldPassword(
                            controller: controller1,
                            keyboardType: TextInputType.number,
                            focusNode: focus1,
                            nextFocusNode: focus2, // Move to the next field
                          ),
                        ),
                        Expanded(
                          child: TextFormFieldPassword(
                            controller: controller2,
                            keyboardType: TextInputType.number,
                            focusNode: focus2,
                            nextFocusNode: focus3,
                          ),
                        ),
                        Expanded(
                          child: TextFormFieldPassword(
                            controller: controller3,
                            keyboardType: TextInputType.number,
                            focusNode: focus3,
                            nextFocusNode: focus4,
                          ),
                        ),
                        Expanded(
                          child: TextFormFieldPassword(
                            controller: controller4,
                            keyboardType: TextInputType.number,
                            focusNode: focus4, // Last field, no next focus
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    userId == null
                        ? const Center(child: CircularProgressIndicator()) // ✅ Show loading while fetching userId
                        : ConfirmButton(
                      formKey: _formKey,
                      controller1: controller1,
                      controller2: controller2,
                      controller3: controller3,
                      controller4: controller4,
                      userId: userId!, // ✅ Use retrieved userId
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
