import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'job_create_widgets.dart';

class Step1JobDetails extends StatefulWidget {
  final TextEditingController titleController;
  final String? departmentType;
  final ValueChanged<String?> onDepartmentChanged;
  final List<dynamic> departmentOptions;
  final bool isLoadingDepartments;
  final String? employmentType;
  final ValueChanged<String?> onEmploymentTypeChanged;
  final List<dynamic> employmentTypeOptions;
  final bool isLoadingEmploymentTypes;
  final String? workLocType;
  final ValueChanged<String?> onWorkLocTypeChanged;
  final List<dynamic> locationTypeOptions;
  final bool isLoadingLocationTypes;
  final TextEditingController locationController;
  final TextEditingController openingsController;

  final String? salaryType;
  final ValueChanged<String?> onSalaryTypeChanged;
  final List<dynamic> salaryTypeOptions;
  final bool isLoadingSalaryTypes;
  final TextEditingController salaryRangeController;

  final List<String> selectedPerks;
  final List<String> perkOptions;
  final bool isLoadingPerks;
  final void Function(String) onAddPerk;
  final void Function(String) onRemovePerk;
  final void Function(String, TextEditingController) onAddNewPerkToDB;

  const Step1JobDetails({
    super.key,
    required this.titleController,
    required this.departmentType,
    required this.onDepartmentChanged,
    required this.departmentOptions,
    required this.isLoadingDepartments,
    required this.employmentType,
    required this.onEmploymentTypeChanged,
    required this.employmentTypeOptions,
    required this.isLoadingEmploymentTypes,
    required this.workLocType,
    required this.onWorkLocTypeChanged,
    required this.locationTypeOptions,
    required this.isLoadingLocationTypes,
    required this.locationController,
    required this.openingsController,
    required this.salaryType,
    required this.onSalaryTypeChanged,
    required this.salaryTypeOptions,
    required this.isLoadingSalaryTypes,
    required this.salaryRangeController,
    required this.selectedPerks,
    required this.perkOptions,
    required this.isLoadingPerks,
    required this.onAddPerk,
    required this.onRemovePerk,
    required this.onAddNewPerkToDB,
  });

  @override
  State<Step1JobDetails> createState() => _Step1JobDetailsState();
}

class _Step1JobDetailsState extends State<Step1JobDetails> {
  TextEditingController? _perksSearchController;

  void _incrementOpenings() {
    int current = int.tryParse(widget.openingsController.text) ?? 1;
    widget.openingsController.text = (current + 1).toString();
  }

