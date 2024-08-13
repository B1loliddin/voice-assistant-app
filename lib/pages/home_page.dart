import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant_app/services/constants/colors.dart';
import 'package:voice_assistant_app/services/constants/fonts.dart';
import 'package:voice_assistant_app/services/constants/images.dart';
import 'package:voice_assistant_app/services/constants/strings.dart';
import 'package:voice_assistant_app/services/network/openai_service.dart';
import 'package:voice_assistant_app/widgets/suggestion_box.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechToText speechToText = SpeechToText();
  final OpenAIService openAIService = OpenAIService();
  final FlutterTts flutterTts = FlutterTts();
  String lastWords = '';
  String? generatedContent;
  String? generatedImageUrl;

  @override
  void initState() {
    super.initState();
    _initSpeechToText();
    _initTextToSpeech();
  }

  @override
  void dispose() {
    speechToText.stop();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _initTextToSpeech() async =>
      setState(() async => await flutterTts.setSharedInstance(true));

  Future<void> _initSpeechToText() async =>
      setState(() async => await speechToText.initialize());

  void _onSpeechResult(SpeechRecognitionResult result) =>
      setState(() => lastWords = result.recognizedWords);

  Future<void> _startListening() async => setState(
      () async => await speechToText.listen(onResult: _onSpeechResult));

  Future<void> _stopListening() async =>
      setState(() async => await speechToText.cancel());

  Future<void> systemSpeak(String content) async => flutterTts.speak(content);

  Future<void> onPressedFAB() async {
    if (await speechToText.hasPermission && speechToText.isNotListening) {
      await _startListening();
    } else if (speechToText.isListening) {
      final response = await openAIService.isArtPromptApi(lastWords);

      if (response.contains('https')) {
        generatedImageUrl = response;
        generatedContent = null;
        setState(() {});
      } else {
        generatedImageUrl = null;
        generatedContent = response;
        setState(() {});

        await systemSpeak(response);
      }

      await _stopListening();
    } else {
      _initSpeechToText();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
        ),
        title: const Text(CustomStrings.appBarTitle),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 5),

            /// #voice assistant image
            const Stack(
              children: [
                ClipOval(
                  child: ColoredBox(
                    color: CustomColors.assistantCircleColor,
                    child: SizedBox(
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),
                ClipOval(
                  child: Image(
                    image: AssetImage(
                      CustomImages.virtualAssistant,
                    ),
                    width: 120,
                    height: 120,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            /// #chat bubble
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: CustomColors.borderColor),
                  borderRadius: const BorderRadius.all(Radius.circular(20))
                      .copyWith(topLeft: const Radius.circular(0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Text(
                    generatedContent ?? CustomStrings.welcomeText,
                    style: TextStyle(
                      fontSize: generatedContent == null ? 25 : 18,
                      fontFamily: CustomFonts.ceraPro,
                      color: CustomColors.mainFontColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// #response image
            if (generatedImageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: Image(
                  image: NetworkImage(generatedImageUrl!),
                  fit: BoxFit.cover,
                ),
              ),

            /// #suggestions text
            Visibility(
              visible: generatedImageUrl == null && generatedContent == null,
              child: const Padding(
                padding: EdgeInsets.only(left: 32),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    CustomStrings.suggestionCommandsText,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: CustomFonts.ceraPro,
                      fontWeight: FontWeight.bold,
                      color: CustomColors.mainFontColor,
                    ),
                  ),
                ),
              ),
            ),
            generatedImageUrl == null
                ? const SizedBox(height: 20)
                : const SizedBox.shrink(),

            /// #suggestions list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Visibility(
                visible: generatedImageUrl == null && generatedContent == null,
                child: const Column(
                  children: [
                    SuggestionBox(
                      color: CustomColors.firstSuggestionBoxColor,
                      headerText: CustomStrings.chatGPT,
                      descriptionText: CustomStrings.chatGPTDescription,
                    ),
                    SizedBox(height: 20),
                    SuggestionBox(
                      color: CustomColors.secondSuggestionBoxColor,
                      headerText: CustomStrings.dallE,
                      descriptionText: CustomStrings.dallEDescription,
                    ),
                    SizedBox(height: 20),
                    SuggestionBox(
                      color: CustomColors.thirdSuggestionBoxColor,
                      headerText: CustomStrings.smartVoiceAssistant,
                      descriptionText:
                          CustomStrings.smartVoiceAssistantDescription,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onPressedFAB,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Icon(
            speechToText.isListening ? Icons.stop : Icons.mic,
            key: ValueKey<bool>(speechToText.isListening),
            color: CustomColors.darkPurple,
          ),
        ),
      ),
    );
  }
}
