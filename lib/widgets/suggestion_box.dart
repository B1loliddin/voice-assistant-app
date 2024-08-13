import 'package:flutter/material.dart';
import 'package:voice_assistant_app/services/constants/colors.dart';
import 'package:voice_assistant_app/services/constants/fonts.dart';

class SuggestionBox extends StatelessWidget {
  final Color color;
  final String headerText;
  final String descriptionText;

  const SuggestionBox({
    super.key,
    required this.color,
    required this.headerText,
    required this.descriptionText,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(

          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                headerText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.blackColor,
                  fontFamily: CustomFonts.ceraPro,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                descriptionText,
                style: const TextStyle(
                  color: CustomColors.blackColor,
                  fontFamily: CustomFonts.ceraPro,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
