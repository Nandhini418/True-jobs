import 'package:flutter/material.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/services/api/condition_type_api.dart';

class ConditionTypeSheet extends StatefulWidget {
  final String currentCondition;
  final ValueChanged<String> onConditionSelected;

  const ConditionTypeSheet({
    super.key,
    required this.currentCondition,
    required this.onConditionSelected,
  });

  @override
  State<ConditionTypeSheet> createState() => _ConditionTypeSheetState();
}

class _ConditionTypeSheetState extends State<ConditionTypeSheet> {
  late String _selectedCondition;
  bool _isLoading = true;
  List<String> _conditions = [];

  @override
  void initState() {
    super.initState();
    _selectedCondition = widget.currentCondition;
    _fetchConditions();
  }

  Future<void> _fetchConditions() async {
    try {
      final response = await ConditionTypeApi.fetchConditions();

      if (response['status'] == 'success' || response['error'] == false) {
        final List<dynamic>? rawList = response['data'];
        if (rawList != null) {
          final List<String> fetched = [];
          for (var item in rawList) {
            if (item is Map) {
              String name = '';
              item.forEach((key, val) {
                if (key.toString().toLowerCase().contains('name') ||
                    key.toString().toLowerCase() == 'label' ||
                    key.toString().toLowerCase() == 'title') {
                  name = val.toString();
                }
              });
              if (name.isEmpty && item.values.isNotEmpty) {
                name = item.values.first.toString();
              }
              if (name.isNotEmpty) {
                fetched.add(name);
              }
            } else if (item is String) {
              fetched.add(item);
            }
          }
          if (mounted && fetched.isNotEmpty) {
            setState(() {
              _conditions = fetched;
              _isLoading = false;
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching conditions: $e');
    }

    if (mounted) {
      setState(() {
        _conditions = [
          'Locomotor Disability',
          'Visual Impairment',
          'Hearing Impairment',
          'Speech & Language Disability',
          'Mental Illness',
          'Intellectual Disability',
          'Multiple Disabilities',
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color borderColor = AppColors.dynamicBorder;
    final Color cardBg = AppColors.dynamicCardBg;

    return Container(
      height: screenHeight * 0.6,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Condition Type',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: AppColors.primary, size: screenWidth * 0.06),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),

          // List
          _isLoading
              ? const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
              : Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(screenWidth * 0.04),
              itemCount: _conditions.length,
              itemBuilder: (context, index) {
                final condition = _conditions[index];
                final bool isSelected = _selectedCondition == condition;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCondition = condition;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.018,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE7EFFF) : cardBg,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : borderColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          condition,
                          style: TextStyle(
                            fontSize: screenWidth * 0.038,
                            color: isSelected ? AppColors.primary : textColor,
                          ),
                        ),
                        Container(
                          width: screenWidth * 0.05,
                          height: screenWidth * 0.05,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                            child: Container(
                              width: screenWidth * 0.03,
                              height: screenWidth * 0.03,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Divider(height: 1, color: borderColor),

          // Bottom Buttons
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0E0E0),
                      foregroundColor: textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.08),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onConditionSelected(_selectedCondition);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.08),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                    ),
                    child: const Text('Save'),
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
