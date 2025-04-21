import 'package:flutter/material.dart';
import 'package:genio_ai/features/chat_bot/new_chat.dart';
import 'package:genio_ai/features/login/presentation/widgets/text_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class OtherModels extends StatefulWidget {
  const OtherModels({super.key});

  @override
  State<OtherModels> createState() => _OtherModelsState();
}

class _OtherModelsState extends State<OtherModels> {
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    loadProfileImage();
  }

  void loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profileImageUrl = prefs.getString('profile_image_url');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xFFF0F8FF),
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 35),
          children: [
            Container(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 20,
                bottom: 10
              ),
              color: Color(0xFFF0F8FF),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : const AssetImage('assets/images/img.png') as ImageProvider,
                  ),
                  SizedBox(width: 10),
                  TextAuth(text: 'View Profile', size: 16, fontWeight: FontWeight.w500, color: Color(0XFF0047AB))
                ],
              ),
            ),
            Divider(
              indent: 20,
              endIndent: 25,
              color: Color(0XFF99B5DD),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextAuth(text: 'You can use another features\nwith a new chat', size: 17, fontWeight: FontWeight.w500, color: Color(0XFF0047AB)),
            ),
            _buildFeatureTile(
              context,
              icon: 'assets/images/chatbot.png',
              title: 'Chat Bot',
            ),
            _buildFeatureTile(
              context,
              icon: 'assets/images/image generation.png',
              title: 'image generation',
            ),
            _buildFeatureTile(
              context,
              icon: 'assets/images/Code Generator.png',
              title: 'Code Generator',
            ),
            _buildFeatureTile(
              context,
              icon: 'assets/images/Email Writer.png',
              title: 'Email Writer',
            ),
            _buildFeatureTile(
              context,
              icon: 'assets/images/Text Summarizer.png',
              title: 'Text Summarizer',
            ),
            _buildFeatureTile(
              context,
              icon: 'assets/images/Create Presentaion.png',
              title: 'Create Presentation',
            ),
            _buildFeatureTile(
              context,
              icon: 'assets/images/Essay Writer.png',
              title: 'Essay Writer',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(BuildContext context, {required String icon, required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          final newChatId = const Uuid().v4();
          await prefs.setString('chatId', newChatId); // 🆕 تخزين chatId جديد
          Navigator.pushNamed(context, NewChatBot.routeName);
        },
        child: Container(
          height: 76,
          padding: EdgeInsets.symmetric(vertical: 3,horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              width: 0.5,
              color: Colors.black12
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(icon, width: 55, height: 55),
              SizedBox(width: 16),
              TextAuth(text: title, size: 16, fontWeight: FontWeight.w500, color: Color(0XFF344054))
            ],
          ),
        ),
      ),
    );
  }
}
