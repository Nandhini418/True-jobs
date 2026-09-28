import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Model to hold one saved internship entry
class InternshipEntry {
  final String? id;
  final String companyName;
  final String startDate;
  final String endDate;
  final String projectName;
  final String description;
  final String keySkills;
  final String projectUrl;

  InternshipEntry({
    this.id,
    required this.companyName,
    required this.startDate,
    required this.endDate,
    required this.projectName,
    required this.description,
    required this.keySkills,
    required this.projectUrl,
  });
}

class AddInternshipScreen extends StatefulWidget {
  final InternshipEntry? existingEntry; // non-null when editing

  const AddInternshipScreen({super.key, this.existingEntry});

  @override
  State<AddInternshipScreen> createState() => _AddInternshipScreenState();
}

class _AddInternshipScreenState extends State<AddInternshipScreen> {
  final _companyName = TextEditingController();
  final _startDate = TextEditingController();
  final _endDate = TextEditingController();
  final _projectName = TextEditingController();
  final _description = TextEditingController();
  final _keySkills = TextEditingController();
  final _projectUrl = TextEditingController();

  static const int _descriptionMaxLength = 1000;

  String _formatToDisplay(String dateStr) {
    if (dateStr.isEmpty) return '';
    if (dateStr.contains('/')) return dateStr;
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      final year = parts[0];
      final month = parts[1];
      final day = parts[2];
      return '$day/$month/$year';
    }
    return dateStr;
  }

  String _formatToApi(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split('/');
    if (parts.length == 3) {
      final day = parts[0];
      final month = parts[1];
      final year = parts[2];
      return '$year-$month-$day';
    }
    return dateStr;
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      final e = widget.existingEntry!;
      debugPrint('AddInternshipScreen: Initiating Edit Mode. Existing Internship ID = ${e.id}');
      _companyName.text = e.companyName;
      _startDate.text = _formatToDisplay(e.startDate);
      _endDate.text = _formatToDisplay(e.endDate);
      _projectName.text = e.projectName;
      _description.text = e.description;
      _keySkills.text = e.keySkills;
      _projectUrl.text = e.projectUrl;
    }
    _description.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _companyName.dispose();
    _startDate.dispose();
    _endDate.dispose();
    _projectName.dispose();
    _description.dispose();
    _keySkills.dispose();
    _projectUrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _companyName.text.trim().isNotEmpty &&
          _description.text.trim().isNotEmpty;

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        controller.text =
        '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Internship'),
        content: const Text(
          'Are you sure you want to delete this internship details?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Navigator.pop(context, 'delete');
    }
  }

  Future<void> _onSave() async {
    if (!_canSave) return;
    final entry = InternshipEntry(
      id: widget.existingEntry?.id != null && widget.existingEntry!.id!.isNotEmpty
          ? widget.existingEntry!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      companyName: _companyName.text.trim(),
      startDate: _formatToApi(_startDate.text.trim()),
      endDate: _formatToApi(_endDate.text.trim()),
      projectName: _projectName.text.trim(),
      description: _description.text.trim(),
      keySkills: _keySkills.text.trim(),
      projectUrl: _projectUrl.text.trim(),
    );

    if (mounted) {
      Navigator.pop(context, entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double sw = size.width;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color cardBg = AppColors.dynamicCardBg;
    final Color borderColor = AppColors.dynamicBorder;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: sw * 0.15,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
            size: sw * 0.045,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Internship',
          style: TextStyle(
            color: textColor,
            fontSize: sw * 0.05,
            fontWeight: FontWeight.w600,
          ),
        ),
        titleSpacing: 0,
        actions: [
          if (widget.existingEntry != null)
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
              onPressed: _confirmDelete,
              tooltip: 'Delete Internship',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.05,
            vertical: sw * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Show your professional learnings',
                style: TextStyle(
                  fontSize: sw * 0.038,
                  color: AppColors.primary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: sw * 0.08),

              _buildTextField(sw, _companyName, 'Company name', textColor, subtitleColor, borderColor),
              SizedBox(height: sw * 0.06),

              _buildLabel(sw, 'Internship duration', subtitleColor),
              SizedBox(height: sw * 0.03),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                        sw, _startDate, 'Start date', textColor, subtitleColor, borderColor),
                  ),
                  SizedBox(width: sw * 0.06),
                  Expanded(
                    child: _buildDateField(sw, _endDate, 'End date', textColor, subtitleColor, borderColor),
                  ),
                ],
              ),
              SizedBox(height: sw * 0.06),

              _buildTextField(sw, _projectName, 'Project name', textColor, subtitleColor, borderColor),
              SizedBox(height: sw * 0.06),

              _buildTextField(
                sw,
                _description,
                'Describe what you did at internship',
                textColor,
                subtitleColor,
                borderColor,
                maxLines: 4,
                maxLength: _descriptionMaxLength,
              ),
              SizedBox(height: sw * 0.06),

              _buildTextField(
                sw,
                _keySkills,
                'Key skills (optional)',
                textColor,
                subtitleColor,
                borderColor,
              ),
              SizedBox(height: sw * 0.06),

              _buildTextField(
                sw,
                _projectUrl,
                'Project URL (optional)',
                textColor,
                subtitleColor,
                borderColor,
                inputType: TextInputType.url,
              ),
              SizedBox(height: sw * 0.08),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.05,
            vertical: sw * 0.04,
          ),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(top: BorderSide(color: borderColor, width: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: sw * 0.04),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw * 0.08),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: sw * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.04),
              Expanded(
                child: ElevatedButton(
                  onPressed: _canSave ? _onSave : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: sw * 0.04),
                    backgroundColor: _canSave
                        ? AppColors.primary
                        : const Color(0xFFE0E0E0),
                    foregroundColor:
                    _canSave ? Colors.white : const Color(0xFFAAAAAA),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw * 0.08),
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
        ),
      ),
    );
  }

  Widget _buildLabel(double sw, String text, Color subtitleColor) {
    return Text(
      text,
      style: TextStyle(
        fontSize: sw * 0.034,
        color: subtitleColor,
      ),
    );
  }

  Widget _buildTextField(
      double sw,
      TextEditingController controller,
      String label,
      Color textColor,
      Color subtitleColor,
      Color borderColor, {
        TextInputType inputType = TextInputType.text,
        int maxLines = 1,
        int? maxLength,
      }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      maxLength: maxLength,
      style: TextStyle(color: textColor),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        counterStyle: TextStyle(color: subtitleColor),
        counterText: maxLength != null
            ? '${controller.text.length}/$maxLength'
            : '',
        labelStyle: TextStyle(
          color: subtitleColor,
          fontSize: sw * 0.038,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildDateField(
      double sw,
      TextEditingController controller,
      String label,
      Color textColor,
      Color subtitleColor,
      Color borderColor,
      ) {
    return GestureDetector(
      onTap: () => _pickDate(controller),
      child: AbsorbPointer(
        child: _buildTextField(sw, controller, label, textColor, subtitleColor, borderColor),
      ),
    );
  }
}