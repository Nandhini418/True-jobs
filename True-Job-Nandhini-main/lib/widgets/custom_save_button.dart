import 'package:flutter/material.dart';
import 'package:truejobs/constants/app_colors.dart';

class CustomSaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const CustomSaveButton({
    super.key,
    required this.onPressed,
    this.text = 'Save',
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFE0E0E0),
        disabledForegroundColor: const Color(0xFFAAAAAA),
        minimumSize: Size(double.infinity, screenHeight * 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.08),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
