import 'package:flutter/material.dart';
import 'package:truejobs/constants/app_colors.dart';

class LanguageSelectionBottomSheet extends StatefulWidget {
  final String currentLanguage;
  final ValueChanged<String> onLanguageSelected;

  const LanguageSelectionBottomSheet({
    super.key,
    required this.currentLanguage,
    required this.onLanguageSelected,
  });

  @override
  State<LanguageSelectionBottomSheet> createState() =>
      _LanguageSelectionBottomSheetState();
}

class _LanguageSelectionBottomSheetState
    extends State<LanguageSelectionBottomSheet> {
  late String _selectedLanguage;

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'display': 'English( English)'},
    {'name': 'Tamil', 'display': 'தமிழ்( Tamil)'},
    {'name': 'Malayalam', 'display': 'മലയാളം( Malayalam)'},
    {'name': 'Telugu', 'display': 'తెలుగు( Telugu)'},
    {'name': 'Kannada', 'display': 'ಕನ್ನಡ( Kannada)'},
    {'name': 'Marathi', 'display': 'मराठी( Marathi)'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final Color cardBg = AppColors.dynamicCardBg;
    final Color textColor = AppColors.dynamicText;
    final Color borderColor = AppColors.dynamicBorder;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose Your Language',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: AppColors.primary,
                    size: screenWidth * 0.06,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),

          // Language List
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(screenWidth * 0.04),
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                final bool isSelected = _selectedLanguage == language['name'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language['name']!;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE7EFFF)
                          : cardBg,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : borderColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          language['display']!,
                          style: TextStyle(
                            fontSize: screenWidth * 0.038,
                            color: textColor,
                          ),
                        ),
                        Container(
                          width: screenWidth * 0.05,
                          height: screenWidth * 0.05,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : borderColor,
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: screenWidth * 0.03,
                                    height: screenWidth * 0.03,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Divider(height: 1, color: borderColor),

          // Bottom Next Button
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.02,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  widget.onLanguageSelected(_selectedLanguage);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenHeight * 0.012,
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Next ',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_double_arrow_right,
                      color: Colors.white,
                      size: screenWidth * 0.04,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
