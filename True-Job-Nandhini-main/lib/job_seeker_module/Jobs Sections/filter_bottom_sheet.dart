import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>>? initialFilters;

  const FilterBottomSheet({super.key, this.initialFilters});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'Freshness',
    'Sort by',
    'Work mode',
    'Location',
    'Salary',
    'Experience',
    'Walk-in',
    'Job Type',
  ];

  // Map of categories and their options with selection state
  final Map<String, List<Map<String, dynamic>>> _optionsMap = {
    'Freshness': [
      {'label': 'Last 1 day', 'checked': false},
      {'label': 'Last 3 day', 'checked': false},
      {'label': 'Last 7 day', 'checked': false},
      {'label': 'Last 15 day', 'checked': false},
      {'label': 'Last 30 day', 'checked': false},
    ],
    'Sort by': [
      {'label': 'Relevance', 'checked': true},
      {'label': 'Date', 'checked': false},
    ],
    'Work mode': [
      {'label': 'Work from office', 'checked': false},
      {'label': 'Hybrid', 'checked': false},
      {'label': 'Remote', 'checked': false},
    ],
    'Location': [
      {'label': 'Coimbatore', 'checked': false},
      {'label': 'Chennai', 'checked': false},
      {'label': 'Bangalore', 'checked': false},
    ],
    'Salary': [
      {'label': '0-3 Lacs', 'checked': false},
      {'label': '3-6 Lacs', 'checked': false},
      {'label': '6-10 Lacs', 'checked': false},
    ],
    'Experience': [
      {'label': 'Freshers', 'checked': false},
      {'label': '1-3 Yrs', 'checked': false},
      {'label': '3-5 Yrs', 'checked': false},
    ],
    'Walk-in': [
      {'label': 'Yes', 'checked': false},
      {'label': 'No', 'checked': false},
    ],
    'Job Type': [
      {'label': 'Full Time', 'checked': false},
      {'label': 'Part Time', 'checked': false},
      {'label': 'Contract', 'checked': false},
    ],
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      _optionsMap.forEach((key, list) {
        if (widget.initialFilters!.containsKey(key)) {
          for (int i = 0; i < list.length; i++) {
            list[i]['checked'] = widget.initialFilters![key]![i]['checked'];
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;
    final double sh = screenSize.height;

    final currentCategory = _categories[_selectedCategoryIndex];
    final currentOptions = _optionsMap[currentCategory] ?? [];

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color borderColor = AppColors.dynamicBorder;

    return Container(
      height: sh * 0.8,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle and Title
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: sw * 0.15,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.04),
            child: Text(
              'Filter',
              style: TextStyle(
                fontSize: sw * 0.06,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          Divider(height: 1, color: borderColor),

          // Content Area (Split Left/Right)
          Expanded(
            child: Row(
              children: [
                // Left Panel - Category list
                Container(
                  width: sw * 0.3,
                  color: bgColor,
                  child: ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedCategoryIndex;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? bgColor : Colors.grey.shade50,
                            border: isSelected
                                ? const Border(
                              bottom: BorderSide(color: AppColors.primary, width: 3),
                            )
                                : null,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.03,
                            vertical: sw * 0.045,
                          ),
                          child: Text(
                            _categories[index],
                            style: TextStyle(
                              fontSize: sw * 0.038,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Divider
                Container(width: 1, color: borderColor),
                // Right Panel - Options checklist
                Expanded(
                  child: Container(
                    color: bgColor,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.02),
                      itemCount: currentOptions.length,
                      itemBuilder: (context, index) {
                        final option = currentOptions[index];
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            option['label'],
                            style: TextStyle(
                              fontSize: sw * 0.04,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: option['checked'],
                          activeColor: AppColors.primary,
                          checkboxShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                          side: BorderSide(color: textColor, width: 1),
                          onChanged: (val) {
                            setState(() {
                              option['checked'] = val;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),

          // Bottom Action Bar
          Padding(
            padding: EdgeInsets.fromLTRB(sw * 0.05, sw * 0.04, sw * 0.05, sw * 0.06),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(sw * 0.01),
                      ),
                      padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: textColor,
                        fontSize: sw * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: sw * 0.04),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _optionsMap);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(sw * 0.01),
                      ),
                      padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                    ),
                    child: Text(
                      'Apply',
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
    );
  }
}
