import 'package:flutter/material.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/widgets/condition_type_sheet.dart';
import 'package:truejobs/widgets/affected_area_sheet.dart';

class DisabilityPopup extends StatefulWidget {
  final String initialCondition;
  final String initialArea;

  const DisabilityPopup({
    super.key,
    required this.initialCondition,
    required this.initialArea,
  });

  @override
  State<DisabilityPopup> createState() => _DisabilityPopupState();
}

class _DisabilityPopupState extends State<DisabilityPopup> {
  late String _selectedCondition;
  late String _selectedArea;

  @override
  void initState() {
    super.initState();
    _selectedCondition = widget.initialCondition;
    _selectedArea = widget.initialArea;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color borderColor = AppColors.dynamicBorder;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenWidth * 0.06, screenWidth * 0.05, screenWidth * 0.08),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset('assets/briefcase.png',
                    height: screenHeight * 0.03,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    "Explain us , we'll help you to get job",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, color: AppColors.primary, size: screenWidth * 0.05),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.01),
          Divider(color: borderColor, thickness: 0.5,),
          SizedBox(height: screenWidth * 0.025),

          Text(
            'Condition type',
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: screenWidth * 0.015),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => ConditionTypeSheet(
                  currentCondition: _selectedCondition,
                  onConditionSelected: (newCond) {
                    setState(() {
                      _selectedCondition = newCond;
                    });
                  },
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.035),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCondition,
                    style: TextStyle(
                      color: _selectedCondition == 'Select here' ? Colors.grey[400] : textColor,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: textColor, size: screenWidth * 0.05),
                ],
              ),
            ),
          ),

          SizedBox(height: screenWidth * 0.04),

          Text(
            'Affected area',
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: screenWidth * 0.015),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AffectedAreaSheet(
                  currentArea: _selectedArea,
                  onAreaSelected: (newArea) {
                    setState(() {
                      _selectedArea = newArea;
                    });
                  },
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.035),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedArea,
                    style: TextStyle(
                      color: _selectedArea == 'Select here' ? Colors.grey[400] : textColor,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: textColor, size: screenWidth * 0.05),
                ],
              ),
            ),
          ),

          SizedBox(height: screenWidth * 0.06),

          // Cancel & Save Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0E0E0),
                    foregroundColor: textColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.08),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'cond_type': _selectedCondition,
                      'affect_area': _selectedArea,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.08),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
        ],
      ),
    );
  }
}
