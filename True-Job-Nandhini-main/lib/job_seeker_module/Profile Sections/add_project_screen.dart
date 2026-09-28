import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Model to hold one saved project entry
class ProjectEntry {
  final String? id;
  final String projectName;
  final String startDate;
  final String endDate;
  final String details;
  final String keySkills;
  final String projectUrl;

  ProjectEntry({
    this.id,
    required this.projectName,
    required this.startDate,
    required this.endDate,
    required this.details,
    required this.keySkills,
    required this.projectUrl,
  });
}

class AddProjectScreen extends StatefulWidget {
  final ProjectEntry? existingEntry; // non-null when editing

  const AddProjectScreen({super.key, this.existingEntry});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _projectName = TextEditingController();
  final _startDate = TextEditingController();
  final _endDate = TextEditingController();
  final _details = TextEditingController();
  final _keySkills = TextEditingController();
  final _projectUrl = TextEditingController();

  static const int _detailsMaxLength = 1000;

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
      debugPrint('AddProjectScreen: Initiating Edit Mode. Existing Project ID = ${e.id}');
      _projectName.text = e.projectName;
      _startDate.text = _formatToDisplay(e.startDate);
      _endDate.text = _formatToDisplay(e.endDate);
      _details.text = e.details;
      _keySkills.text = e.keySkills;
      _projectUrl.text = e.projectUrl;
    }
    _details.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _projectName.dispose();
    _startDate.dispose();
    _endDate.dispose();
    _details.dispose();
    _keySkills.dispose();
    _projectUrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _projectName.text.trim().isNotEmpty &&
          _details.text.trim().isNotEmpty;

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
        title: const Text('Delete Project'),
        content: const Text(
          'Are you sure you want to delete this project details?',
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
    final entry = ProjectEntry(
      id: widget.existingEntry?.id != null && widget.existingEntry!.id!.isNotEmpty
          ? widget.existingEntry!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      projectName: _projectName.text.trim(),
      startDate: _formatToApi(_startDate.text.trim()),
      endDate: _formatToApi(_endDate.text.trim()),
      details: _details.text.trim(),
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
          'Project',
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
              tooltip: 'Delete Project',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: sw * 0.05,
            right: sw * 0.05,
            top: sw * 0.02,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Showcase your talent with the best projects you have worked on during college and work',
                style: TextStyle(
                  fontSize: sw * 0.038,
                  color: AppColors.primary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: sw * 0.08),

              _buildFieldSection(
                sw: sw,
                label: 'Project name',
                child: _buildInputBox(
                  controller: _projectName,
                  hintText: 'Enter project name',
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  borderColor: borderColor,
                ),
              ),
              SizedBox(height: sw * 0.06),

              Text(
                'Project duration',
                style: TextStyle(
                  fontSize: sw * 0.038,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: sw * 0.02),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildFieldSection(
                      sw: sw,
                      label: 'Start date',
                      child: _buildDateField(
                        sw,
                        _startDate,
                        'Start date',
                        textColor,
                        subtitleColor,
                        borderColor,
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.06),
                  Expanded(
                    child: _buildFieldSection(
                      sw: sw,
                      label: 'End date',
                      child: _buildDateField(
                        sw,
                        _endDate,
                        'End date',
                        textColor,
                        subtitleColor,
                        borderColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sw * 0.06),

              _buildFieldSection(
                sw: sw,
                label: 'Details of project',
                child: _buildInputBox(
                  controller: _details,
                  hintText: 'Enter project details',
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  borderColor: borderColor,
                  multiline: true,
                  minLines: 1,
                  maxLines: 5,
                  maxLength: _detailsMaxLength,
                ),
              ),
              SizedBox(height: sw * 0.06),

              _buildFieldSection(
                sw: sw,
                label: 'Key skills used in the project (optional)',
                child: _buildInputBox(
                  controller: _keySkills,
                  hintText: 'e.g. Flutter, Firebase',
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  borderColor: borderColor,
                ),
              ),
              SizedBox(height: sw * 0.06),

              _buildFieldSection(
                sw: sw,
                label: 'Project URL (optional)',
                child: _buildInputBox(
                  controller: _projectUrl,
                  hintText: 'https://github.com/my-project',
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  borderColor: borderColor,
                  inputType: TextInputType.url,
                ),
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

  Widget _buildFieldSection({
    required double sw,
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: sw * 0.038,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: sw * 0.015),
        child,
      ],
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required String hintText,
    required Color textColor,
    required Color subtitleColor,
    required Color borderColor,
    TextInputType inputType = TextInputType.text,
    bool multiline = false,
    int? minLines,
    int? maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: multiline ? TextInputType.multiline : inputType,
      minLines: minLines,
      maxLines: multiline ? maxLines : 1,
      maxLength: maxLength,
      style: TextStyle(color: textColor, fontSize: 15),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: subtitleColor.withValues(alpha: 0.7), fontSize: 14),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        counterStyle: TextStyle(color: subtitleColor, fontSize: 12),
        counterText: maxLength != null
            ? '${controller.text.length}/$maxLength'
            : null,
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
    String hint,
    Color textColor,
    Color subtitleColor,
    Color borderColor,
  ) {
    return GestureDetector(
      onTap: () => _pickDate(controller),
      child: AbsorbPointer(
        child: _buildInputBox(
          controller: controller,
          hintText: hint,
          textColor: textColor,
          subtitleColor: subtitleColor,
          borderColor: borderColor,
        ),
      ),
    );
  }
}