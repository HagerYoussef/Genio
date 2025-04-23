import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genio_ai/features/account/account_settings.dart';
import 'package:genio_ai/features/chat_bot/chatbot.dart';
import 'package:genio_ai/features/chat_bot/new_chat.dart';
import 'package:genio_ai/features/code_generator/code_generator_screen.dart';
import 'package:genio_ai/features/email_writer/email_writer_screen.dart';
import 'package:genio_ai/features/essay_writer/essay_writer_screen.dart';
import 'package:genio_ai/features/home_screen/homescreen.dart';
import 'package:genio_ai/features/image_generation/image_generation_screen.dart';
import 'package:genio_ai/features/payment/payment_screen.dart';
import 'package:genio_ai/features/profile/profile_screen.dart';
import 'package:genio_ai/features/register/register.dart';
import 'package:genio_ai/features/splash_screen/splash_screen.dart';
import 'package:genio_ai/features/text_summerizer/text_summerizer_screen.dart';
import 'package:genio_ai/features/upgrade_screen.dart';
import 'features/forget_password/data/repositry/done_repository.dart';
import 'features/forget_password/data/repositry/reset_password_repository.dart';
import 'features/forget_password/presentation/bloc/done_bloc.dart';
import 'features/forget_password/presentation/bloc/reset_password_bloc.dart';
import 'features/login/data/repository/login_repository.dart';
import 'features/login/presentation/bloc/login_bloc.dart';
import 'features/login/presentation/login.dart';
import 'features/on_boarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authRepository: AuthRepository()),
        ),
        BlocProvider(
          create: (context) => ResetPasswordBloc(ResetPasswordRepository()),
        ),
        BlocProvider(
          create: (context) => DoneBloc( repository: DoneRepository()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          Login.routeName:(_)=>Login(),
          Register.routeName:(_)=>Register(),
          ChatBot.routeName:(_)=>ChatBot(),
          HomeScreen.routeName:(_)=>HomeScreen(),
          OnBoardingScreen.routeName:(_)=>OnBoardingScreen(),
          AccountSettings.routeName:(_)=>AccountSettings(),
          ProfileScreen.routeName:(_)=>ProfileScreen(),
          NewChatBot.routeName:(_)=>NewChatBot(),
          ImageGeneration.routeName:(_)=>ImageGeneration(),
          CodeGenerator.routeName:(_)=>CodeGenerator(),
          EmailWriter.routeName:(_)=>EmailWriter(),
          TextSummarizer.routeName:(_)=>TextSummarizer(),
          EssayWriter.routeName:(_)=>EssayWriter(),
          UpgradeScreen.routeName:(_)=>UpgradeScreen(),
          PaymentScreen.routeName: (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return PaymentScreen(
              planName: args['planName'],
              planPrice: args['planPrice'],
            );
          },
        },
        home:SplashScreen(),
        theme: ThemeData(
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color(0xff99B5DF),
            selectionColor: Color(0xff99B5DF),
            selectionHandleColor: Color(0xff99B5DF),
          ),
        ),
      ),
    );
  }
}
