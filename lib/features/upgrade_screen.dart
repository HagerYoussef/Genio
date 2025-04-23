import 'package:flutter/material.dart';
import 'package:genio_ai/features/home_screen/homescreen.dart';
import 'package:genio_ai/features/login/presentation/widgets/text_auth.dart';
import 'package:genio_ai/features/payment/payment_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class UpgradeScreen extends StatelessWidget {
  static String routeName = 'upgrade screen';

  const UpgradeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 248, 255, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(240, 248, 255, 1),
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pushNamed(context, HomeScreen.routeName);
          },
          child: Icon(Icons.arrow_back_ios, color: Color(0xff0047AB)),
        ),
        title: TextAuth(
          text: 'Upgrade',
          size: 19,
          fontWeight: FontWeight.w600,
          color: Color(0xff0047AB),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              PricingCard(
                title: "Free",
                price: "0",
                planTitle: "Try Genio AI with limited access to tools",
                planBtnText: 'Get Free',
                text1: '10 AI chat messages per month',
                text2: '3 image generations',
                text3:
                    'Essay Writer: Generate up to 2 essays/month (max 800 words each)',
                text4:
                    "Code Generator: 5 code generations/month (basic level only)",
                text5:
                    "Email Writer: Write up to 3 emails/month (no templates)",
                text6: "Basic summarization (up to 500 words)",
                onTap: () {
                  print('Done');
                    QuickAlert.show(
                      context: context,
                      title: 'Info',
                      text: 'You are already in this plan',
                      type: QuickAlertType.info,
                      confirmBtnColor: const Color(0xFF0047AB),
                    );
                },
                btnColor: Color(0xff4D7EC4),
              ),
              SizedBox(height: 20),
              PricingCard(
                title: "Plus",
                price: "80",
                planTitle: "Enhanced access to all AI tools",
                planBtnText: 'Get Plus',
                text1: '500 AI chat messages per month',
                text2: '50 image generations',
                text3: 'Essay Writer: 20 essays/month (up to 1200 words)',
                text4: "Code Generator: 30 code generations (standard level)",
                text5: "Email Writer: 50 emails/month with access to smart templates",
                text6: "Advanced summarization (up to 2000 words)",
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    PaymentScreen.routeName,
                    arguments: {
                      'planName': 'Plus',
                      'planPrice': 80.0,
                    },
                  );
                },
                btnColor: Color(0xff40047AB),
              ),
              SizedBox(height: 20),
              PricingCard(
                title: "Super Plus",
                price: "120",
                planTitle: "Full power of Genio AI without limits",
                planBtnText: 'Get Pro',
                text1: 'Unlimited AI chat messages',
                text2: 'Unlimited image generations',
                text3: 'Essay Writer: Unlimited essays (up to 3000 words)',
                text4: "Code Generator: Unlimited with smart debugging & suggestions",
                text5: "Email Writer: Unlimited with tone & formatting control",
                text6: "Summarizer: Pro-level (up to 10,000 words, structured output)",
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    PaymentScreen.routeName,
                    arguments: {
                      'planName': 'Super Plus',
                      'planPrice': 120.0,
                    },
                  );

                },
                btnColor: Color(0xff4DC4BE),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String planTitle;
  final String planBtnText;
  final String text1;
  final String text2;
  final String text3;
  final String text4;
  final String text5;
  final String text6;
  VoidCallback onTap;
  final Color btnColor;

  PricingCard({
    required this.title,
    required this.price,
    required this.planTitle,
    required this.planBtnText,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.text4,
    required this.text5,
    required this.text6,
    required this.onTap,
    required this.btnColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        color: Color(0xFFE6F0FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color.fromRGBO(149, 186, 230, 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextAuth(
            text: title,
            size: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextAuth(
                text: '\$',
                size: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xff80A3D5),
              ),
              TextAuth(
                text: price,
                size: 32,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextAuth(
                      text: 'USD/',
                      size: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff80A3D5),
                    ),
                    TextAuth(
                      text: 'Month',
                      size: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff80A3D5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          TextAuth(
            text: planTitle,
            size: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xff80A3D5),
          ),
          SizedBox(height: 15),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size(double.infinity, 45),
            ),
            child: TextAuth(
              text: planBtnText,
              size: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage('assets/images/right.png'),
                      color: Color(0xff344054),
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextAuth(
                        text: text1,
                        size: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff344054),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage('assets/images/right.png'),
                      color: Color(0xff344054),
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextAuth(
                        text: text2,
                        size: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff344054),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage('assets/images/right.png'),
                      color: Color(0xff344054),
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextAuth(
                        text: text3,
                        size: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff344054),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage('assets/images/right.png'),
                      color: Color(0xff344054),
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextAuth(
                        text: text4,
                        size: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff344054),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage('assets/images/right.png'),
                      color: Color(0xff344054),
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextAuth(
                        text: text5,
                        size: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff344054),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage('assets/images/right.png'),
                      color: Color(0xff344054),
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextAuth(
                        text: text6,
                        size: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff344054),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          GestureDetector(
            onTap: () {},
            child: Text(
              'Have an existing plan? See billing here',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 14.4,
                color: Color(0xff6691CD),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
