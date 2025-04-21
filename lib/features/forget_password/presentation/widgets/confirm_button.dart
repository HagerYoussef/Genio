import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../login/presentation/widgets/text_auth.dart';
import '../bloc/confirm_reset_number.dart';
import '../reset_password.dart';

class ConfirmButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller1;
  final TextEditingController controller2;
  final TextEditingController controller3;
  final TextEditingController controller4;
  final String userId;

  const ConfirmButton({
    super.key,
    required this.formKey,
    required this.controller1,
    required this.controller2,
    required this.controller3,
    required this.controller4,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResetCodeBloc, ResetCodeState>(
      listener: (context, state) {
        if (state is ResetCodeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Verification successful!"),backgroundColor: Colors.green,duration: const Duration(seconds: 2),),
          );
          Future.delayed(const Duration(seconds: 2), () {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ResetPassword(userId: userId,)));});
        } else if (state is ResetCodeFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage)),
          );
        }
      },
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: state is ResetCodeLoading
                ? null
                : () {
              if (formKey.currentState!.validate()) {
                String resetCode =
                    "${controller1.text}${controller2.text}${controller3.text}${controller4.text}";
                context.read<ResetCodeBloc>().add(
                  SubmitResetCode(
                      userId: userId, resetCode: resetCode),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0047AB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: state is ResetCodeLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const TextAuth(text: "Confirm", color: Colors.white,size: 16,fontWeight: FontWeight.w600,),
          ),
        );
      },
    );
  }
}
