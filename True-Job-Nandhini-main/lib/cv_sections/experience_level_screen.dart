import 'package:flutter/material.dart';
import 'package:truejobs/cv_sections/student_template_screen.dart';

class ExperienceLevelScreen extends StatefulWidget {
  const ExperienceLevelScreen({super.key});

  @override
  State<ExperienceLevelScreen> createState() => _ExperienceLevelScreenState();
}

class _ExperienceLevelScreenState extends State<ExperienceLevelScreen> {
  String? _selected;
  String? _isStudent;
  String? _educationLevel;

  final List<String> _options = [
    'Fresher',
    'Less than 3 years',
    '3-5 years',
    '5-10 years',
    '10+ years',
  ];

  final List<String> _educationOptions = [
    'Secondary school',
    'Vocational Certificate or Diploma',
    'Apprenticeship or Internship Training',
    'Associates',
    'Bachelors',
    'Masters',
    'Doctorate or Ph.D.',
  ];

  Color get _selectedColor => const Color(0xFF19893F);

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable body ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.06,
                  vertical: sw * 0.04,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Back button ─────────────────────────────────
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back_ios_new,
                          size: sw * 0.05, color: Colors.black),
                    ),

                    SizedBox(height: sh * 0.05),

                    // ── Title ───────────────────────────────────────
                    Text(
                      'How long have you\nbeen working?',
                      style: TextStyle(
                        fontSize: sw * 0.075,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),

                    SizedBox(height: sh * 0.015),

                    // ── Subtitle ─────────────────────────────────────
                    Text(
                      "We'll find the best templates for\nyour experience level.",
                      style: TextStyle(
                        fontSize: sw * 0.038,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: sh * 0.035),

                    // ── Experience chips ─────────────────────────────
                    Wrap(
                      spacing: sw * 0.03,
                      runSpacing: sw * 0.03,
                      children: _options.map((option) {
                        final bool isSelected = _selected == option;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selected = option;
                              _isStudent = null;
                              _educationLevel = null;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.045,
                              vertical: sw * 0.025,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? _selectedColor : const Color(0xFFF2F2F2), // ash color
                              borderRadius: BorderRadius.circular(sw * 0.06),
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: sw * 0.035,
                                fontWeight: FontWeight.w500,
                                color:
                                isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // ── "Are you a student?" ─────────────────────────
                    if (_selected == 'Fresher') ...[
                      SizedBox(height: sh * 0.035),
                      Text(
                        'Are you a student?',
                        style: TextStyle(
                          fontSize: sw * 0.052,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: sh * 0.018),
                      Row(
                        children: ['Yes', 'No'].map((answer) {
                          final bool isAnswered = _isStudent == answer;
                          return Padding(
                            padding: EdgeInsets.only(right: sw * 0.03),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isStudent = answer;
                                  _educationLevel = null;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(
                                  horizontal: sw * 0.07,
                                  vertical: sw * 0.03,
                                ),
                                decoration: BoxDecoration(
                                  color: isAnswered
                                      ? const Color(0xFF19893F)
                                      : Colors.white,
                                  border: Border.all(
                                    color: isAnswered
                                        ? const Color(0xFF19893F)
                                        : Colors.grey.shade400,
                                    width: 1.2,
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(sw * 0.06),
                                ),
                                child: Text(
                                  answer,
                                  style: TextStyle(
                                    fontSize: sw * 0.038,
                                    fontWeight: FontWeight.w500,
                                    color: isAnswered
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // ── Education level section (only when Yes tapped) ──
                    if (_selected == 'Fresher' && _isStudent == 'Yes') ...[
                      SizedBox(height: sh * 0.035),
                      Text(
                        'What education level are you\ncurrently pursuing?',
                        style: TextStyle(
                          fontSize: sw * 0.048,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: sh * 0.008),
                      Text(
                        'Select the highest level you are working toward so we\ncan organize your resume correctly',
                        style: TextStyle(
                          fontSize: sw * 0.033,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: sh * 0.02),

                      // Education level list
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _educationOptions.map((edu) {
                          final bool isEduSelected = _educationLevel == edu;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _educationLevel = edu),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              margin: EdgeInsets.only(bottom: sh * 0.012),
                              padding: EdgeInsets.symmetric(
                                horizontal: sw * 0.04,
                                vertical: sw * 0.025,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(sw * 0.06),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    child: isEduSelected
                                        ? Padding(
                                      padding: EdgeInsets.only(right: sw * 0.02),
                                      child: Icon(
                                        Icons.verified,
                                        color: const Color(0xFF19893F),
                                        size: sw * 0.045,
                                      ),
                                    )
                                        : const SizedBox.shrink(),
                                  ),
                                  Text(
                                    edu,
                                    style: TextStyle(
                                      fontSize: sw * 0.036,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      // Prefer not to answer
                      GestureDetector(
                        onTap: () =>
                            setState(() => _educationLevel = 'prefer_not'),
                        child: Padding(
                          padding: EdgeInsets.only(top: sh * 0.008),
                          child: Text(
                            'Prefer not to answer',
                            style: TextStyle(
                              fontSize: sw * 0.038,
                              color: const Color(0xFF19893F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: sh * 0.03),
                    ],

                    SizedBox(height: sh * 0.02),
                  ],
                ),
              ),
            ),

            // ── Bottom buttons ────────────────────────────────────────
            if (_selected != null) ...[
              Container(
                padding: EdgeInsets.fromLTRB(
                    sw * 0.06, sw * 0.03, sw * 0.06, sw * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: SizedBox(
                        height: sw * 0.13,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: Colors.grey.shade400, width: 1.2),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(sw * 0.07),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: sw * 0.042,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: sw * 0.04),

                    // Save button
                    Expanded(
                      child: SizedBox(
                        height: sw * 0.13,
                        child: ElevatedButton(
                          onPressed: _canSave()
                              ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const StudentTemplatesScreen(),
                              ),
                            );
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF19893F),
                            disabledBackgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(sw * 0.07),
                            ),
                          ),
                          child: Text(
                            'Save',
                            style: TextStyle(
                              fontSize: sw * 0.042,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _canSave() {
    if (_selected == null) return false;
    if (_selected == 'Fresher') {
      if (_isStudent == null) return false;
      if (_isStudent == 'Yes' && _educationLevel == null) return false;
    }
    return true;
  }
}
