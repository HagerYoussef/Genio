import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genio_ai/features/account/account_settings.dart';
import 'package:genio_ai/features/customer_support/customer_support_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'login/presentation/widgets/text_auth.dart';

class FAQScreen extends StatelessWidget {
  static String routeName = 'FACs Screen';
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F8FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFF0F8FF),
        elevation: 0,
        title: TextAuth(
          text: 'FAQs',
          size: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xff0047AB),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, AccountSettings.routeName);
          },
          icon: ImageIcon(
            AssetImage('assets/images/arrowback.png'),
            color: Color(0xff0047AB),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTopBox(
            image: 'assets/images/payment.png',
            title: 'Billing & Payments',
            subtitle: 'Questions about pricing, plans, and payment methods',
            color: const Color(0xFFD4EBFF),
          ),
          const SizedBox(height: 12),
          _buildTopBox(
            image: 'assets/images/account.png',
            title: 'Account Settings',
            subtitle: 'Help with your account, profile, and preferences',
            color: const Color(0xFFD4EBFF),
          ),
          const SizedBox(height: 12),
          _buildTopBox(
            image: 'assets/images/security.png',
            title: 'Security & Privacy',
            subtitle: 'Information about data protection and security',
            color: const Color(0xFFD4EBFF),
          ),
          const SizedBox(height: 24),
          const _FAQSection(
            title: 'Billing & Payments',
            faqs: [
              {
                'question': 'How do I change my subscription plan?',
                'answer':
                    'You can change your plan from your Account settings > View plans from upgrade section',
              },
              {
                'question': 'What payment methods do you accept?',
                'answer': 'We accept Visa',
              },
            ],
          ),
          const _FAQSection(
            title: 'Account Settings',
            faqs: [
              {
                'question': 'How do I reset my password?',
                'answer':
                    'You can reset your password from your Account settings > Profile > Edit password',
              },
              {
                'question': 'Can I change my email address?',
                'answer':
                    'Yes, you can change your email address from your Account settings > Profile > Edit email',
              },
            ],
          ),
          const _FAQSection(
            title: 'Security & Privacy',
            faqs: [
              {
                'question': 'How is my data protected?',
                'answer':
                    'We implement advanced encryption protocols and strict access controls to protect your data at every stage',
              },
              {
                'question': 'What is your privacy policy?',
                'answer':
                    'Our privacy policy explains how we collect, use, and protect your personal information. We are committed to keeping your data safe and ensuring transparency in all data handling practices. You can review our full privacy policy on our website or within the app settings',
              },
            ],
          ),
          TextAuth(
            text: 'Still have questions?',
            size: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          Container(
            width: double.infinity,
            height: 55,
            // padding: EdgeInsets.only(
            //   bottom: 5
            // ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 2),
                    child: ElevatedButton(
                      onPressed: () async {
                        CallHelper.makePhoneCall(context, '01151116632');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Color(0xff0047AB)),
                        ),
                      ),
                      child: TextAuth(
                        text: 'Make a call',
                        size: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff0047AB),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          CustomerSupportScreen.routeName,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0047AB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: TextAuth(
                        text: 'Support',
                        size: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBox({
    required String image,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ImageIcon(AssetImage(image), color: Color(0xff0047AB)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextAuth(
                  text: title,
                  size: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                const SizedBox(height: 4),
                TextAuth(
                  text: subtitle,
                  size: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff4B5563),
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Text(
                      'View FAQ',
                      style: TextStyle(color: Color(0xff2563EB)),
                    ),
                    ImageIcon(
                      AssetImage('assets/images/arrow1.png'),
                      color: Color(0xff2563EB),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQSection extends StatelessWidget {
  final String title;
  final List<Map<String, String>> faqs;

  const _FAQSection({required this.title, required this.faqs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextAuth(
          text: title,
          size: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        const SizedBox(height: 8),
        ...faqs
            .map(
              (faq) =>
                  _FAQTile(question: faq['question']!, answer: faq['answer']!),
            )
            .toList(),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _FAQTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQTile({required this.question, required this.answer});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xff99B5DD), width: 1),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        title: TextAuth(
          text: widget.question,
          size: 12,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextAuth(
              text: widget.answer,
              size: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class CallHelper {
  static const platform = MethodChannel('com.example.call');

  static Future<void> makePhoneCall(
    BuildContext context,
    String phoneNumber,
  ) async {
    try {
      await platform.invokeMethod('callPhone', {'number': phoneNumber});
    } catch (e) {
      debugPrint('فشل الاتصال: $e');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: "This device don't support phone calling!",
        confirmBtnText: 'Ok',
        confirmBtnColor: const Color(0xFF0047AB),
        confirmBtnTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white,
        ),
      );
    }
  }
}
