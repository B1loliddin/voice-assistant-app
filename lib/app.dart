import 'package:flutter/material.dart';
import 'package:voice_assistant_app/pages/home_page.dart';
import 'package:voice_assistant_app/services/constants/colors.dart';

class VoiceAssistant extends StatelessWidget {
  const VoiceAssistant({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: CustomColors.whiteColor,
        appBarTheme: AppBarTheme(color: CustomColors.whiteColor),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      home: HomePage(),
    );
  }
}
