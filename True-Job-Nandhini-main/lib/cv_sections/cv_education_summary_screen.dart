import 'package:flutter/material.dart';
import 'dart:ui';

import 'cv_education_screen.dart';
import 'cv_experience_screen.dart';
import 'cv_template_state.dart';

class CvEducationSummaryScreen extends StatefulWidget {
  final List<Map<String, String>> educations;
  const CvEducationSummaryScreen({
    super.key,
    this.educations = const [{
      'institute': 'SNS College of Engineering',
      'degree': 'MBA',
      'fieldOfStudy': 'Information Technology',
      'month': 'January',
      'year': '2026'
    }]
  });

  @override
  State<CvEducationSummaryScreen> createState() => _CvEducationSummaryScreenState();
}

class _CvEducationSummaryScreenState extends State<CvEducationSummaryScreen> {
  List<Map<String, String>> _localEducations = [];

  @override
  void initState() {
    super.initState();
    _localEducations = List.from(widget.educations);
  }

  void _showTipsPopup(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: sw * 0.05),
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(right: sw * 0.06),
                child: ClipPath(
                  clipper: _TriangleClipper(),
                  child: Container(
                    width: sw * 0.06,
                    height: sw * 0.04,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(sw * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(sw * 0.03),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.lightbulb, color: const Color(0xFF2C5BA8), size: sw * 0.07),
                            Icon(Icons.star, color: Colors.white, size: sw * 0.03),
                          ],
                        ),
                        SizedBox(width: sw * 0.03),
                        Text(
                          "Tips for Adding Education",
                          style: TextStyle(
                            fontSize: sw * 0.048,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sw * 0.05),
                    _buildTipItem("Add your highest qualification first", sw),
                    _buildTipItem("Use your official degree name", sw),
                    _buildTipItem("If still studying, select expected graduation date", sw),
                    _buildTipItem("Add your specialization (Field of Study) clearly", sw),
                    _buildTipItem("Keep details short and accurate", sw),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTipItem(String text, double sw) {
    return Padding(
      padding: EdgeInsets.only(bottom: sw * 0.035),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: sw * 0.005),
            child: Icon(Icons.star, color: const Color(0xFF2C5BA8), size: sw * 0.04),
          ),
          SizedBox(width: sw * 0.03),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: sw * 0.038,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back_ios_new, size: sw * 0.05, color: Colors.black),
                    ),
                    SizedBox(height: sw * 0.05),

                    // Header Texts
                    Text(
                      "Education summary",
                      style: TextStyle(
                        fontSize: sw * 0.065,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: sw * 0.03),
                    Text(
                      "Review your education to ensure it's up to date,\nincluding any current programs or training.",
                      style: TextStyle(
                        fontSize: sw * 0.035,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: sw * 0.03),

                    // Tips Button aligned to right
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => _showTipsPopup(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lightbulb_outline, size: sw * 0.04, color: const Color(0xFF4A72D6)),
                            SizedBox(width: sw * 0.01),
                            Text(
                              "Tips",
                              style: TextStyle(
                                fontSize: sw * 0.035,
                                color: const Color(0xFF4A72D6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: sw * 0.05),

                    // Education Cards
                    if (_localEducations.isEmpty)
                      const Center(child: Text("No education added yet.", style: TextStyle(color: Colors.grey))),
                    ..._localEducations.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Map<String, String> edu = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: sw * 0.05),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(sw * 0.04),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(sw * 0.03),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: sw * 0.035,
                                    backgroundColor: const Color(0xFF2C5BA8), // Dark Blue
                                    child: Text(
                                      '${idx + 1}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: sw * 0.035,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: sw * 0.03),
                                  Text(
                                    edu['degree'] ?? 'Unknown Degree',
                                    style: TextStyle(
                                      fontSize: sw * 0.042,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.edit, color: const Color(0xFF00AEEF), size: sw * 0.05),
                                  SizedBox(width: sw * 0.03),
                                  GestureDetector(
                                    onTap: () => _showDeleteDialog(idx),
                                    child: Icon(Icons.delete, color: Colors.red.shade400, size: sw * 0.05),
                                  ),
                                ],
                              ),
                              SizedBox(height: sw * 0.03),
                              Text(
                                edu['fieldOfStudy'] ?? 'Unknown Field',
                                style: TextStyle(
                                  fontSize: sw * 0.035,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: sw * 0.01),
                              Text(
                                edu['institute'] ?? 'Unknown Institute',
                                style: TextStyle(
                                  fontSize: sw * 0.038,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: sw * 0.02),
                              Text(
                                '${edu['month']} ${edu['year']}'.trim().isEmpty ? 'Present' : '${edu['month']} ${edu['year']}',
                                style: TextStyle(
                                  fontSize: sw * 0.035,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    // Add Another Button (Dashed)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CvEducationScreen(existingEducations: _localEducations),
                          ),
                        );
                      },
                      child: CustomPaint(
                        painter: _DashedRectPainter(),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: sw * 0.04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: const Color(0xFF00AEEF), size: sw * 0.05),
                              SizedBox(width: sw * 0.02),
                              Text(
                                'Add another',
                                style: TextStyle(
                                  color: const Color(0xFF00AEEF),
                                  fontSize: sw * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        CvTemplateState.showPreviewDialog(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: sw * 0.04),
                        side: const BorderSide(color: Colors.black87),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(sw * 0.08),
                        ),
                      ),
                      child: Text(
                        'Preview',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: sw * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.04),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CvExperienceScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF19893F), // Green
                        padding: EdgeInsets.symmetric(vertical: sw * 0.04),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(sw * 0.08),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Next: Experience',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Delete this entry?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "This can't be undone.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF5A94FF),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _localEducations.removeAt(index);
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD3493A), // Red color from the image
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0); // Top center point
    path.lineTo(size.width, size.height); // Bottom right
    path.lineTo(0, size.height); // Bottom left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();
    final double dashWidth = 5.0;
    final double dashSpace = 3.0;

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
