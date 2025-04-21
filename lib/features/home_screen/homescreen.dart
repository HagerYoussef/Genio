import 'package:flutter/material.dart';
import 'package:genio_ai/features/account/account_settings.dart';
import 'package:genio_ai/features/history/history_screen.dart';
import 'package:genio_ai/features/home_screen/presentation/widgets/ai_tools_container.dart';
import 'package:genio_ai/features/other_models/other_models.dart';
import '../chat_bot/chatbot.dart';
import '../login/presentation/widgets/text_auth.dart';
import '../upgrade_screen.dart';
class HomeScreen extends StatelessWidget {
  static const routeName ='HomeScreen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> aiTools = [
      AiToolsContainer(
        text: 'Chat Bot',
        imagePath: 'assets/images/chatbot.png',
          onTap: () {
            Navigator.pushNamed(context, ChatBot.routeName);
        },
      ),
      AiToolsContainer(
        text: 'Image Generation',
        imagePath: 'assets/images/image generation.png',
        onTap: () {  },
      ),
      AiToolsContainer(
        text: 'Code Generator',
        imagePath: 'assets/images/Code Generator.png',
        onTap: () {  },
      ),
      AiToolsContainer(
        text: 'Email Writer',
        imagePath: 'assets/images/Email Writer.png',
        onTap: () {  },
      ),
      AiToolsContainer(
        text: 'Text Summarizer',
        imagePath: 'assets/images/Text Summarizer.png',
        onTap: () {  },
      ),
      AiToolsContainer(
        text: 'Essay Writer',
        imagePath: 'assets/images/Essay Writer.png',
        onTap: () {},
      ),
    ];
    return Scaffold(
      drawer: History(),
      endDrawer: OtherModels(),
      backgroundColor: const Color(0xffF0F8FF),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(85),
        child: AppBar(
          toolbarHeight: 100,
          scrolledUnderElevation:0.5,
          shadowColor : const Color(0xffF0F8FF),
          backgroundColor: const Color(0xffF0F8FF),
          leading: Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const ImageIcon(AssetImage('assets/images/menu.png'),color: Color(0xff0047AB),size: 24,),
              );
            }
          ),
          title: Center(
            child: Container(
              width: 130,
              height:32,
              decoration: BoxDecoration(
                color: Color(0xffD4EBFF),
                borderRadius: BorderRadius.circular(12)
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => UpgradeScreen()),
                      );
                    },
                    icon: const ImageIcon(AssetImage('assets/images/flash.png'),color: Color(0xff0047AB),size: 24,),
                  ),
                  TextAuth(text: 'Upgrade', size: 13, fontWeight: FontWeight.w500, color: Color(0xff0047AB)),
                ],
              ),
            ),
          ),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  icon: const ImageIcon(AssetImage('assets/images/edit.png'),color: Color(0xff0047AB),size: 24,),
                );
              }
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, AccountSettings.routeName);
              },
              icon: const ImageIcon(
                AssetImage('assets/images/menu_vector.png')
                ,color: Color(0xff0047AB),size: 24,),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1), // Divider height
            child: Container(
              color: Color(0xff0047AB),// Divider color
              height: 0.5, // Divider thickness
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20,bottom: 50,left: 12,right: 12),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // عدد الأعمدة
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 130 / 120,
            ),
            itemCount: aiTools.length, // عدد العناصر في الشبكة
            itemBuilder: (context, index) {
              return aiTools[index];
            },
          ),
        ),
      )
      );
  }
}