import 'package:flutter/material.dart';

class CvTemplateState {
  static String? selectedTemplatePath;

  static void showPreviewDialog(BuildContext context) {
    if (selectedTemplatePath == null) return;

    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: sh * 0.9, // 90% of screen height
          padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.05),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Our Resume Builder delivers results',
                    style: TextStyle(
                      fontSize: sw * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: Colors.black, size: sw * 0.06),
                  ),
                ],
              ),
              SizedBox(height: sw * 0.05),

              // Stats Pill
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: sw * 0.03),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBEBEB),
                  borderRadius: BorderRadius.circular(sw * 0.06),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_upward, color: const Color(0xFF5D82A2), size: sw * 0.045),
                    SizedBox(width: sw * 0.02),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '50% ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: sw * 0.035,
                            ),
                          ),
                          TextSpan(
                            text: 'Increase in dream job prospects',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: sw * 0.035,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: sw * 0.06),

              // CV Image Preview
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    selectedTemplatePath!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: sw * 0.06),

              // Change Template Link
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Close dialog
                  // Note: In a real app, this should navigate back to the templates screen.
                  // Since the user is deep in the CV flow, we might need to pop until the template screen.
                  Navigator.popUntil(context, (route) => route.settings.name == '/templates' || route.isFirst);
                },
                child: Text(
                  'Change Template',
                  style: TextStyle(
                    color: const Color(0xFF3366CC),
                    fontSize: sw * 0.045,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFF3366CC),
                  ),
                ),
              ),
              SizedBox(height: sw * 0.04),
            ],
          ),
        );
      },
    );
  }
}
