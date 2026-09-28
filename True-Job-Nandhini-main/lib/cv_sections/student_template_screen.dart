import 'package:flutter/material.dart';
import 'package:truejobs/cv_sections/cv_details_screen.dart';
import 'cv_template_state.dart';
import '../models/resume_data.dart';
import 'flutter_cv_templates.dart';
class StudentTemplatesScreen extends StatefulWidget {
  const StudentTemplatesScreen({super.key});

  @override
  State<StudentTemplatesScreen> createState() => _StudentTemplatesScreenState();
}

class _StudentTemplatesScreenState extends State<StudentTemplatesScreen> {
  // Using actual Flutter widget templates
  final List<Map<String, dynamic>> _templates = [
    {'id': 'template_1', 'builder': (ResumeData data) => Template1Widget(data: data)},
    {'id': 'template_2', 'builder': (ResumeData data) => Template2Widget(data: data)},
    {'id': 'template_3', 'builder': (ResumeData data) => Template3Widget(data: data)},
  ];

  // Dummy data for rendering the templates in preview/grid
  final ResumeData _dummyData = ResumeData.dummyData(withPhoto: true);

  // Indices of templates that should have the "Recommended" badge
  final List<int> _recommendedIndices = [0, 1];

  // Store selected filters
  final Set<String> _selectedFilters = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showHelpDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Section ───────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(sw * 0.05, sw * 0.04, sw * 0.05, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios_new,
                        size: sw * 0.05, color: Colors.black),
                  ),
                  SizedBox(height: sh * 0.03),

                  // Title
                  Text(
                    'Best templates for\nstudents',
                    style: TextStyle(
                      fontSize: sw * 0.075,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: sh * 0.02),

                  // Subtitle & Filter Button Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'You can always change your\ntemplate later.',
                          style: TextStyle(
                            fontSize: sw * 0.038,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                      ),
                      // Filter Button
                      GestureDetector(
                        onTap: () => _showFilterBottomSheet(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.04,
                            vertical: sw * 0.02,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7A28CB), // Purple
                            borderRadius: BorderRadius.circular(sw * 0.05),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.filter_list,
                                  color: Colors.white, size: sw * 0.045),
                              SizedBox(width: sw * 0.02),
                              Text(
                                'Filter',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: sw * 0.035,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sh * 0.03),
                ],
              ),
            ),

            // ── Templates Grid ───────────────────────────────────────
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(
                    sw * 0.05, 0, sw * 0.05, sw * 0.05),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: sw * 0.04,
                  mainAxisSpacing: sw * 0.04,
                  childAspectRatio: 0.72, // Matches the tall CV proportion
                ),
                itemCount: _templates.length,
                itemBuilder: (context, index) {
                  final bool isRecommended = _recommendedIndices.contains(index);
                  final template = _templates[index];

                  return GestureDetector(
                    onTap: () => _showTemplatePreviewDialog(context, template),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      clipBehavior: Clip.none,
                      children: [
                        // CV Card
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(sw * 0.03),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(sw * 0.03),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                width: 595, // Standard A4 width at 72dpi
                                height: 842, // Standard A4 height at 72dpi
                                child: AbsorbPointer(
                                  child: template['builder'](_dummyData),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Recommended Badge (Overlay)
                        if (isRecommended)
                          Positioned(
                            bottom: sw * 0.04,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: sw * 0.04,
                                vertical: sw * 0.015,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF48C5C0), // Teal
                                borderRadius: BorderRadius.circular(sw * 0.04),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Recommended',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sw * 0.032,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTemplatePreviewDialog(BuildContext context, Map<String, dynamic> template) {
    final double sw = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7), // Dark overlay
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: sw * 0.05),
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Full CV Code Widget wrapped in FittedBox
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(sw * 0.03),
                  child: InteractiveViewer(
                    maxScale: 3.0,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: 595,
                        height: 842,
                        child: AbsorbPointer(
                          child: template['builder'](_dummyData),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: sw * 0.06),

              // Use template Button
              ElevatedButton(
                onPressed: () {
                  CvTemplateState.selectedTemplatePath = template['id'];
                  Navigator.pop(context); // Close preview dialog
                  // Navigate to CV creation screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CvDetailsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE6B830), // Yellow gold color
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.15, vertical: sw * 0.035),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(sw * 0.08),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Use template',
                  style: TextStyle(
                    fontSize: sw * 0.045,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Spacing between yellow button and close button
              SizedBox(height: sw * 0.08),

              // Close Circular Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: sw * 0.14,
                  height: sw * 0.14,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.black, size: sw * 0.08),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: sh * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5), // Light grey background like screenshot
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.05, vertical: sw * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: sw * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close, size: sw * 0.06),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterSection(
                              'Headshot', ['With photo', 'Without photo'], sw, setModalState),
                          SizedBox(height: sw * 0.05),
                          _buildFilterSection(
                              'Columns', ['1 Column', '2 Columns'], sw, setModalState),
                          SizedBox(height: sw * 0.05),
                          _buildFilterSection('Style',
                              ['Traditional', 'Creative', 'Contemporary'], sw, setModalState),
                          SizedBox(height: sw * 0.05),
                          _buildFilterSection(
                              'Occupation',
                              [
                                'Management & Executive',
                                'Office & Administrative Support',
                                'Business & Finance',
                                'Retail & Sales',
                                'Healthcare & Medical'
                              ],
                              sw, setModalState),

                          // Show More link
                          Padding(
                            padding: EdgeInsets.only(
                                top: sw * 0.02, bottom: sw * 0.08),
                            child: Row(
                              children: [
                                Text(
                                  'Show More',
                                  style: TextStyle(
                                    color: const Color(0xFF4CA0E9), // Light blue
                                    fontSize: sw * 0.035,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_down,
                                    color: const Color(0xFF4CA0E9), size: sw * 0.04),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Save Button Footer
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(sw * 0.05),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF19893F),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: sw * 0.038),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(sw * 0.06),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontSize: sw * 0.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection(String title, List<String> options, double sw, void Function(VoidCallback) setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: sw * 0.038,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: sw * 0.03),
        ...options.map(
              (option) {
            final bool isSelected = _selectedFilters.contains(option);
            return GestureDetector(
              onTap: () {
                setModalState(() {
                  if (isSelected) {
                    _selectedFilters.remove(option);
                  } else {
                    _selectedFilters.add(option);
                  }
                });
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: sw * 0.03),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: sw * 0.045,
                      height: sw * 0.045,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF19893F) : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: isSelected
                          ? Icon(Icons.check, color: Colors.white, size: sw * 0.035)
                          : null,
                    ),
                    SizedBox(width: sw * 0.03),
                    Text(
                      option,
                      style: TextStyle(
                        fontSize: sw * 0.036,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: sw * 0.05),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(sw * 0.04),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Half: Purple/Blue background with illustration
                Container(
                  width: double.infinity,
                  height: sw * 0.45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB9C6E4), // Match the blueish-purple from screenshot
                    borderRadius: BorderRadius.vertical(top: Radius.circular(sw * 0.04)),
                  ),
                  child: Stack(
                    children: [
                      // CV illustration
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: sw * 0.04),
                          child: Transform.rotate(
                            angle: 0.1, // Slight tilt for a dynamic look
                            child: Container(
                              height: sw * 0.35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(sw * 0.02),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: const Offset(2, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(sw * 0.02),
                                child: Image.asset('assets/CV2.png', fit: BoxFit.contain),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Close Button
                      Positioned(
                        top: sw * 0.04,
                        right: sw * 0.04,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close, size: sw * 0.07, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Half: Text and Buttons
                Padding(
                  padding: EdgeInsets.fromLTRB(sw * 0.06, sw * 0.06, sw * 0.06, sw * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need help choosing a template?',
                        style: TextStyle(
                          fontSize: sw * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: sw * 0.03),
                      Text(
                        "We'll personalize your template choices in 4 easy steps.",
                        style: TextStyle(
                          fontSize: sw * 0.042,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: sw * 0.08),

                      // Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Skip Button
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF6B2B7D), width: 1.5),
                              padding: EdgeInsets.symmetric(horizontal: sw * 0.08, vertical: sw * 0.03),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(sw * 0.06),
                              ),
                            ),
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                color: const Color(0xFF6B2B7D),
                                fontSize: sw * 0.04,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          // Let's Go Button
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (context) => const TemplateWizardDialog(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF19893F),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: sw * 0.08, vertical: sw * 0.03),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(sw * 0.06),
                              ),
                            ),
                            child: Text(
                              "Let's Go",
                              style: TextStyle(
                                fontSize: sw * 0.04,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TemplateWizardDialog extends StatefulWidget {
  const TemplateWizardDialog({super.key});

  @override
  State<TemplateWizardDialog> createState() => _TemplateWizardDialogState();
}

class _TemplateWizardDialogState extends State<TemplateWizardDialog> {
  int _currentStep = 0;

  String? _selectedPhoto;
  String? _selectedLayout;
  final Set<String> _selectedStyles = {};

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      Navigator.pop(context); // Close dialog on finish
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: sw * 0.05),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(sw * 0.04),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Bar
            Padding(
              padding: EdgeInsets.fromLTRB(sw * 0.04, sw * 0.04, sw * 0.04, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _prevStep,
                    child: Icon(Icons.arrow_back_ios_new, size: sw * 0.055, color: Colors.black),
                  ),
                  // Progress Dots
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: sw * 0.01),
                        width: sw * 0.04,
                        height: sw * 0.01,
                        decoration: BoxDecoration(
                          color: _currentStep == index ? const Color(0xFF7A28CB) : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(sw * 0.01),
                        ),
                      );
                    }),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: sw * 0.065, color: Colors.black),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(sw * 0.06),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStepContent(sw),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(double sw) {
    if (_currentStep == 0) {
      return _buildPhotoStep(sw);
    } else if (_currentStep == 1) {
      return _buildLayoutStep(sw);
    } else {
      return _buildStyleStep(sw);
    }
  }

  // ── Step 1: Photo ───────────────────────────────────────────
  Widget _buildPhotoStep(double sw) {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Will you be adding a photo to your resume?',
          style: TextStyle(fontSize: sw * 0.045, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: sw * 0.02),
        Text(
          "Add a photo if it's a standard practice in your industry or region.",
          style: TextStyle(fontSize: sw * 0.038, color: Colors.grey.shade600, height: 1.4),
        ),
        SizedBox(height: sw * 0.06),
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                sw: sw,
                title: 'With Photo',
                isSelected: _selectedPhoto == 'With Photo',
                onTap: () => setState(() => _selectedPhoto = 'With Photo'),
                child: _buildAbstractCV(sw, withPhoto: true),
              ),
            ),
            SizedBox(width: sw * 0.04),
            Expanded(
              child: _buildOptionCard(
                sw: sw,
                title: 'Without Photo',
                isSelected: _selectedPhoto == 'Without Photo',
                onTap: () => setState(() => _selectedPhoto = 'Without Photo'),
                child: _buildAbstractCV(sw, withPhoto: false),
              ),
            ),
          ],
        ),
        SizedBox(height: sw * 0.08),
        _buildFooterButtons(sw, showSkip: true),
      ],
    );
  }

  // ── Step 2: Layout ──────────────────────────────────────────
  Widget _buildLayoutStep(double sw) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What layout suits you best?',
          style: TextStyle(fontSize: sw * 0.045, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: sw * 0.02),
        Text(
          "Use one column to fit more info, or two columns for better organization",
          style: TextStyle(fontSize: sw * 0.038, color: Colors.grey.shade600, height: 1.4),
        ),
        SizedBox(height: sw * 0.06),
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                sw: sw,
                title: 'Two column',
                isSelected: _selectedLayout == 'Two column',
                onTap: () => setState(() => _selectedLayout = 'Two column'),
                child: _buildAbstractCV(sw, twoColumn: true),
              ),
            ),
            SizedBox(width: sw * 0.04),
            Expanded(
              child: _buildOptionCard(
                sw: sw,
                title: 'One column',
                isSelected: _selectedLayout == 'One column',
                onTap: () => setState(() => _selectedLayout = 'One column'),
                child: _buildAbstractCV(sw, twoColumn: false),
              ),
            ),
          ],
        ),
        SizedBox(height: sw * 0.08),
        _buildFooterButtons(sw, showSkip: true),
      ],
    );
  }

  // ── Step 3: Style ───────────────────────────────────────────
  Widget _buildStyleStep(double sw) {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What style do you prefer?',
          style: TextStyle(fontSize: sw * 0.045, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: sw * 0.02),
        Text(
          "Pick a resume style based on your industry, you can choose multiple styles too.",
          style: TextStyle(fontSize: sw * 0.038, color: Colors.grey.shade600, height: 1.4),
        ),
        SizedBox(height: sw * 0.06),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildStyleCard(
                sw: sw,
                title: 'Simple & classic',
                subtitle: 'For standard corporate roles',
                imagePath: 'assets/temp1.png',
                isSelected: _selectedStyles.contains('Simple & classic'),
                onTap: () => setState(() {
                  if (_selectedStyles.contains('Simple & classic')) {
                    _selectedStyles.remove('Simple & classic');
                  } else {
                    _selectedStyles.add('Simple & classic');
                  }
                }),
              ),
            ),
            SizedBox(width: sw * 0.04),
            Expanded(
              child: _buildStyleCard(
                sw: sw,
                title: 'Modern & Subtle',
                subtitle: 'For tech, startups,or innovative roles',
                imagePath: 'assets/temp2.png',
                isSelected: _selectedStyles.contains('Modern & Subtle'),
                onTap: () => setState(() {
                  if (_selectedStyles.contains('Modern & Subtle')) {
                    _selectedStyles.remove('Modern & Subtle');
                  } else {
                    _selectedStyles.add('Modern & Subtle');
                  }
                }),
              ),
            ),
          ],
        ),
        SizedBox(height: sw * 0.08),
        Center(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF19893F),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: sw * 0.08, vertical: sw * 0.03),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw * 0.06)),
            ),
            child: Text(
              "See Templates",
              style: TextStyle(fontSize: sw * 0.04, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helper Widgets ──────────────────────────────────────────

  Widget _buildOptionCard({
    required double sw,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(sw * 0.03),
              border: Border.all(color: isSelected ? const Color(0xFF19893F) : Colors.grey.shade200, width: isSelected ? 2 : 1),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: sw * 0.03),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: sw * 0.035, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(sw * 0.03, 0, sw * 0.03, sw * 0.03),
                  child: child, // The abstract CV shape
                ),
              ],
            ),
          ),
          // Verified Tick
          if (isSelected)
            Positioned(
              top: -sw * 0.02,
              right: -sw * 0.02,
              child: AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.verified, color: const Color(0xFF19893F), size: sw * 0.06),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStyleCard({
    required double sw,
    required String title,
    required String subtitle,
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sw * 0.03),
          border: Border.all(color: isSelected ? const Color(0xFF19893F) : Colors.grey.shade200, width: isSelected ? 2 : 1),
        ),
        padding: EdgeInsets.all(sw * 0.03),
        child: Column(
          children: [
            // Checkbox and Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: sw * 0.04,
                  height: sw * 0.04,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF19893F) : Colors.white,
                    border: Border.all(color: isSelected ? const Color(0xFF19893F) : Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: isSelected ? Icon(Icons.check, size: sw * 0.03, color: Colors.white) : null,
                ),
                SizedBox(width: sw * 0.02),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: sw * 0.035, fontWeight: FontWeight.bold, color: Colors.black, height: 1.2),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(height: sw * 0.03),
            // CV Image
            Container(
              height: sw * 0.35,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(sw * 0.02),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(sw * 0.02),
                child: Image.asset(imagePath, fit: BoxFit.cover, alignment: Alignment.topCenter),
              ),
            ),
            SizedBox(height: sw * 0.03),
            // Subtitle
            Text(
              subtitle,
              style: TextStyle(fontSize: sw * 0.03, color: Colors.grey.shade700, height: 1.3),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterButtons(double sw, {required bool showSkip}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (showSkip)
          OutlinedButton(
            onPressed: _nextStep,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF6B2B7D), width: 1.5),
              padding: EdgeInsets.symmetric(horizontal: sw * 0.08, vertical: sw * 0.025),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw * 0.06)),
            ),
            child: Text('Skip', style: TextStyle(color: const Color(0xFF6B2B7D), fontSize: sw * 0.038, fontWeight: FontWeight.w500)),
          )
        else
          const SizedBox(), // Placeholder if no skip
        ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF19893F),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: sw * 0.08, vertical: sw * 0.025),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw * 0.06)),
          ),
          child: Text('Next', style: TextStyle(fontSize: sw * 0.038, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  // Helper to draw the little abstract CV schematics for step 1 & 2
  Widget _buildAbstractCV(double sw, {bool withPhoto = false, bool twoColumn = false}) {
    return Container(
      height: sw * 0.35,
      padding: EdgeInsets.all(sw * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.02),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column (for 2 column layout)
          if (twoColumn)
            Container(
              width: sw * 0.08,
              color: const Color(0xFFC5CAE9), // Light indigo
              margin: EdgeInsets.only(right: sw * 0.02),
              child: Column(
                children: [
                  SizedBox(height: sw * 0.02),
                  Container(height: sw * 0.015, width: sw * 0.05, color: Colors.white),
                  SizedBox(height: sw * 0.01),
                  Container(height: sw * 0.01, width: sw * 0.06, color: Colors.white70),
                  SizedBox(height: sw * 0.01),
                  Container(height: sw * 0.01, width: sw * 0.06, color: Colors.white70),
                ],
              ),
            ),

          // Main content column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Photo + Text or Just Text)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (withPhoto && !twoColumn)
                      Container(
                        margin: EdgeInsets.only(right: sw * 0.02),
                        width: sw * 0.06,
                        height: sw * 0.06,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person, size: sw * 0.04, color: Colors.blue.shade700),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: sw * 0.015, width: sw * 0.15, color: const Color(0xFFC5CAE9)),
                          SizedBox(height: sw * 0.01),
                          Container(height: sw * 0.015, width: sw * 0.08, color: const Color(0xFFC5CAE9)),
                        ],
                      ),
                    ),
                    if (!twoColumn) // Right aligned details if single column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(height: sw * 0.01, width: sw * 0.08, color: const Color(0xFFC5CAE9)),
                          SizedBox(height: sw * 0.01),
                          Container(height: sw * 0.01, width: sw * 0.08, color: const Color(0xFFC5CAE9)),
                        ],
                      ),
                  ],
                ),
                SizedBox(height: sw * 0.03),
                // Body Lines
                ...List.generate(4, (i) => Padding(
                  padding: EdgeInsets.only(bottom: sw * 0.015),
                  child: Container(height: sw * 0.01, width: double.infinity, color: const Color(0xFFE8EAF6)),
                )),
                SizedBox(height: sw * 0.02),
                Container(height: sw * 0.015, width: sw * 0.08, color: const Color(0xFFC5CAE9)),
                SizedBox(height: sw * 0.01),
                ...List.generate(2, (i) => Padding(
                  padding: EdgeInsets.only(bottom: sw * 0.015),
                  child: Container(height: sw * 0.01, width: double.infinity, color: const Color(0xFFE8EAF6)),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