  void _decrementOpenings() {
    int current = int.tryParse(widget.openingsController.text) ?? 1;
    if (current > 1) {
      widget.openingsController.text = (current - 1).toString();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.openingsController.text.isEmpty) {
      widget.openingsController.text = '1';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('1. Basic Information'),
        
        buildTextField(
          label: 'Job title',
          hintText: 'Enter job title',
          controller: widget.titleController,
        ),

        buildApiDropdownField(
                label: 'Department',
                value: widget.departmentType,
                hintText: 'Select Department',
                apiOptions: widget.departmentOptions,
                isLoading: widget.isLoadingDepartments,
                onChanged: widget.onDepartmentChanged,
              ),
        
        Row(
          children: [
            Expanded(
              child: buildApiDropdownField(
                label: 'Employment Type',
                value: widget.employmentType,
                hintText: 'Select Type',
                apiOptions: widget.employmentTypeOptions,
                isLoading: widget.isLoadingEmploymentTypes,
                onChanged: widget.onEmploymentTypeChanged,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: buildApiDropdownField(
          label: 'Work Loc Type',
          value: widget.workLocType,
          hintText: 'Select Type',
          apiOptions: widget.locationTypeOptions,
          isLoading: widget.isLoadingLocationTypes,
          onChanged: widget.onWorkLocTypeChanged,
        ),
            ),
          ],
        ),
        
        
        
        buildTextField(
          label: 'Location',
          hintText: 'Enter Location',
          controller: widget.locationController,
        ),

        // Custom Openings Field
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: buildFieldLabel('Number of openings', isRequired: true),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD7D7D7)),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: _decrementOpenings,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      child: Text('-', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.dynamicText)),
                    ),
                  ),
                  Container(width: 1, height: 35.h, color: const Color(0xFFD7D7D7)),
                  SizedBox(
                    width: 50.w,
                    child: TextFormField(
                      controller: widget.openingsController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(fontFamily: kJobFontFamily, fontSize: 13.sp, color: AppColors.dynamicText),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Container(width: 1, height: 35.h, color: const Color(0xFFD7D7D7)),
                  InkWell(
                    onTap: _incrementOpenings,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      child: Text('+', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.dynamicText)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),

        buildSectionHeader('2. Compensation'),
        
        buildApiDropdownField(
          label: 'Salary Type',
          value: widget.salaryType,
          hintText: 'Select Salary Type',
          apiOptions: widget.salaryTypeOptions,
          isLoading: widget.isLoadingSalaryTypes,
          onChanged: widget.onSalaryTypeChanged,
        ),

        buildTextField(
          label: 'Salary Range',
          hintText: 'e.g. 50,000 - 80,000',
          controller: widget.salaryRangeController,
        ),

        _buildSearchablePerksField(),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildSearchablePerksField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFieldLabel('Perks & Benefits', isRequired: false),
        SizedBox(height: 7.h),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (widget.isLoadingPerks) {
              return const Iterable<String>.empty();
            }
            final available = widget.perkOptions.where(
              (e) => !widget.selectedPerks.contains(e),
            );
            if (textEditingValue.text.isEmpty) {
              return available;
            }
            
            final query = textEditingValue.text.toLowerCase();
            final matches = available.where((String option) {
              return option.toLowerCase().contains(query);
            }).toList();
            
            final isExactMatch = widget.perkOptions.any((option) => option.toLowerCase() == query);
            if (!isExactMatch && textEditingValue.text.trim().isNotEmpty) {
              matches.insert(0, 'Add "${textEditingValue.text.trim()}"');
            }
            
            return matches;
          },
          onSelected: (String selection) {
            if (selection.startsWith('Add "') && selection.endsWith('"')) {
              final newPerk = selection.substring(5, selection.length - 1);
              if (_perksSearchController != null) {
                widget.onAddNewPerkToDB(newPerk, _perksSearchController!);
              } else {
                widget.onAddPerk(newPerk);
              }
            } else {
              widget.onAddPerk(selection);
            }
            Future.delayed(Duration.zero, () {
              _perksSearchController?.clear();
            });
            FocusManager.instance.primaryFocus?.unfocus();
          },
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            _perksSearchController = controller;
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              decoration: InputDecoration(
                hintText: widget.isLoadingPerks ? 'Loading perks...' : 'Search perks...',
                hintStyle: TextStyle(fontFamily: kJobFontFamily, color: AppColors.grey, fontSize: 13.sp),
                suffixIcon: const Icon(Icons.search, color: AppColors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: AppColors.primary)),
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                isDense: true,
              ),
              style: TextStyle(fontFamily: kJobFontFamily, fontSize: 13.sp, color: Colors.black),
              onFieldSubmitted: (val) => widget.onAddNewPerkToDB(val, controller),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 250.h, maxWidth: MediaQuery.of(context).size.width - 32.w),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(option, style: TextStyle(fontFamily: kJobFontFamily, fontSize: 13.sp)),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.selectedPerks.isNotEmpty) SizedBox(height: 10.h),
        if (widget.selectedPerks.isNotEmpty)
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: widget.selectedPerks.map((perk) {
              return Chip(
                label: Text(perk, style: TextStyle(fontFamily: kJobFontFamily, fontSize: 12.sp, color: Colors.white)),
                backgroundColor: AppColors.primary,
                deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                onDeleted: () => widget.onRemovePerk(perk),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r), side: const BorderSide(color: Colors.transparent)),
              );
            }).toList(),
          ),
      ],
    );
  }
}
