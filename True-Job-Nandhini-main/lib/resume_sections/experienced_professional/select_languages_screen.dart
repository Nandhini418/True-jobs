import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';

class SelectLanguagesScreen extends StatefulWidget {
  final List<String> initialSelected;

  const SelectLanguagesScreen({
    super.key,
    required this.initialSelected,
  });

  @override
  State<SelectLanguagesScreen> createState() => _SelectLanguagesScreenState();
}

class _SelectLanguagesScreenState extends State<SelectLanguagesScreen> {
  final List<String> _allLanguages = [
    'Other',
    'English',
    'Malayalam',
    'Telugu',
    'Tamil',
    'Hindi',
    'Kannada',
    'Marathi',
    'Gujarati',
    'Bengali',
    'Odia',
    'Punjabi',
    'Urdu',
  ];

  late List<String> _selectedLanguages;

  @override
  void initState() {
    super.initState();
    _selectedLanguages = List.from(widget.initialSelected);
  }

  void _toggleLanguage(String language, bool? isSelected) {
    setState(() {
      if (isSelected == true) {
        if (!_selectedLanguages.contains(language)) {
          _selectedLanguages.add(language);
        }
      } else {
        _selectedLanguages.remove(language);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Select Languages",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black, size: 24.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                itemCount: _allLanguages.length,
                separatorBuilder: (context, index) => const Divider(color: Color(0xFFEEEEEE), height: 1),
                itemBuilder: (context, index) {
                  final lang = _allLanguages[index];
                  final isSelected = _selectedLanguages.contains(lang);
                  return CheckboxListTile(
                    title: Text(
                      lang,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black87,
                      ),
                    ),
                    value: isSelected,
                    onChanged: (val) => _toggleLanguage(lang, val),
                    activeColor: AppColors.primary,
                    checkColor: Colors.white,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.trailing,
                    checkboxShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  );
                },
              ),
            ),
            // Submit Button
            Padding(
              padding: EdgeInsets.all(20.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedLanguages);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
