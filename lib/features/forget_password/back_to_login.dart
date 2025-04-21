import 'package:flutter/material.dart';
import 'package:genio_ai/features/forget_password/presentation/widgets/done_button.dart';
import '../login/presentation/login.dart';
import '../login/presentation/widgets/text_auth.dart';

class BackToLogin extends StatelessWidget {
  const BackToLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F8FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 190,
                height: 220,
                child: Image.asset('assets/images/RobotGroup.png'),
              ),
              const SizedBox(
                height: 20,
              ),
              const Center(child: TextAuth(text: 'Successfully Changed', size: 18, fontWeight: FontWeight.w600, color: Color(0xff0047AB))),
              SizedBox(
                height: 20,
              ),
              DoneButton(onPressed: (){
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => Login()));
              }, text: 'Go To Login',),
            ],
          ),
        ),
      ),
    );
  }
}
