import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/widgets/custom_save_button.dart';
import 'package:truejobs/services/api/board_api.dart';
import 'package:truejobs/services/api/stream_api.dart';
import 'package:truejobs/services/api/diploma_api.dart';
import 'package:truejobs/services/api/iti_trade_api.dart';
import 'package:truejobs/services/api/ug_course_api.dart';
import 'package:truejobs/services/api/pg_course_api.dart';

// Helper custom dropdown widget to match design
class SheetDropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const SheetDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;
    final Color bgColor = AppColors.dynamicBg;

    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          SizedBox(height: screenWidth * 0.015),
          DropdownButtonFormField<String>(
            value: (value != null && items.contains(value)) ? value : null,
            dropdownColor: bgColor,
            style: GoogleFonts.poppins(color: textColor, fontSize: screenWidth * 0.035),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.035,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: subtitleColor,
                fontSize: screenWidth * 0.035,
              ),
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: textColor,
              size: screenWidth * 0.06,
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.035,
                    color: textColor,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// Helper custom text field widget to match design
class SheetTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int? maxLength;

  const SheetTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          SizedBox(height: screenWidth * 0.015),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLength: maxLength,
            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.035,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: subtitleColor,
                fontSize: screenWidth * 0.035,
              ),
            ),
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.038,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Base Sheet Layout Wrapper
class BaseSheetLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onSave;
  final String? errorMessage;

  const BaseSheetLayout({
    super.key,
    required this.title,
    required this.child,
    required this.onSave,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color borderColor = AppColors.dynamicBorder;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: AppColors.primary,
                    size: screenWidth * 0.06,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),

          // Scrollable Form
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: child,
            ),
          ),

          if (errorMessage != null && errorMessage!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenWidth * 0.02,
              ),
              child: Text(
                errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          Divider(height: 1, color: borderColor),

          // Bottom Actions
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0E0E0),
                      foregroundColor: textColor,
                      minimumSize: Size(double.infinity, screenHeight * 0.06),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.08),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: CustomSaveButton(
                    onPressed: onSave,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 1. 10th Details Bottom Sheet
class TenthDetailsSheet extends StatefulWidget {
  final String? title;
  final String? value;
  final Map<String, dynamic>? initialData;
  final Function(Map<String, String>) onSave;

  const TenthDetailsSheet({
    super.key,
    this.title,
    this.value,
    this.initialData,
    required this.onSave,
  });

  @override
  State<TenthDetailsSheet> createState() => _TenthDetailsSheetState();
}

class _TenthDetailsSheetState extends State<TenthDetailsSheet> {
  String? _selectedBoardName;
  String? _selectedBoardId;
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();

  List<String> _boards = ['CBSE', 'State Board', 'ICSE'];
  Map<String, String> _boardMap = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _selectedBoardId = widget.initialData!['board']?.toString();
      _selectedBoardName = widget.initialData!['board_name']?.toString() ?? widget.initialData!['board']?.toString();
      _schoolController.text = widget.initialData!['school']?.toString() ?? '';
      _yearController.text = widget.initialData!['year']?.toString() ?? '';
      _percentageController.text = widget.initialData!['percentage']?.toString() ?? '';
    }
    _loadBoards();
  }

  Future<void> _loadBoards() async {
    if (!mounted) return;
    try {
      final res = await BoardApi.fetchBoards();
      if (res['error'] == false || res['status'] == 'success') {
        final List<dynamic>? list = res['data'];
        if (list != null && list.isNotEmpty) {
          final List<String> fetched = [];
          final Map<String, String> bMap = {};
          for (var item in list) {
            if (item is Map) {
              final String name = item['name']?.toString() ?? '';
              final String val = item['value']?.toString() ?? item['id']?.toString() ?? '';
              if (name.isNotEmpty) {
                fetched.add(name);
                bMap[name] = val;
              }
            }
          }
          if (fetched.isNotEmpty && mounted) {
            setState(() {
              _boards = fetched;
              _boardMap = bMap;

              if (_selectedBoardId != null && _selectedBoardId!.isNotEmpty) {
                final match = _boardMap.entries.firstWhere(
                  (e) => e.value == _selectedBoardId,
                  orElse: () => const MapEntry('', ''),
                );
                if (match.key.isNotEmpty) {
                  _selectedBoardName = match.key;
                }
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching boards: $e');
    }
  }

  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return BaseSheetLayout(
      title: widget.title ?? '10th Details',
      errorMessage: _errorMessage,
      onSave: () {
        if (_selectedBoardName == null || _selectedBoardName!.isEmpty) {
          setState(() => _errorMessage = 'Board is required');
          return;
        }
        if (_schoolController.text.trim().isEmpty) {
          setState(() => _errorMessage = 'School name is required');
          return;
        }
        final String yearStr = _yearController.text.trim();
        if (yearStr.isEmpty) {
          setState(() => _errorMessage = 'Year of completion is required');
          return;
        }
        final int? year = int.tryParse(yearStr);
        if (year == null || yearStr.length != 4 || year >= 2028) {
          setState(() => _errorMessage = 'Year must be a 4-digit number less than 2028');
          return;
        }
        final String percentStr = _percentageController.text.trim().replaceAll('%', '');
        if (percentStr.isEmpty) {
          setState(() => _errorMessage = 'Percentage is required');
          return;
        }
        final double? percent = double.tryParse(percentStr);
        if (percent == null || percent > 100 || percent < 0) {
          setState(() => _errorMessage = 'Percentage must be a number less than or equal to 100');
          return;
        }

        widget.onSave({
          'board': _boardMap[_selectedBoardName] ?? _selectedBoardName ?? '',
          'board_name': _selectedBoardName ?? '',
          'school': _schoolController.text.trim(),
          'year': _yearController.text.trim(),
          'percentage': _percentageController.text.trim(),
        });
        Navigator.pop(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetDropdownField(
            label: 'Board',
            hint: 'Select Board',
            value: _selectedBoardName,
            items: _boards,
            onChanged: (val) => setState(() => _selectedBoardName = val),
          ),
          SheetTextField(
            label: 'School Name / Institute',
            hint: 'Eg : School Name',
            controller: _schoolController,
          ),
          SheetTextField(
            label: 'Year of Completion',
            hint: 'Eg : 2019',
            controller: _yearController,
            keyboardType: TextInputType.number,
            maxLength: 4,
          ),
          SheetTextField(
            label: 'Percentage / CGPA',
            hint: 'Eg : 85%',
            controller: _percentageController,
            keyboardType: TextInputType.number,
            maxLength: 3,
          ),
        ],
      ),
    );
  }
}

// 2. 11th & 12th Details Bottom Sheet
class TwelfthDetailsSheet extends StatefulWidget {
  final String? title;
  final String? value;
  final Map<String, dynamic>? initialData;
  final Function(Map<String, String>) onSave;

  const TwelfthDetailsSheet({
    super.key,
    this.title,
    this.value,
    this.initialData,
    required this.onSave,
  });

  @override
  State<TwelfthDetailsSheet> createState() => _TwelfthDetailsSheetState();
}

class _TwelfthDetailsSheetState extends State<TwelfthDetailsSheet> {
  String? _selectedBoardName;
  String? _selectedBoardId;
  String? _selectedStreamName;
  String? _selectedStreamId;
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();

  List<String> _boards = ['CBSE', 'State Board', 'ICSE'];
  Map<String, String> _boardMap = {};

  List<String> _streams = ['Science', 'Commerce', 'Arts'];
  Map<String, String> _streamMap = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _selectedBoardId = widget.initialData!['board']?.toString();
      _selectedBoardName = widget.initialData!['board_name']?.toString() ?? widget.initialData!['board']?.toString();
      _selectedStreamId = widget.initialData!['stream']?.toString();
      _selectedStreamName = widget.initialData!['stream_name']?.toString() ?? widget.initialData!['stream']?.toString();
      _schoolController.text = widget.initialData!['school']?.toString() ?? '';
      _yearController.text = widget.initialData!['year']?.toString() ?? '';
      _percentageController.text = widget.initialData!['percentage']?.toString() ?? '';
    }
    _loadBoards();
    _loadStreams();
  }

  Future<void> _loadBoards() async {
    if (!mounted) return;
    try {
      final res = await BoardApi.fetchBoards();
      if (res['error'] == false || res['status'] == 'success') {
        final List<dynamic>? list = res['data'];
        if (list != null && list.isNotEmpty) {
          final List<String> fetched = [];
          final Map<String, String> bMap = {};
          for (var item in list) {
            if (item is Map) {
              final String name = item['name']?.toString() ?? '';
              final String val = item['value']?.toString() ?? item['id']?.toString() ?? '';
              if (name.isNotEmpty) {
                fetched.add(name);
                bMap[name] = val;
              }
            }
          }
          if (fetched.isNotEmpty && mounted) {
            setState(() {
              _boards = fetched;
              _boardMap = bMap;

              if (_selectedBoardId != null && _selectedBoardId!.isNotEmpty) {
                final match = _boardMap.entries.firstWhere(
                  (e) => e.value == _selectedBoardId,
                  orElse: () => const MapEntry('', ''),
                );
                if (match.key.isNotEmpty) {
                  _selectedBoardName = match.key;
                }
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching boards: $e');
    }
  }

  Future<void> _loadStreams() async {
    if (!mounted) return;
    try {
      final res = await StreamApi.fetchStreams();
      if (res['error'] == false || res['status'] == 'success') {
        final List<dynamic>? list = res['data'];
        if (list != null && list.isNotEmpty) {
          final List<String> fetched = [];
          final Map<String, String> sMap = {};
          for (var item in list) {
            if (item is Map) {
              final String name = item['name']?.toString() ?? '';
              final String val = item['value']?.toString() ?? item['id']?.toString() ?? '';
              if (name.isNotEmpty) {
                fetched.add(name);
                sMap[name] = val;
              }
            }
          }
          if (fetched.isNotEmpty && mounted) {
            setState(() {
              _streams = fetched;
              _streamMap = sMap;

              if (_selectedStreamId != null && _selectedStreamId!.isNotEmpty) {
                final match = _streamMap.entries.firstWhere(
                  (e) => e.value == _selectedStreamId,
                  orElse: () => const MapEntry('', ''),
                );
                if (match.key.isNotEmpty) {
                  _selectedStreamName = match.key;
                }
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching streams: $e');
    }
  }

  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return BaseSheetLayout(
      title: widget.title ?? '11th & 12th Details',
      errorMessage: _errorMessage,
      onSave: () {
        if (_selectedBoardName == null || _selectedBoardName!.isEmpty) {
          setState(() => _errorMessage = 'Board is required');
          return;
        }
        if (_selectedStreamName == null || _selectedStreamName!.isEmpty) {
          setState(() => _errorMessage = 'Stream is required');
          return;
        }
        if (_schoolController.text.trim().isEmpty) {
          setState(() => _errorMessage = 'School / Junior college name is required');
          return;
        }
        final String yearStr = _yearController.text.trim();
        if (yearStr.isEmpty) {
          setState(() => _errorMessage = 'Year of completion is required');
          return;
        }
        final int? year = int.tryParse(yearStr);
        if (year == null || yearStr.length != 4 || year >= 2028) {
          setState(() => _errorMessage = 'Year must be a 4-digit number less than 2028');
          return;
        }
        final String percentStr = _percentageController.text.trim().replaceAll('%', '');
        if (percentStr.isEmpty) {
          setState(() => _errorMessage = 'Percentage is required');
          return;
        }
        final double? percent = double.tryParse(percentStr);
        if (percent == null || percent > 100 || percent < 0) {
          setState(() => _errorMessage = 'Percentage must be a number less than or equal to 100');
          return;
        }

        widget.onSave({
          'board': _boardMap[_selectedBoardName] ?? _selectedBoardName ?? '',
          'board_name': _selectedBoardName ?? '',
          'stream': _streamMap[_selectedStreamName] ?? _selectedStreamName ?? '',
          'stream_name': _selectedStreamName ?? '',
          'school': _schoolController.text.trim(),
          'year': _yearController.text.trim(),
          'percentage': _percentageController.text.trim(),
        });
        Navigator.pop(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetDropdownField(
            label: 'Board',
            hint: 'Select Board',
            value: _selectedBoardName,
            items: _boards,
            onChanged: (val) => setState(() => _selectedBoardName = val),
          ),
          SheetDropdownField(
            label: 'Stream',
            hint: 'Select Stream',
            value: _selectedStreamName,
            items: _streams,
            onChanged: (val) => setState(() => _selectedStreamName = val),
          ),
          SheetTextField(
            label: 'School / Junior College Name',
            hint: 'Eg : School Name',
            controller: _schoolController,
          ),
          SheetTextField(
            label: 'Year of Completion',
            hint: 'Eg : 2019',
            controller: _yearController,
            keyboardType: TextInputType.number,
            maxLength: 4,
          ),
          SheetTextField(
            label: 'Percentage / CGPA',
            hint: 'Eg : 85%',
            controller: _percentageController,
            keyboardType: TextInputType.number,
            maxLength: 3,
          ),
        ],
      ),
    );
  }
}

// 3. Diploma Details Bottom Sheet
class DiplomaDetailsSheet extends StatefulWidget {
  final String? title;
  final String? value;
  final Map<String, dynamic>? initialData;
  final Function(Map<String, String>) onSave;

  const DiplomaDetailsSheet({
    super.key,
    this.title,
    this.value,
    this.initialData,
    required this.onSave,
  });

  @override
  State<DiplomaDetailsSheet> createState() => _DiplomaDetailsSheetState();
}

class _DiplomaDetailsSheetState extends State<DiplomaDetailsSheet> {
  String? _selectedDiplomaName;
  String? _selectedDiplomaId;
  final TextEditingController _instituteController = TextEditingController();
  final TextEditingController _boardController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();

  List<String> _diplomas = [
    'Mechanical',
    'Electrical',
    'Civil',
    'Computer Science',
  ];
  Map<String, String> _diplomaMap = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _selectedDiplomaId = widget.initialData!['diploma']?.toString();
      _selectedDiplomaName = widget.initialData!['diploma_name']?.toString() ?? widget.initialData!['diploma']?.toString();
      _instituteController.text = widget.initialData!['institute']?.toString() ?? '';
      _boardController.text = widget.initialData!['board']?.toString() ?? '';
      _durationController.text = widget.initialData!['duration']?.toString() ?? '';
      _yearController.text = widget.initialData!['year']?.toString() ?? '';
      _percentageController.text = widget.initialData!['percentage']?.toString() ?? '';
    }
    _loadDiplomas();
  }

  Future<void> _loadDiplomas() async {
    if (!mounted) return;
    try {
      final res = await DiplomaApi.fetchCourses();
      if (res['error'] == false || res['status'] == 'success') {
        final List<dynamic>? list = res['data'];
        if (list != null && list.isNotEmpty) {
          final List<String> fetched = [];
          final Map<String, String> dMap = {};
          for (var item in list) {
            if (item is Map) {
              final String name = item['name']?.toString() ?? '';
              final String val = item['value']?.toString() ?? item['id']?.toString() ?? '';
              if (name.isNotEmpty) {
                fetched.add(name);
                dMap[name] = val;
              }
            }
          }
          if (fetched.isNotEmpty && mounted) {
            setState(() {
              _diplomas = fetched;
              _diplomaMap = dMap;

              if (_selectedDiplomaId != null && _selectedDiplomaId!.isNotEmpty) {
                final match = _diplomaMap.entries.firstWhere(
                  (e) => e.value == _selectedDiplomaId,
                  orElse: () => const MapEntry('', ''),
                );
                if (match.key.isNotEmpty) {
                  _selectedDiplomaName = match.key;
                }
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching diplomas: $e');
    }
  }

  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return BaseSheetLayout(
      title: widget.title ?? 'Diploma',
      errorMessage: _errorMessage,
      onSave: () {
        if (_selectedDiplomaName == null || _selectedDiplomaName!.isEmpty) {
          setState(() => _errorMessage = 'Diploma is required');
          return;
        }
        if (_instituteController.text.trim().isEmpty) {
          setState(() => _errorMessage = 'Institute is required');
          return;
        }
        if (_boardController.text.trim().isEmpty) {
          setState(() => _errorMessage = 'Board / University is required');
          return;
        }
        if (_durationController.text.trim().isEmpty) {
          setState(() => _errorMessage = 'Duration is required');
          return;
        }
        final String yearStr = _yearController.text.trim();
        if (yearStr.isEmpty) {
          setState(() => _errorMessage = 'Year of completion is required');
          return;
        }
        final int? year = int.tryParse(yearStr);
        if (year == null || yearStr.length != 4 || year >= 2028) {
          setState(() => _errorMessage = 'Year must be a 4-digit number less than 2028');
          return;
        }
        final String percentStr = _percentageController.text.trim().replaceAll('%', '');
        if (percentStr.isEmpty) {
          setState(() => _errorMessage = 'Percentage is required');
          return;
        }
        final double? percent = double.tryParse(percentStr);
        if (percent == null || percent > 100 || percent < 0) {
          setState(() => _errorMessage = 'Percentage must be a number less than or equal to 100');
          return;
        }

        widget.onSave({
          'diploma': _diplomaMap[_selectedDiplomaName] ?? _selectedDiplomaName ?? '',
          'diploma_name': _selectedDiplomaName ?? '',
          'institute': _instituteController.text.trim(),
          'board': _boardController.text.trim(),
          'duration': _durationController.text.trim(),
          'year': _yearController.text.trim(),
          'percentage': _percentageController.text.trim(),
        });
        Navigator.pop(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetDropdownField(
            label: 'Diploma',
            hint: 'Select Diploma',
            value: _selectedDiplomaName,
            items: _diplomas,
            onChanged: (val) => setState(() => _selectedDiplomaName = val),
          ),
          SheetTextField(
            label: 'Institute',
            hint: 'Eg : College / University',
            controller: _instituteController,
          ),
          SheetTextField(
            label: 'Board',
            hint: 'Eg : State Board / University',
            controller: _boardController,
          ),
          SheetTextField(
            label: 'Duration',
            hint: 'Eg : 3 Years',
            controller: _durationController,
          ),
          SheetTextField(
            label: 'Year of Completion',
            hint: 'Eg : 2019',
            controller: _yearController,
            keyboardType: TextInputType.number,
            maxLength: 4,
          ),
          SheetTextField(
            label: 'Percentage',
            hint: 'Eg : 85%',
            controller: _percentageController,
            keyboardType: TextInputType.number,
            maxLength: 3,
          ),
        ],
      ),
    );
  }
}

// 4. ITI Details Bottom Sheet
class ItiDetailsSheet extends StatefulWidget {
  final String? title;
  final String? value;
  final Map<String, dynamic>? initialData;
  final Function(Map<String, String>) onSave;

  const ItiDetailsSheet({
    super.key,
    this.title,
    this.value,
    this.initialData,
    required this.onSave,
  });

  @override
  State<ItiDetailsSheet> createState() => _ItiDetailsSheetState();
}

class _ItiDetailsSheetState extends State<ItiDetailsSheet> {
  String? _selectedTradeName;
  String? _selectedTradeId;
  String _selectedBoardType = 'NCVT'; // Default NCVT
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _instituteController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();

  List<String> _trades = [
    'Electrician',
    'Fitter',
    'Welder',
    'Mechanic',
  ];
  Map<String, String> _tradeMap = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _selectedTradeId = widget.initialData!['trade']?.toString();
      _selectedTradeName = widget.initialData!['trade_name']?.toString() ?? widget.initialData!['trade']?.toString();
      _specializationController.text = widget.initialData!['specialization']?.toString() ?? '';
      _instituteController.text = widget.initialData!['institute']?.toString() ?? '';
      _selectedBoardType = widget.initialData!['boardType']?.toString() ?? 'NCVT';
      _durationController.text = widget.initialData!['duration']?.toString() ?? '';
      _yearController.text = widget.initialData!['year']?.toString() ?? '';
      _percentageController.text = widget.initialData!['percentage']?.toString() ?? '';
    }
    _loadTrades();
  }

  Future<void> _loadTrades() async {
    if (!mounted) return;
    try {
      final res = await ItiTradeApi.fetchTrades();
      if (res['error'] == false || res['status'] == 'success') {
        final List<dynamic>? list = res['data'];
        if (list != null && list.isNotEmpty) {
          final List<String> fetched = [];
          final Map<String, String> tMap = {};
          for (var item in list) {
            if (item is Map) {
              final String name = item['name']?.toString() ?? '';
              final String val = item['value']?.toString() ?? item['id']?.toString() ?? '';
              if (name.isNotEmpty) {
                fetched.add(name);
                tMap[name] = val;
              }
            }
          }
          if (fetched.isNotEmpty && mounted) {
            setState(() {
              _trades = fetched;
              _tradeMap = tMap;

              if (_selectedTradeId != null && _selectedTradeId!.isNotEmpty) {
                final match = _tradeMap.entries.firstWhere(
                  (e) => e.value == _selectedTradeId,
                  orElse: () => const MapEntry('', ''),
                );
                if (match.key.isNotEmpty) {
                  _selectedTradeName = match.key;
                }
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching ITI trades: $e');
    }
  }


  Widget _buildBoardSelectorButton(String type, double screenWidth) {
    final bool isSelected = _selectedBoardType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedBoardType = type;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFE0E0E0),
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppColors.primary.withAlpha(26),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ]
                : null,
          ),
          child: Center(
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: screenWidth * 0.038,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return BaseSheetLayout(
      title: widget.title ?? 'ITI Details',
      errorMessage: _errorMessage,
      onSave: () {
        if (_selectedTradeName == null || _selectedTradeName!.isEmpty) {
          setState(() => _errorMessage = 'Trade is required');
          return;
        }
        if (_specializationController.text.trim().isEmpty) {
          setState(() => _errorMessage = 'Specialization is required');
          return;
        }
        if (_instituteController.text.trim().isEmpty) {
          setState(() => _errorMessage = 'Institute is required');
          return;
        }
        if (_durationController.text.trim().isEmpty) {
          setState(() => _errorMessage = 'Duration is required');
          return;
        }
        final String yearStr = _yearController.text.trim();
        if (yearStr.isEmpty) {
          setState(() => _errorMessage = 'Year of completion is required');
          return;
        }
        final int? year = int.tryParse(yearStr);
        if (year == null || yearStr.length != 4 || year >= 2028) {
          setState(() => _errorMessage = 'Year must be a 4-digit number less than 2028');
          return;
        }
        final String percentStr = _percentageController.text.trim().replaceAll('%', '');
        if (percentStr.isEmpty) {
          setState(() => _errorMessage = 'Percentage is required');
          return;
        }
        final double? percent = double.tryParse(percentStr);
        if (percent == null || percent > 100 || percent < 0) {
          setState(() => _errorMessage = 'Percentage must be a number less than or equal to 100');
          return;
        }

        widget.onSave({
          'trade': _tradeMap[_selectedTradeName] ?? _selectedTradeName ?? '',
          'trade_name': _selectedTradeName ?? '',
          'specialization': _specializationController.text.trim(),
          'institute': _instituteController.text.trim(),
          'boardType': _selectedBoardType,
          'duration': _durationController.text.trim(),
          'year': _yearController.text.trim(),
          'percentage': _percentageController.text.trim(),
        });
        Navigator.pop(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetDropdownField(
            label: 'Trade',
            hint: 'Select ITI',
            value: _selectedTradeName,
            items: _trades,
            onChanged: (val) => setState(() => _selectedTradeName = val),
          ),
          SheetTextField(
            label: 'Specialization',
            hint: 'Enter specialization',
            controller: _specializationController,
          ),
          SheetTextField(
            label: 'Institute',
            hint: 'Eg : College / University',
            controller: _instituteController,
          ),

          // Board: NCVT & SCVT selector buttons
          Padding(
            padding: EdgeInsets.only(bottom: screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Board',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenWidth * 0.015),
                Row(
                  children: [
                    _buildBoardSelectorButton('NCVT', screenWidth),
                    SizedBox(width: screenWidth * 0.04),
                    _buildBoardSelectorButton('SCVT', screenWidth),
                  ],
                ),
              ],
            ),
          ),

          SheetTextField(
            label: 'Duration',
            hint: 'Eg : 2 Years',
            controller: _durationController,
          ),
          SheetTextField(
            label: 'Year of Completion',
            hint: 'Eg : 2019',
            controller: _yearController,
            keyboardType: TextInputType.number,
            maxLength: 4,
          ),
          SheetTextField(
            label: 'Percentage',
            hint: 'Eg : 85%',
            controller: _percentageController,
            keyboardType: TextInputType.number,
            maxLength: 3,
          ),
        ],
      ),
    );
  }
}

// 5. UG & PG Details Bottom Sheet
class UgPgDetailsSheet extends StatefulWidget {
  final String? title; // "UG Details" or "PG Details"
  final String? value;
  final Map<String, dynamic>? initialData;
  final Function(Map<String, String>) onSave;

  const UgPgDetailsSheet({
    super.key,
    this.title,
    this.value,
    this.initialData,
    required this.onSave,
  });

  @override
  State<UgPgDetailsSheet> createState() => _UgPgDetailsSheetState();
}

class _UgPgDetailsSheetState extends State<UgPgDetailsSheet> {
  String? _selectedCourseName;
  String? _selectedCourseId;
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _instituteController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();
  List<String> _courses = [
    'B.Sc',
    'B.Com',
    'BCA',
    'BBA',
    'M.Sc',
    'MCA',
    'MBA',
  ];
  Map<String, String> _courseMap = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _selectedCourseId = widget.initialData!['course']?.toString();
      _selectedCourseName = widget.initialData!['course_name']?.toString() ?? widget.initialData!['course']?.toString();
      _specializationController.text = widget.initialData!['specialization']?.toString() ?? '';
      _instituteController.text = widget.initialData!['institute']?.toString() ?? '';
      _universityController.text = widget.initialData!['university']?.toString() ?? '';
      _durationController.text = widget.initialData!['duration']?.toString() ?? '';
      _yearController.text = widget.initialData!['year']?.toString() ?? '';
      _percentageController.text = widget.initialData!['percentage']?.toString() ?? '';
    }
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    if (!mounted) return;
    try {
      final bool isUg = widget.value == '3';
      final res = isUg ? await UgCourseApi.fetchCourses() : await PgCourseApi.fetchCourses();
      if (res['error'] == false || res['status'] == 'success') {
        final List<dynamic>? list = res['data'];
        if (list != null && list.isNotEmpty) {
          final List<String> fetched = [];
          final Map<String, String> cMap = {};
          for (var item in list) {
            if (item is Map) {
              final String name = item['name']?.toString() ?? '';
              final String val = item['value']?.toString() ?? item['id']?.toString() ?? '';
              if (name.isNotEmpty) {
                fetched.add(name);
                cMap[name] = val;
              }
            }
          }
          if (fetched.isNotEmpty && mounted) {
            setState(() {
              _courses = fetched;
              _courseMap = cMap;

              if (_selectedCourseId != null && _selectedCourseId!.isNotEmpty) {
                final match = _courseMap.entries.firstWhere(
                  (e) => e.value == _selectedCourseId,
                  orElse: () => const MapEntry('', ''),
                );
                if (match.key.isNotEmpty) {
                  _selectedCourseName = match.key;
                }
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching courses: $e');
    }
  }

  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return BaseSheetLayout(
      title: widget.title ?? 'UG / PG Details',
      errorMessage: _errorMessage,
      onSave: () {
        if (_selectedCourseName == null || _selectedCourseName!.isEmpty) {
          setState(() => _errorMessage = 'Course is required');
          return;
        }
        if (_specializationController.text.trim().isEmpty) {
          setState(() => _errorMessage = 'Specialization is required');
          return;
        }
        if (_instituteController.text.trim().isEmpty) {
          setState(() => _errorMessage = 'Institute is required');
          return;
        }
        if (_universityController.text.trim().isEmpty) {
          setState(() => _errorMessage = 'University is required');
          return;
        }
        if (_durationController.text.trim().isEmpty) {
          setState(() => _errorMessage = 'Duration is required');
          return;
        }
        final String yearStr = _yearController.text.trim();
        if (yearStr.isEmpty) {
          setState(() => _errorMessage = 'Year of completion is required');
          return;
        }
        final int? year = int.tryParse(yearStr);
        if (year == null || yearStr.length != 4 || year >= 2028) {
          setState(() => _errorMessage = 'Year must be a 4-digit number less than 2028');
          return;
        }
        final String percentStr = _percentageController.text.trim().replaceAll('%', '');
        if (percentStr.isEmpty) {
          setState(() => _errorMessage = 'Percentage is required');
          return;
        }
        final double? percent = double.tryParse(percentStr);
        if (percent == null || percent > 100 || percent < 0) {
          setState(() => _errorMessage = 'Percentage must be a number less than or equal to 100');
          return;
        }

        widget.onSave({
          'course': _courseMap[_selectedCourseName] ?? _selectedCourseName ?? '',
          'course_name': _selectedCourseName ?? '',
          'specialization': _specializationController.text.trim(),
          'institute': _instituteController.text.trim(),
          'university': _universityController.text.trim(),
          'duration': _durationController.text.trim(),
          'year': _yearController.text.trim(),
          'percentage': _percentageController.text.trim(),
        });
        Navigator.pop(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetDropdownField(
            label: 'Course',
            hint: 'Select Course',
            value: _selectedCourseName,
            items: _courses,
            onChanged: (val) => setState(() => _selectedCourseName = val),
          ),
          SheetTextField(
            label: 'Specialization',
            hint: 'Enter specialization',
            controller: _specializationController,
          ),
          SheetTextField(
            label: 'Institute / College',
            hint: 'Eg : College / University',
            controller: _instituteController,
          ),
          SheetTextField(
            label: 'University / Board',
            hint: 'Eg : University Name',
            controller: _universityController,
          ),
          SheetTextField(
            label: 'Duration',
            hint: 'Eg : 3-4 Years',
            controller: _durationController,
          ),
          SheetTextField(
            label: 'Year of Completion',
            hint: 'Eg : 2019',
            controller: _yearController,
            keyboardType: TextInputType.number,
            maxLength: 4,
          ),
          SheetTextField(
            label: 'Percentage / CGPA',
            hint: 'Eg : 85%',
            controller: _percentageController,
            keyboardType: TextInputType.number,
            maxLength: 3,
          ),
        ],
      ),
    );
  }
}
