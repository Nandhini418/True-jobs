import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'job_create_widgets.dart';

class Step2CandidateReqs extends StatefulWidget {
  final String? minEducation;
  final ValueChanged<String?> onMinEducationChanged;
  final List<String> educationOptions;

  final TextEditingController experienceController;

  final String? englishLevel;
  final ValueChanged<String?> onEnglishLevelChanged;
  final List<String> englishLevelOptions;

  final List<String> selectedSkills;
  final List<String> skillOptions;
  final bool isLoadingSkills;
  final void Function(String) onAddSkill;
  final void Function(String) onRemoveSkill;
  final void Function(String, TextEditingController) onAddNewSkillToDB;

  const Step2CandidateReqs({
    super.key,
    required this.minEducation,
    required this.onMinEducationChanged,
    required this.educationOptions,
    required this.experienceController,
    required this.englishLevel,
    required this.onEnglishLevelChanged,
    required this.englishLevelOptions,
    required this.selectedSkills,
    required this.skillOptions,
    required this.isLoadingSkills,
    required this.onAddSkill,
    required this.onRemoveSkill,
    required this.onAddNewSkillToDB,
  });

  @override
  State<Step2CandidateReqs> createState() => _Step2CandidateReqsState();
}

class _Step2CandidateReqsState extends State<Step2CandidateReqs> {
  TextEditingController? _skillsSearchController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Candidate Requirements', subtitle: 'Define the ideal candidate for this role'),
        
        buildDropdownField(
          label: 'Minimum Education',
          value: widget.minEducation,
          hintText: 'Select education level',
          items: widget.educationOptions,
          onChanged: widget.onMinEducationChanged,
        ),
        
        buildTextField(
          label: 'Experience',
          hintText: 'e.g 2-3 years',
          controller: widget.experienceController,
        ),
        
        _buildEnglishLevelField(),

        _buildSearchableSkillsField(),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildEnglishLevelField() {
    return FormField<String>(
      initialValue: widget.englishLevel,
      validator: (val) => val == null ? 'Required field' : null,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildFieldLabel('English Level'),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 15.w,
              runSpacing: 11.h,
              children: widget.englishLevelOptions.where((opt) => opt != 'No English Required').map((option) {
                final isSelected = widget.englishLevel == option;
                return GestureDetector(
                  onTap: () {
                    widget.onEnglishLevelChanged(option);
                    state.didChange(option);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : const Color(0xFFC7C7C7),
                        width: 0.72,
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontFamily: kJobFontFamily,
                        fontSize: 12.sp,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.dynamicText,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (state.hasError)
              Padding(
                padding: EdgeInsets.only(top: 7.h),
                child: Text(
                  state.errorText!,
                  style: TextStyle(fontFamily: kJobFontFamily, fontSize: 10.sp, color: Colors.red),
                ),
              ),
            SizedBox(height: 14.h),
          ],
        );
      },
    );
  }

  Widget _buildSearchableSkillsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFieldLabel('Required Skills'),
        SizedBox(height: 4.h),
        Text('You can add up to 15 key skills to make your job visible to the right candidates.', style: TextStyle(fontFamily: kJobFontFamily, fontSize: 11.sp, color: AppColors.dynamicSubtitle)),
        SizedBox(height: 10.h),

        

        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (widget.isLoadingSkills) return const Iterable<String>.empty();
            final available = widget.skillOptions.where((e) => !widget.selectedSkills.contains(e));
            if (textEditingValue.text.isEmpty) return available;
            
            final query = textEditingValue.text.toLowerCase();
            final matches = available.where((option) => option.toLowerCase().contains(query)).toList();
            
            final isExactMatch = widget.skillOptions.any((option) => option.toLowerCase() == query);
            if (!isExactMatch && textEditingValue.text.trim().isNotEmpty) {
              matches.insert(0, 'Add "${textEditingValue.text.trim()}"');
            }
            
            return matches;
          },
          onSelected: (String selection) {
            if (widget.selectedSkills.length < 15) {
              if (selection.startsWith('Add "') && selection.endsWith('"')) {
                final newSkill = selection.substring(5, selection.length - 1);
                if (_skillsSearchController != null) {
                  widget.onAddNewSkillToDB(newSkill, _skillsSearchController!);
                } else {
                  widget.onAddSkill(newSkill);
                }
              } else {
                widget.onAddSkill(selection);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 15 skills allowed')));
            }
            Future.delayed(Duration.zero, () => _skillsSearchController?.clear());
            FocusManager.instance.primaryFocus?.unfocus();
          },
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            _skillsSearchController = controller;
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              decoration: InputDecoration(
                hintText: widget.isLoadingSkills ? 'Loading skills...' : 'Search or add a skill',
                hintStyle: TextStyle(fontFamily: kJobFontFamily, color: AppColors.grey, fontSize: 13.sp),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: AppColors.primary)),
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                isDense: true,
              ),
              style: TextStyle(fontFamily: kJobFontFamily, fontSize: 13.sp, color: Colors.black),
              onFieldSubmitted: (val) {
                if (widget.selectedSkills.length < 15) {
                  widget.onAddNewSkillToDB(val, controller);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 15 skills allowed')));
                }
              },
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
        if (widget.selectedSkills.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: widget.selectedSkills.map((skill) {
              return Chip(
                label: Text(skill, style: TextStyle(fontFamily: kJobFontFamily, fontSize: 12.sp, color: AppColors.primary)),
                backgroundColor: const Color(0xFFEAEFFC),
                deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.primary),
                onDeleted: () => widget.onRemoveSkill(skill),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r), side: const BorderSide(color: AppColors.primary)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
