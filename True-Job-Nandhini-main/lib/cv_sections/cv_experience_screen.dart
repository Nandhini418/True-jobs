import 'package:flutter/material.dart';
import 'cv_template_state.dart';

class ExperienceEntry {
  TextEditingController controller;
  bool fromChip;

  ExperienceEntry({required String initialText, this.fromChip = false})
      : controller = TextEditingController(text: initialText);
}

class CvExperienceScreen extends StatefulWidget {
  const CvExperienceScreen({super.key});

  @override
  State<CvExperienceScreen> createState() => _CvExperienceScreenState();
}

class _CvExperienceScreenState extends State<CvExperienceScreen> {
  final List<String> _allChips = [
    'Internship',
    'Full-time Job',
    'Part-time Job',
    'Freelance Work',
    'Contract Job',
    'Industrial Training',
    'Startup Experience',
  ];

  List<ExperienceEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    // Start with one empty entry
    _entries.add(ExperienceEntry(initialText: '', fromChip: false));
  }

  @override
  void dispose() {
    for (var entry in _entries) {
      entry.controller.dispose();
    }
    super.dispose();
  }

  void _addFromChip(String text) {
    setState(() {
      // Find the first empty entry
      int emptyIndex = _entries.indexWhere((e) => e.controller.text.trim().isEmpty);
      if (emptyIndex != -1) {
        _entries[emptyIndex].controller.text = text;
        _entries[emptyIndex].fromChip = true;
      } else {
        _entries.add(ExperienceEntry(initialText: text, fromChip: true));
      }
    });
  }

  void _addManualEntry() {
    setState(() {
      _entries.add(ExperienceEntry(initialText: '', fromChip: false));
    });
  }

  void _removeEntry(int index) {
    setState(() {
      _entries.removeAt(index);
      // Ensure there's always at least one empty entry if the list becomes empty
      if (_entries.isEmpty) {
        _entries.add(ExperienceEntry(initialText: '', fromChip: false));
      }
    });
  }

  List<String> get _availableChips {
    List<String> used = _entries.where((e) => e.fromChip).map((e) => e.controller.text).toList();
    return _allChips.where((c) => !used.contains(c)).toList();
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
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back_ios_new, size: sw * 0.05, color: Colors.black),
                    ),
                    SizedBox(height: sw * 0.08),

                    // Title
                    Text(
                      'Add your experiences',
                      style: TextStyle(
                        fontSize: sw * 0.065,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: sw * 0.02),

                    // Subtitle
                    Text(
                      'Enhance your resume to stand out from the crowd.You can also add your own.',
                      style: TextStyle(
                        fontSize: sw * 0.035,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: sw * 0.06),

                    // Available Chips
                    Wrap(
                      spacing: sw * 0.03,
                      runSpacing: sw * 0.03,
                      children: _availableChips.map((chip) {
                        return GestureDetector(
                          onTap: () => _addFromChip(chip),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.02),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(sw * 0.05),
                              border: Border.all(color: const Color(0xFF4A72D6)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  chip,
                                  style: TextStyle(
                                    color: const Color(0xFF4A72D6),
                                    fontSize: sw * 0.035,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: sw * 0.01),
                                Icon(Icons.add, color: const Color(0xFF4A72D6), size: sw * 0.04),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: sw * 0.08),

                    // Dynamic Fields
                    ..._entries.asMap().entries.map((entry) {
                      int idx = entry.key;
                      ExperienceEntry exp = entry.value;

                      return Padding(
                        padding: EdgeInsets.only(bottom: sw * 0.06),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EXPERIENCE TITLE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: sw * 0.02),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: exp.controller,
                                    readOnly: exp.fromChip, // If from chip, it acts like a badge
                                    onChanged: (val) {
                                      // If user starts typing in a chip-filled box, it becomes manual
                                      if (exp.fromChip && val != exp.controller.text) {
                                        setState(() {
                                          exp.fromChip = false;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Type your own',
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
                                      suffixIcon: exp.fromChip
                                          ? Icon(Icons.check, color: const Color(0xFF19893F))
                                          : null,
                                    ),
                                  ),
                                ),
                                SizedBox(width: sw * 0.04),
                                GestureDetector(
                                  onTap: () => _removeEntry(idx),
                                  child: Container(
                                    padding: EdgeInsets.all(sw * 0.02),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F4FB),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.delete, color: const Color(0xFF00AEEF), size: sw * 0.05),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    // Add another experiences
                    GestureDetector(
                      onTap: _addManualEntry,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: const Color(0xFF00AEEF), size: sw * 0.045),
                          SizedBox(width: sw * 0.02),
                          Text(
                            'Add another experiences',
                            style: TextStyle(
                              color: const Color(0xFF00AEEF),
                              fontSize: sw * 0.035,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sw * 0.1),
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
                          // Handle next action
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
                          'Next: Skills',
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
