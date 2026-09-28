import 'package:flutter/material.dart';
import 'package:truejobs/cv_sections/cv_education_screen.dart';
import 'package:truejobs/cv_sections/cv_template_state.dart';

class CvDetailsScreen extends StatefulWidget {
  const CvDetailsScreen({super.key});

  @override
  State<CvDetailsScreen> createState() => _CvDetailsScreenState();
}

class _CvDetailsScreenState extends State<CvDetailsScreen> {
  Widget _buildTextField(String label, String hint, {bool isRequired = false, double? width}) {
    return SizedBox(
      width: width ?? double.infinity,
      child: Column(
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
      ),
    );
  }

  Widget _buildSocialChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4A72D6)), // Blue border
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4A72D6), // Blue text
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.add, color: Color(0xFF4A72D6), size: 16),
        ],
      ),
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
                      "What's the best way for employers to contact you?",
                      style: TextStyle(
                        fontSize: sw * 0.065,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: sw * 0.04),
                    Text(
                      "We suggest including an email and phone number.",
                      style: TextStyle(
                        fontSize: sw * 0.035,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: sw * 0.01),
                    Text(
                      "*indicates a required field",
                      style: TextStyle(
                        fontSize: sw * 0.032,
                        color: const Color(0xFF4A72D6), // Blue color
                      ),
                    ),
                    SizedBox(height: sw * 0.06),

                    // Upload Photo
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(sw * 0.04),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(sw * 0.03),
                            ),
                            child: Column(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(Icons.camera_alt, size: sw * 0.08, color: Colors.black87),
                                    Positioned(
                                      right: -sw * 0.02,
                                      top: -sw * 0.01,
                                      child: Icon(Icons.add, size: sw * 0.04, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                SizedBox(height: sw * 0.02),
                                Text(
                                  "( Optional )",
                                  style: TextStyle(
                                    fontSize: sw * 0.03,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: sw * 0.02),
                          Text(
                            "Upload Photo",
                            style: TextStyle(
                              fontSize: sw * 0.035,
                              color: const Color(0xFF4A72D6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sw * 0.08),

                    // Form Fields
                    _buildTextField('First name', 'Eg : Akhil'),
                    SizedBox(height: sw * 0.05),
                    _buildTextField('Sur name', 'Eg : Mohan'),
                    SizedBox(height: sw * 0.05),
                    _buildTextField('Profession', 'Ui Ux Designer'),
                    SizedBox(height: sw * 0.05),
                    _buildTextField('City', 'Coimbatore'),
                    SizedBox(height: sw * 0.05),

                    Row(
                      children: [
                        Expanded(child: _buildTextField('Country', 'India')),
                        SizedBox(width: sw * 0.04),
                        Expanded(child: _buildTextField('Pin Code', '685535')),
                      ],
                    ),
                    SizedBox(height: sw * 0.05),

                    _buildTextField('Phone', '+91 8590 79 4021'),
                    SizedBox(height: sw * 0.05),
                    _buildTextField('Email', 'akhilmohan04869@gmail.com', isRequired: true),
                    SizedBox(height: sw * 0.08),

                    // Additional Information Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(sw * 0.01),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.info_outline, color: Colors.orange, size: sw * 0.05),
                        ),
                        SizedBox(width: sw * 0.03),
                        Expanded(
                          child: Text(
                            "Add additional information to your\nresume (optional)",
                            style: TextStyle(
                              fontSize: sw * 0.038,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sw * 0.04),

                    // Social Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSocialChip('LinkedIn'),
                          _buildSocialChip('Behance'),
                          _buildSocialChip('Website'),
                        ],
                      ),
                    ),
                    SizedBox(height: sw * 0.1), // Extra padding at bottom
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CvEducationScreen()),
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
                          'Next: Education',
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
}
