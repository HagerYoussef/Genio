import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genio_ai/features/login/presentation/bloc/login_bloc.dart';
import 'package:genio_ai/features/login/presentation/widgets/text_auth.dart';

class AuthButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback? onPressed;

  const AuthButton({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
              if (formKey.currentState!.validate()) {
                onPressed?.call();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0047AB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const TextAuth(
              text: 'Sign in',
              size: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
