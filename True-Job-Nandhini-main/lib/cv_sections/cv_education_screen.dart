import 'package:flutter/material.dart';
import 'cv_education_summary_screen.dart';
import 'cv_template_state.dart';

class CvEducationScreen extends StatefulWidget {
  final List<Map<String, String>> existingEducations;
  const CvEducationScreen({
    super.key,
    this.existingEducations = const [{
      'institute': 'SNS College of Engineering',
      'degree': 'MBA',
      'fieldOfStudy': 'Information Technology',
      'month': 'January',
      'year': '2026'
    }]
  });

  @override
  State<CvEducationScreen> createState() => _CvEducationScreenState();
}

class _CvEducationScreenState extends State<CvEducationScreen> {
  final TextEditingController _instituteController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _fieldController = TextEditingController();

  String? _selectedDegree;
  String? _selectedMonth;
  String? _selectedYear;

  Widget _buildTextField(String label, String hint, {bool isRequired = false, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? ' *' : ''),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String hint, List<String> items, {double? width, Function(String?)? onChanged}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu<String>(
          width: width ?? constraints.maxWidth,
          hintText: hint,
          textStyle: const TextStyle(fontSize: 14, color: Colors.black87),
          menuHeight: 200, // Reduced from 300 to help it open downwards
          menuStyle: MenuStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            elevation: MaterialStateProperty.all(2),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
          dropdownMenuEntries: items.map((String value) {
            return DropdownMenuEntry<String>(
              value: value,
              label: value,
              style: MenuItemButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                textStyle: const TextStyle(fontSize: 14),
                foregroundColor: Colors.black87,
              ),
            );
          }).toList(),
          onSelected: onChanged ?? (value) {},
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

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
                      "Share your education journey",
                      style: TextStyle(
                        fontSize: sw * 0.065,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: sw * 0.04),
                    Text(
                      "Include your higher education details—degree, courses, or institution.",
                      style: TextStyle(
                        fontSize: sw * 0.035,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: sw * 0.02),

                    // Required field and Tips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "*indicates a required field",
                          style: TextStyle(
                            fontSize: sw * 0.032,
                            color: const Color(0xFF4A72D6), // Blue color
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showTipsPopup(context),
                          child: Row(
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
                      ],
                    ),
                    SizedBox(height: sw * 0.08),

                    // Form Fields
                    _buildTextField('Institute / School / College', 'Institute / School / College', controller: _instituteController),
                    SizedBox(height: sw * 0.05),

                    _buildTextField('Location', 'Delhi, India', controller: _locationController),
                    SizedBox(height: sw * 0.05),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Degree',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDropdownField('Select', [
                          'Bachelor of Art',
                          'Bachelor of Science',
                          'BBA',
                          'High School Diploma',
                          'Associates of Arts',
                          'Associates of Science',
                          'Associates of Applied Science'
                        ], onChanged: (val) {
                          _selectedDegree = val;
                        }),
                      ],
                    ),
                    SizedBox(height: sw * 0.05),

                    _buildTextField('Field of Study', 'Financial Accounting', controller: _fieldController),
                    SizedBox(height: sw * 0.05),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Graduation Date',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(or expected Graduation Date )',
                              style: TextStyle(
                                fontSize: sw * 0.03,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildDropdownField('Month', [
                              'January', 'February', 'March', 'April', 'May', 'June',
                              'July', 'August', 'September', 'October', 'November', 'December'
                            ], onChanged: (val) => _selectedMonth = val)),
                            SizedBox(width: sw * 0.04),
                            Expanded(child: _buildDropdownField('Year', [
                              '2022', '2023', '2024', '2025', '2026', '2027', '2028', '2029', '2030'
                            ], onChanged: (val) => _selectedYear = val)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 200), // Extra padding at bottom to ensure dropdowns have space to open downwards
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            if (!isKeyboardOpen)
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
                          Map<String, String> newEdu = {
                            'institute': _instituteController.text.isNotEmpty ? _instituteController.text : 'Unknown Institute',
                            'degree': _selectedDegree ?? 'Unknown Degree',
                            'fieldOfStudy': _fieldController.text.isNotEmpty ? _fieldController.text : 'Unknown Field',
                            'month': _selectedMonth ?? '',
                            'year': _selectedYear ?? '',
                          };
                          List<Map<String, String>> updatedList = List.from(widget.existingEducations)..add(newEdu);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CvEducationSummaryScreen(educations: updatedList),
                            ),
                          );
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

  void _showTipsPopup(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // Dimmed background behind the dialog
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: sw * 0.05),
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end, // Align the tooltip arrow to the right
            children: [
              // Upward Tooltip Triangle
              Padding(
                padding: EdgeInsets.only(right: sw * 0.06), // Aligned roughly under the 'Tips' text
                child: ClipPath(
                  clipper: _TriangleClipper(),
                  child: Container(
                    width: sw * 0.06,
                    height: sw * 0.04,
                    color: Colors.white,
                  ),
                ),
              ),
              // Main White Box
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
                    // Header Row
                    Row(
                      children: [
                        // Blue lightbulb with white star inside
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

                    // Tip Items
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
