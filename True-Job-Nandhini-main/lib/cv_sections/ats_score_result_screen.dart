import 'dart:math';
import 'package:flutter/material.dart';

class AtsScoreResultScreen extends StatelessWidget {
  const AtsScoreResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Colors.black, size: 28),
            onPressed: () {},
          ),
          SizedBox(width: sw * 0.02),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                child: Column(
                  children: [
                    SizedBox(height: sw * 0.06),
                    Text(
                      'ATS Score Result',
                      style: TextStyle(
                        fontSize: sw * 0.055,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: sw * 0.08),

                    // Gauge Chart
                    SizedBox(
                      width: sw * 0.6,
                      height: sw * 0.4,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: Size(sw * 0.6, sw * 0.4),
                            painter: _GaugePainter(score: 0.78),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: sw * 0.05), // push down a bit
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '78',
                                    style: TextStyle(
                                      fontSize: sw * 0.12,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                  Text(
                                    '%',
                                    style: TextStyle(
                                      fontSize: sw * 0.06,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: sw * 0.01),
                              Text(
                                '4 Issues Found',
                                style: TextStyle(
                                  fontSize: sw * 0.035,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFD92D20),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: sw * 0.08),

                    // Description
                    Text(
                      'Your resume has a good match with\nthe job requirements.\nkeep improving toget an excellent\nscore!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: sw * 0.035,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: sw * 0.08),

                    // Alert Box
                    Container(
                      padding: EdgeInsets.all(sw * 0.04),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F5FF),
                        border: Border.all(color: const Color(0xFFE9D7FE)),
                        borderRadius: BorderRadius.circular(sw * 0.03),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(sw * 0.02),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.emoji_events,
                              color: const Color(0xFFFDB022),
                              size: sw * 0.06,
                            ),
                          ),
                          SizedBox(width: sw * 0.04),
                          Expanded(
                            child: Text(
                              'Great! Your resume is better than 68%\nof other applicants.',
                              style: TextStyle(
                                fontSize: sw * 0.032,
                                color: const Color(0xFF6941C6),
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sw * 0.06),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Container(
              padding: EdgeInsets.all(sw * 0.05),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF19893F),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, sw * 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(sw * 0.06),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View Improvements',
                      style: TextStyle(
                        fontSize: sw * 0.038,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: sw * 0.02),
                    Icon(Icons.arrow_forward_ios, size: sw * 0.035),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double score;

  _GaugePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);

    // Background arc (grey)
    final Paint bgPaint = Paint()
      ..color = const Color(0xFFF3F4F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    // Start angle: 140 degrees (in radians)
    // Sweep angle: 260 degrees (in radians)
    const double startAngle = 140 * pi / 180;
    const double sweepAngle = 260 * pi / 180;

    canvas.drawArc(rect, startAngle, sweepAngle, false, bgPaint);

    // Foreground arc (gradient)
    final Gradient gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: const [
        Color(0xFFF04438), // Red
        Color(0xFFF79009), // Orange
        Color(0xFFFDB022), // Yellow
        Color(0xFF12B76A), // Green
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );

    final Paint fgPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    final double actualSweep = sweepAngle * score;

    canvas.drawArc(rect, startAngle, actualSweep, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
