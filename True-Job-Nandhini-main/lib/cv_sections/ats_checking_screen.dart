import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:truejobs/cv_sections/ats_score_result_screen.dart';
import 'dart:ui';
import 'dart:async';

enum AtsState {
  initial,
  scanning,
  done,
}

class AtsCheckingScreen extends StatefulWidget {
  const AtsCheckingScreen({super.key});

  @override
  State<AtsCheckingScreen> createState() => _AtsCheckingScreenState();
}

class _AtsCheckingScreenState extends State<AtsCheckingScreen> {
  AtsState _currentState = AtsState.initial;

  // To simulate the checklist progress
  int _currentStep = 0;
  final List<String> _steps = [
    'Reading resume content',
    'Extracting skills and experience',
    'Matching keywords',
    'Checking ATS compatibility',
    'Generating suggestions',
  ];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      String extension = result.files.single.extension?.toLowerCase() ?? '';

      if (extension != 'pdf' && extension != 'doc' && extension != 'docx') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid file! Please upload only a Resume document (PDF or DOCX).', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Start scanning process
      setState(() {
        _currentState = AtsState.scanning;
        _currentStep = 0;
      });

      _runScanningSimulation();
    }
  }

  void _runScanningSimulation() async {
    for (int i = 0; i < _steps.length; i++) {
      // Simulate each step taking a second
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      setState(() {
        _currentStep++;
      });
    }

    // All steps complete
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _currentState = AtsState.done;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB), // light gray background from screenshot
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: sw * 0.05),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: sw * 0.04),

              // Dynamic Title
              Text(
                _currentState == AtsState.initial
                    ? 'Is your resume good\nenough?'
                    : _currentState == AtsState.scanning
                    ? 'Analyzing your resume'
                    : 'Analysis complete!',
                style: TextStyle(
                  fontSize: sw * 0.065,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              SizedBox(height: sw * 0.02),

              // Dynamic Subtitle
              Text(
                _currentState == AtsState.initial
                    ? 'Get a detailed analysis and tips to improve\nyour resume score.'
                    : _currentState == AtsState.scanning
                    ? 'This may take a few minutes'
                    : 'We found some areas where you can improve.',
                style: TextStyle(
                  fontSize: sw * 0.035,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              SizedBox(height: sw * 0.08),

              // Dashed Box Area
              CustomPaint(
                foregroundPainter: _DashedRectPainter(
                  color: const Color(0xFF19893F),
                  borderRadius: sw * 0.03,
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: sw * 0.1, horizontal: sw * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(sw * 0.03),
                  ),
                  child: Column(
                    children: [
                      if (_currentState == AtsState.initial) ...[
                        Text(
                          'Drop your resume here or choose a file.\nPDF & DOCX only. Max 2MB file size.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: sw * 0.032,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: sw * 0.06),
                        ElevatedButton(
                          onPressed: _pickFile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF19893F),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(sw * 0.06),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: sw * 0.08, vertical: sw * 0.035),
                          ),
                          child: Text(
                            'Upload Your Resume',
                            style: TextStyle(fontSize: sw * 0.04, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ] else if (_currentState == AtsState.scanning) ...[
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5A94FF)),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: sw * 0.06),
                        Text(
                          'We are scanning your file.',
                          style: TextStyle(
                            fontSize: sw * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: sw * 0.02),
                        Text(
                          'Drop your resume here or choose a file.\nPDF & DOCX only. Max 2MB file size.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: sw * 0.032,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ] else if (_currentState == AtsState.done) ...[
                        Container(
                          padding: EdgeInsets.all(sw * 0.02),
                          decoration: const BoxDecoration(
                            color: Color(0xFF19893F),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check, color: Colors.white, size: sw * 0.08),
                        ),
                        SizedBox(height: sw * 0.06),
                        Text(
                          'Your resume report is ready',
                          style: TextStyle(
                            fontSize: sw * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: sw * 0.06),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AtsScoreResultScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF19893F),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(sw * 0.06),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: sw * 0.08, vertical: sw * 0.035),
                          ),
                          child: Text(
                            'View Detailed Report',
                            style: TextStyle(fontSize: sw * 0.04, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),

              // Checklist Card (only visible during scanning or when done)
              if (_currentState != AtsState.initial) ...[
                SizedBox(height: sw * 0.08),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(sw * 0.05),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(sw * 0.03),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: _steps.asMap().entries.map((entry) {
                      int idx = entry.key;
                      String stepName = entry.value;

                      bool isCompleted = _currentStep > idx;
                      bool isCurrent = _currentStep == idx && _currentState == AtsState.scanning;

                      Widget trailingIcon;
                      if (isCompleted) {
                        trailingIcon = Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF19893F), width: 1.5),
                          ),
                          child: Icon(Icons.check, color: const Color(0xFF19893F), size: sw * 0.03),
                        );
                      } else if (isCurrent) {
                        trailingIcon = SizedBox(
                          width: sw * 0.045,
                          height: sw * 0.045,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
                          ),
                        );
                      } else {
                        // Pending
                        trailingIcon = Container(
                          width: sw * 0.045,
                          height: sw * 0.045,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300, width: 1.5),
                          ),
                        );
                      }

                      return Padding(
                        padding: EdgeInsets.only(bottom: idx == _steps.length - 1 ? 0 : sw * 0.04),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              stepName,
                              style: TextStyle(
                                fontSize: sw * 0.035,
                                color: Colors.black87,
                              ),
                            ),
                            trailingIcon,
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  _DashedRectPainter({required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();
    const double dashWidth = 8.0;
    const double dashSpace = 4.0;

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
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
  }
}
