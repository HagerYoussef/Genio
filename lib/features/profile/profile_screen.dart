import 'package:flutter/material.dart';
import 'package:genio_ai/features/login/presentation/widgets/text_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static String routeName = 'Profile screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F8FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFF0F8FF),
        elevation: 0,
        title: TextAuth(text: 'Profile', size: 20, fontWeight: FontWeight.w600, color: Color(0xff0047AB)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: ImageIcon(
            AssetImage('assets/images/arrowback.png'),
            color: Color(0xff0047AB),
          ),
        ),
      ),
      body: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/user.png'),
                radius: 50,
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: (){}, icon: Image(image: AssetImage('assets/images/edit.png'),color: Color(0XFF344054),)),
                  TextButton(
                    onPressed: () {
                      // Do something
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Change',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color(0xFF344054),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF344054),
                        decorationThickness: 1.2,
                      ),
                    ),
                  )

                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
