import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genio_ai/features/login/presentation/widgets/auth_button.dart';
import 'package:genio_ai/features/login/presentation/widgets/text_auth.dart';
import 'package:genio_ai/features/login/presentation/widgets/text_form_field_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../forget_password/forger_password_1.dart';
import '../../home_screen/homescreen.dart';
import '../../register/register.dart';
import 'bloc/login_bloc.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';



class Login extends StatelessWidget {
  static String routeName = 'Login';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Login({super.key});

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      final uid = userCredential.user?.uid;
      final email = userCredential.user?.email;
      final name = userCredential.user?.displayName;

      final String secretKey = r"h@8G$z!X9rF%2pL^vM&*sYQ1JbT7NcW5x!G3dR0PmA*Zq^vU4L&V9mY6C2H";

      final jwt = JWT({
        'uid': uid,
        'email': email,
        'name': name,
        'iat': DateTime.now().millisecondsSinceEpoch,
      });

      final signedToken = jwt.sign(SecretKey(secretKey), algorithm: JWTAlgorithm.HS256);

      print("🔐 JWT Token (HS256): $signedToken");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', signedToken); // JWT
      await prefs.setString('userId', uid!); // Firebase UID

      await http.post(
        Uri.parse('https://back-end-api.genio.ae/api/login'),
        headers: {
          'Authorization': 'Bearer $signedToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "userId": uid,
          "email": email,
          "name": name,
        }),
      );

      final storedToken = prefs.getString('token');
      print("📦 Stored Token from SharedPreferences: $storedToken");
      return userCredential;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }


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
                    text: "Log into\nyour Account",
                    size: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  TextFormFieldAuth(
                    controller: passwordController,
                    label: "Password",
                    hint: "Enter your password",
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      } else if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) async {
                      if (state is AuthSuccess) {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString("userId", state.userId);
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.success,
                          text: 'Login successful!',
                          confirmBtnText: 'Continue',
                          confirmBtnColor: const Color(0xFF0047AB),
                          confirmBtnTextStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          onConfirmBtnTap: () {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                            );
                          },
                        );
                      }
                      else if (state is AuthFailure) {
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.error,
                          title: 'Login Failed',
                          text: 'Invalid Email or Password',
                          confirmBtnText: 'Try Again',
                          confirmBtnColor: const Color(0xFF0047AB),
                          confirmBtnTextStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return AuthButton(
                        formKey: _formKey,
                        emailController: emailController,
                        passwordController: passwordController,
                        onPressed: () {
                          context.read<AuthBloc>().add(
                            LoginEvent(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: ()async{
                        final userCredential = await signInWithGoogle();
                        if (userCredential != null) {
                          print('Signed in: ${userCredential.user!.displayName}');
                          Navigator.pushNamed(context, HomeScreen.routeName);
                        } else {
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0047AB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                        text: 'Sign in with google',
                        size: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          child: const TextAuth(
                            text: 'Forget password ?',
                            size: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF0047AB),
                          ),
                          onTap: (){
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) =>  ForgetPassword1()),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const TextAuth(
                        text: "Don't have an account ?",
                        size: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => Register()),
                          );
                        },
                        child: const TextAuth(
                          text: ' Sign Up',
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
    );
  }
}