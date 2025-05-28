import 'package:flutter/cupertino.dart';
import '../features/FACs_screen.dart';
import '../features/account/account_settings.dart';
import '../features/chat_bot/new_chat.dart';
import '../features/home_screen/homescreen.dart';
import '../features/image_generation/image_generation_screen.dart';
import '../features/login/presentation/login.dart';
import '../features/on_boarding_screen.dart';
import '../features/payment/payment_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/register/register.dart';
import '../features/upgrade_screen.dart';

class AppRoutes {
  static Future<Map<String, dynamic>> get routes async => {
    Login.routeName:(_)=>Login(),
    Register.routeName:(_)=>Register(),
    NewChatBot.routeName: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final from = args?['from'];
      final bool startNew = (from != "home");
      return NewChatBot(startNewChat: startNew);
    },
    HomeScreen.routeName:(_)=>HomeScreen(),
    OnBoardingScreen.routeName:(_)=>OnBoardingScreen(),
    AccountSettings.routeName:(_)=>AccountSettings(),
    ProfileScreen.routeName:(_)=>ProfileScreen(),
    NewChatBot.routeName:(_)=>NewChatBot(),
    ImageGeneration.routeName: (context) => const ImageGeneration(),
    //CodeGenerator.routeName:(_)=>CodeGenerator(),
    //EmailWriter.routeName:(_)=>EmailWriter(),
    //TextSummarizer.routeName:(_)=>TextSummarizer(),
    //EssayWriter.routeName:(_)=>EssayWriter(),
    UpgradeScreen.routeName:(_)=>UpgradeScreen(),
    PaymentScreen.routeName: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return PaymentScreen(
        planName: args['planName'],
        planPrice: args['planPrice'],
      );
    },
    FAQScreen.routeName:(_)=>FAQScreen(),

  };
}