import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truejobs/services/api/skills_select_api.dart';
import 'package:truejobs/services/api/skills_insert_api.dart';

class AddSkillsScreen extends StatefulWidget {
  const AddSkillsScreen({super.key});

  @override
  State<AddSkillsScreen> createState() => _AddSkillsScreenState();
}

class _AddSkillsScreenState extends State<AddSkillsScreen> {
  final TextEditingController _skillController = TextEditingController();
  List<String> _skillsList = [];
  List<Map<String, dynamic>> _masterSkills = [];
  List<Map<String, dynamic>> _filteredSuggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedSkills();
    _loadMasterSkills();
  }

  Future<void> _loadMasterSkills() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await SkillsSelectApi.fetchSkills();
      if (res['status'] == 'success' || res['error'] == false) {
        final List<dynamic>? list = res['data'];
        if (list != null && list.isNotEmpty) {
          final List<Map<String, dynamic>> fetched = [];
          for (var item in list) {
            if (item is Map) {
              final idStr = (item['id'] ?? item['value'] ?? '').toString();
              fetched.add({
                'value': idStr,
                'name': item['name']?.toString() ?? '',
              });
            }
          }
          if (fetched.isNotEmpty && mounted) {
            fetched.sort((a, b) =>
                (a['name'] ?? '').toString().toLowerCase().compareTo(
                    (b['name'] ?? '').toString().toLowerCase()));
            setState(() {
              _masterSkills = fetched;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading master skills: $e');
    } finally {
      await _loadSavedSkills();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _getPrefsKey() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId;
    try {
      userId = prefs.getInt('user_id');
    } catch (_) {
      final String? userIdStr = prefs.getString('user_id');
      if (userIdStr != null) {
        userId = int.tryParse(userIdStr);
      }
    }
    if (userId == null) {
      final String? cidStr = prefs.getString('cid');
      if (cidStr != null) {
        userId = int.tryParse(cidStr);
      }
    }
    if (userId != null) {
      return 'user_${userId}_skills';
    }
    return 'user_skills';
  }

  Future<void> _loadSavedSkills() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getPrefsKey();
    final List<String> saved = prefs.getStringList(key) ?? [];
    if (mounted) {
      setState(() {
        _skillsList = saved;
      });
    }

    int? userId;
    try {
      userId = prefs.getInt('user_id');
    } catch (_) {
      final String? userIdStr = prefs.getString('user_id');
      if (userIdStr != null) {
        userId = int.tryParse(userIdStr);
      }
    }
    if (userId == null) {
      final String? cidStr = prefs.getString('cid');
      if (cidStr != null) {
        userId = int.tryParse(cidStr);
      }
    }

    if (userId != null) {
      try {
        final userSkillsRes = await SkillsSelectApi.fetchUserSkills(name: userId.toString());
        if (userSkillsRes['status'] == 'success' || userSkillsRes['error'] == false) {
          final rawData = userSkillsRes['data'];
          List<dynamic> skillItems = [];
          if (rawData is List) {
            skillItems = rawData;
          } else if (rawData is Map && rawData['skills'] != null) {
            if (rawData['skills'] is List) {
              skillItems = rawData['skills'];
            }
          }

          if (skillItems.isNotEmpty) {
            final List<String> serverSkills = [];
            for (var item in skillItems) {
              if (item is Map) {
                final String name = item['name']?.toString() ?? item['skill_name']?.toString() ?? '';
                if (name.isNotEmpty && !serverSkills.contains(name)) {
                  serverSkills.add(name);
                }
              } else if (item != null) {
                final idStr = item.toString();
                final matched = _masterSkills.firstWhere(
                  (m) => m['value']?.toString() == idStr || m['name']?.toString().toLowerCase() == idStr.toLowerCase(),
                  orElse: () => <String, dynamic>{},
                );
                if (matched.isNotEmpty) {
                  final String name = matched['name']?.toString() ?? idStr;
                  if (!serverSkills.contains(name)) serverSkills.add(name);
                } else if (int.tryParse(idStr) == null && idStr.isNotEmpty) {
                  if (!serverSkills.contains(idStr)) serverSkills.add(idStr);
                }
              }
            }

            if (serverSkills.isNotEmpty && mounted) {
              setState(() {
                _skillsList = serverSkills;
              });
              await prefs.setStringList(key, serverSkills);
            }
          }
        }
      } catch (e) {
        debugPrint('Error fetching user skills from server: $e');
      }
    }
  }

  void _onSearchChanged(String value) {
    final query = value.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredSuggestions = [];
      });
    } else {
      final matching = _masterSkills.where((skill) {
        final name = skill['name']?.toString() ?? '';
        return name.toLowerCase().contains(query) && !_skillsList.contains(name);
      }).toList();

      final startsWith = matching.where((skill) {
        final name = (skill['name'] ?? '').toString().toLowerCase();
        return name.startsWith(query);
      }).toList()
        ..sort((a, b) => (a['name'] ?? '')
            .toString()
            .toLowerCase()
            .compareTo((b['name'] ?? '').toString().toLowerCase()));

      final contains = matching.where((skill) {
        final name = (skill['name'] ?? '').toString().toLowerCase();
        return !name.startsWith(query);
      }).toList()
        ..sort((a, b) => (a['name'] ?? '')
            .toString()
            .toLowerCase()
            .compareTo((b['name'] ?? '').toString().toLowerCase()));

      setState(() {
        _filteredSuggestions = [...startsWith, ...contains];
      });
    }
  }

  void _addSkill() {
    final text = _skillController.text.trim();
    if (text.isNotEmpty) {
      final matched = _masterSkills.firstWhere(
        (item) => (item['name']?.toString() ?? '').toLowerCase() == text.toLowerCase(),
        orElse: () => <String, dynamic>{},
      );
      if (matched.isNotEmpty) {
        final exactName = matched['name']?.toString() ?? text;
        setState(() {
          if (!_skillsList.contains(exactName)) {
            _skillsList.add(exactName);
          }
          _skillController.clear();
          _filteredSuggestions = [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a skill from the list.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _removeSkill(int index) {
    setState(() {
      _skillsList.removeAt(index);
    });
  }

  Future<void> _saveSkills() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get userId
      int? userId;
      try {
        userId = prefs.getInt('user_id');
      } catch (_) {
        final String? userIdStr = prefs.getString('user_id');
        if (userIdStr != null) {
          userId = int.tryParse(userIdStr);
        }
      }
      if (userId == null) {
        final String? cidStr = prefs.getString('cid');
        if (cidStr != null) {
          userId = int.tryParse(cidStr);
        }
      }

      if (userId != null) {
        // Map selected skill names to their IDs from _masterSkills
        final List<int> selectedIds = [];
        for (var skillName in _skillsList) {
          final matched = _masterSkills.firstWhere(
            (item) => (item['name']?.toString() ?? '').toLowerCase() == skillName.toLowerCase(),
            orElse: () => <String, dynamic>{},
          );
          if (matched.isNotEmpty) {
            final idVal = int.tryParse(matched['value']?.toString() ?? '');
            if (idVal != null) {
              selectedIds.add(idVal);
            }
          }
        }

        // Call the insert API with selectedIds or [0] to clear the skills on the server backend
        final insertRes = await SkillsInsertApi.insertSkills(
          name: userId.toString(),
          skills: selectedIds.isNotEmpty ? selectedIds : [0],
        );

        if (insertRes['status'] != 'success' && insertRes['error'] != false) {
          throw Exception(insertRes['message'] ?? 'Failed to save skills to server');
        }
      }

      // Save locally in SharedPreferences for immediate caching
      final key = await _getPrefsKey();
      await prefs.setStringList(key, _skillsList);

      if (mounted) {
        Navigator.pop(context, true); // return success
      }
    } catch (e) {
      debugPrint('Error saving skills: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving skills: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AppColors.dynamicBg;
    final Color cardBg = AppColors.dynamicCardBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 0.055.sw),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Skills',
          style: TextStyle(
            color: textColor,
            fontSize: 0.05.sw,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Column(
                children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 0.05.sw, vertical: 0.04.sw),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input search/add container with shadow
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        border: Border.all(
                          color: borderColor
                        ),
                        borderRadius: BorderRadius.circular(0.08.sw),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x14000000), // #00000014
                            offset: const Offset(0, 8),
                            blurRadius: 16,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: const Color(0x0A000000), // #0000000A
                            offset: const Offset(0, 0),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0.05.sw),
                              child: TextField(
                                controller: _skillController,
                                decoration: InputDecoration(
                                  hintText: 'Add Your Skills',
                                  hintStyle: TextStyle(color: subtitleColor),
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  fontSize: 0.04.sw,
                                  color: textColor,
                                ),
                                onChanged: _onSearchChanged,
                                onSubmitted: (_) => _addSkill(),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _addSkill,
                            child: Container(
                              margin: EdgeInsets.all(0.015.sw),
                              width: 0.11.sw,
                              height: 0.11.sw,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE7EFFF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add,
                                color: AppColors.primary,
                                size: 0.06.sw,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_filteredSuggestions.isNotEmpty) ...[
                      SizedBox(height: 0.02.sw),
                      Container(
                        constraints: BoxConstraints(maxHeight: 0.25.sh),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _filteredSuggestions.length,
                          separatorBuilder: (_, ignore) => Divider(height: 1, color: borderColor),
                          itemBuilder: (context, index) {
                            final skill = _filteredSuggestions[index];
                            final skillName = skill['name']?.toString() ?? '';
                            return ListTile(
                              title: Text(
                                skillName,
                                style: TextStyle(
                                  fontSize: 0.038.sw,
                                  color: textColor,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 0.035.sw,
                                color: subtitleColor,
                              ),
                              onTap: () {
                                setState(() {
                                  if (!_skillsList.contains(skillName)) {
                                    _skillsList.add(skillName);
                                  }
                                  _skillController.clear();
                                  _filteredSuggestions = [];
                                });
                                FocusScope.of(context).unfocus();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                    SizedBox(height: 0.08.sw),

                    // Section header
                    Text(
                      'Key skills of you',
                      style: TextStyle(
                        fontSize: 0.045.sw,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 0.04.sw),

                    // Wrap Grid of Skills
                    Wrap(
                      spacing: 0.03.sw,
                      runSpacing: 0.03.sw,
                      children: List.generate(_skillsList.length, (index) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 0.035.sw, vertical: 0.015.sw),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7EFFF), // Light purple/dark blue background
                            borderRadius: BorderRadius.circular(0.05.sw),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _skillsList[index],
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 0.035.sw,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 0.02.sw),
                              GestureDetector(
                                onTap: () => _removeSkill(index),
                                child: Icon(
                                  Icons.close,
                                  color: AppColors.primary.withValues(alpha: 0.8),
                                  size: 0.045.sw,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions (Cancel / Save)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 0.05.sw, vertical: 0.04.sw),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(top: BorderSide(color: borderColor, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 0.05.sh,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.06.sw),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 0.04.sw,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 0.04.sw),
                  Expanded(
                    child: SizedBox(
                      height: 0.05.sh,
                      child: ElevatedButton(
                        onPressed: _saveSkills,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.06.sw),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 0.04.sw,
                            fontWeight: FontWeight.bold,
                          ),
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
