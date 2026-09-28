import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/api/job_role_api.dart';

class AddJobRolePopup extends StatefulWidget {
  final List<String>? initialRoles;

  const AddJobRolePopup({super.key, this.initialRoles});

  @override
  State<AddJobRolePopup> createState() => _AddJobRolePopupState();
}

class _AddJobRolePopupState extends State<AddJobRolePopup> {
  final List<TextEditingController> _controllers = [];
  final List<Key> _fieldKeys = [];
  List<String> _availableJobRoles = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialRoles != null && widget.initialRoles!.isNotEmpty) {
      for (var role in widget.initialRoles!) {
        _controllers.add(TextEditingController(text: role));
        _fieldKeys.add(UniqueKey());
      }
    } else {
      _controllers.add(TextEditingController());
      _fieldKeys.add(UniqueKey());
    }
    _loadJobRoles();
  }

  Future<void> _loadJobRoles() async {
    final res = await JobRoleApi.fetchJobRoles();
    if (!mounted) return;
    if (res['error'] == false && res['data'] is List) {
      final List dataList = res['data'];
      final List<String> roles = dataList
          .map((e) => e['role']?.toString() ?? '')
          .where((role) => role.isNotEmpty)
          .toList();
      roles.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      setState(() {
        _availableJobRoles = roles;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addAnotherField() {
    if (_controllers.length < 10) {
      setState(() {
        _controllers.add(TextEditingController());
        _fieldKeys.add(UniqueKey());
      });
    }
  }

  void _removeField(int index) {
    if (_controllers.length > 1) {
      setState(() {
        _controllers[index].dispose();
        _controllers.removeAt(index);
        _fieldKeys.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double sw = size.width;

    // Responsive measurements
    final double paddingAll = sw * 0.05;
    final double headingFontSize = sw * 0.042;
    final double subHeadingFontSize = sw * 0.038;
    final double hintFontSize = sw * 0.032;
    final double buttonHeight = sw * 0.12;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.08),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Padding(
            padding: EdgeInsets.fromLTRB(paddingAll, paddingAll, paddingAll, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      color: textColor,
                      size: sw * 0.055,
                    ),
                    SizedBox(width: sw * 0.025),
                    Text(
                      'Add  Job Role',
                      style: TextStyle(
                        fontSize: headingFontSize,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: textColor,
                    size: sw * 0.055,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: borderColor, thickness: 1),

          // Body Scrollable Section
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: paddingAll, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What are your desired job titles?',
                    style: TextStyle(
                      fontSize: subHeadingFontSize,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: sw * 0.01),
                  Text(
                    'Add up to ten job titles',
                    style: TextStyle(
                      fontSize: hintFontSize,
                      color: subtitleColor,
                    ),
                  ),
                  SizedBox(height: sw * 0.04),

                  // Dynamic list of inputs with Autocomplete and unique Keys
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _controllers.length,
                    separatorBuilder: (context, index) => SizedBox(height: sw * 0.03),
                    itemBuilder: (context, index) {
                      return KeyedSubtree(
                        key: _fieldKeys[index],
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: sw * 0.11,
                                child: Autocomplete<String>(
                                  optionsBuilder: (TextEditingValue textEditingValue) {
                                    final query = textEditingValue.text.trim().toLowerCase();
                                    if (query.isEmpty) {
                                      return const Iterable<String>.empty();
                                    }

                                    // If exact match with an existing option, hide suggestions
                                    final bool isExactMatch = _availableJobRoles.any(
                                      (role) => role.toLowerCase() == query,
                                    );
                                    if (isExactMatch) {
                                      return const Iterable<String>.empty();
                                    }

                                    final startsWith = _availableJobRoles
                                        .where((role) => role.toLowerCase().startsWith(query))
                                        .toList()
                                      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

                                    final contains = _availableJobRoles
                                        .where((role) =>
                                            !role.toLowerCase().startsWith(query) &&
                                            role.toLowerCase().contains(query))
                                        .toList()
                                      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

                                    return [...startsWith, ...contains];
                                  },
                                  onSelected: (String selection) {
                                    _controllers[index].text = selection;
                                    FocusScope.of(context).unfocus();
                                  },
                                  fieldViewBuilder: (
                                    BuildContext context,
                                    TextEditingController fieldController,
                                    FocusNode focusNode,
                                    VoidCallback onFieldSubmitted,
                                  ) {
                                    if (fieldController.text != _controllers[index].text) {
                                      fieldController.text = _controllers[index].text;
                                      fieldController.selection = TextSelection.collapsed(
                                        offset: fieldController.text.length,
                                      );
                                    }

                                    return TextField(
                                      controller: fieldController,
                                      focusNode: focusNode,
                                      onChanged: (val) {
                                        _controllers[index].text = val;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'e.g. Software Engineer',
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: borderColor, width: 1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: sw * 0.038,
                                        color: textColor,
                                      ),
                                    );
                                  },
                                  optionsViewBuilder: (
                                    BuildContext context,
                                    AutocompleteOnSelected<String> onSelected,
                                    Iterable<String> options,
                                  ) {
                                    return Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                        elevation: 4.0,
                                        borderRadius: BorderRadius.circular(8),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight: 200,
                                            maxWidth: sw * 0.7,
                                          ),
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            itemCount: options.length,
                                            itemBuilder: (BuildContext context, int optionIndex) {
                                              final String option = options.elementAt(optionIndex);
                                              return ListTile(
                                                dense: true,
                                                title: Text(
                                                  option,
                                                  style: TextStyle(fontSize: sw * 0.036),
                                                ),
                                                onTap: () {
                                                  onSelected(option);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            if (_controllers.length > 1) ...[
                              SizedBox(width: sw * 0.02),
                              GestureDetector(
                                onTap: () => _removeField(index),
                                child: Icon(
                                  Icons.remove_circle_outline_rounded,
                                  color: AppColors.red,
                                  size: sw * 0.06,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),

                  if (_controllers.length < 10) ...[
                    SizedBox(height: sw * 0.03),
                    GestureDetector(
                      onTap: _addAnotherField,
                      child: Text(
                        '+ Add Another',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: sw * 0.038,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          Divider(color: borderColor, thickness: 1),

          // Footer Buttons
          Padding(
            padding: EdgeInsets.fromLTRB(paddingAll, 8, paddingAll, paddingAll),
            child: Column(
              children: [
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      final List<String> roles = _controllers
                          .map((c) => c.text.trim())
                          .where((text) => text.isNotEmpty)
                          .toList();
                      Navigator.pop(context, roles);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: sw * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: sw * 0.03),
                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F5F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: textColor,
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
