import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/widgets/disability_popup.dart';
import 'package:truejobs/widgets/custom_next_button.dart';
import 'package:truejobs/job_seeker_module/qualification_screen.dart';
import 'package:truejobs/common_screens/role_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:truejobs/services/api/profile_select_api.dart';
import 'package:truejobs/services/api/gender_api.dart';
import 'package:truejobs/services/api/physically_challenged_api.dart';
import 'package:truejobs/services/api/profile_update_api.dart';

class BuildProfileScreen extends StatefulWidget {
  const BuildProfileScreen({super.key});

  @override
  State<BuildProfileScreen> createState() => _BuildProfileScreenState();
}

class _BuildProfileScreenState extends State<BuildProfileScreen> {
  String _selectedGender = '';
  String _isPhysicallyChallenged = 'No';
  bool _isLoading = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String _condType = '';
  String _affectArea = '';
  String? _profileImageUrl;

  List<Map<String, dynamic>> _physicallyChallengedOptions = [];
  List<Map<String, dynamic>> _genderOptions = [];

  @override
  void initState() {
    super.initState();
    _loadLocalData().then((_) {
      _fetchData();
    });
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _dobController.text = prefs.getString('dob') ?? '';

      _selectedGender = prefs.getString('gender') ?? '';
      _isPhysicallyChallenged = prefs.getString('physical_challenge') ?? 'No';

      _condType = prefs.getString('cond_type') ?? '';
      _affectArea = prefs.getString('affect_area') ?? '';

      _profileImageUrl = prefs.getString('profile_image_url');

      _genderOptions = [
        {'name': 'Male', 'value': '1'},
        {'name': 'Female', 'value': '2'},
        {'name': 'Others', 'value': '3'},
      ];

      _physicallyChallengedOptions = [
        {'name': 'Yes', 'value': '1'},
        {'name': 'No', 'value': '2'},
      ];
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (route) => false,
          );
        }
        return;
      }

      // 1. Fetch dynamic gender options
      try {
        final genderRes = await GenderApi.fetchGenders();
        if (genderRes['status'] == 'success' || genderRes['error'] == false) {
          final List<dynamic>? list = genderRes['data'];
          if (list != null) {
            final List<Map<String, dynamic>> parsedGenders = [];
            for (var item in list) {
              if (item is Map) {
                String name = '';
                String value = '';
                item.forEach((k, v) {
                  if (k.toString().toLowerCase().contains('name'))
                    name = v.toString();
                  if (k.toString().toLowerCase().contains('value') ||
                      k.toString().toLowerCase() == 'id')
                    value = v.toString();
                });
                if (name.isEmpty && item.values.isNotEmpty)
                  name = item.values.first.toString();
                if (value.isEmpty && item.values.length > 1)
                  value = item.values.elementAt(1).toString();
                if (name.isNotEmpty) {
                  parsedGenders.add({
                    'name': name,
                    'value': value.isNotEmpty ? value : name,
                  });
                }
              }
            }
            if (parsedGenders.isNotEmpty) {
              setState(() {
                _genderOptions = parsedGenders;
              });
            }
          }
        }
      } catch (e) {
        debugPrint('Error loading genders: $e');
      }

      // 2. Fetch dynamic physically challenged options
      try {
        final pcRes = await PhysicallyChallengedApi.fetchOptions();
        if (pcRes['status'] == 'success' || pcRes['error'] == false) {
          final List<dynamic>? list = pcRes['data'];
          if (list != null) {
            final List<Map<String, dynamic>> parsedOptions = [];
            for (var item in list) {
              if (item is Map) {
                String name = '';
                String value = '';
                item.forEach((k, v) {
                  if (k.toString().toLowerCase().contains('name'))
                    name = v.toString();
                  if (k.toString().toLowerCase().contains('value') ||
                      k.toString().toLowerCase() == 'id')
                    value = v.toString();
                });
                if (name.isEmpty && item.values.isNotEmpty)
                  name = item.values.first.toString();
                if (value.isEmpty && item.values.length > 1)
                  value = item.values.elementAt(1).toString();
                if (name.isNotEmpty) {
                  parsedOptions.add({
                    'name': name,
                    'value': value.isNotEmpty ? value : name,
                  });
                }
              }
            }
            if (parsedOptions.isNotEmpty) {
              setState(() {
                _physicallyChallengedOptions = parsedOptions;
              });
            }
          }
        }
      } catch (e) {
        debugPrint('Error loading physically challenged options: $e');
      }

      // 3. Fetch user profile details from select API
      try {
        final profileRes = await ProfileSelectApi.fetchProfile(userId: userId);

        if (profileRes['status'] == 'success' || profileRes['error'] == false) {
          final data = profileRes['data'];
          if (data != null && data is Map<String, dynamic>) {
            setState(() {
              _nameController.text =
                  data['name']?.toString() ?? _nameController.text;
              _emailController.text =
                  data['email']?.toString() ?? _emailController.text;

              final String dobVal = data['dob']?.toString() ?? '';
              if (dobVal.isNotEmpty) {
                _dobController.text = dobVal;
              }

              _condType = data['cond_type']?.toString() ?? _condType;
              _affectArea = data['affect_area']?.toString() ?? _affectArea;
              _profileImageUrl =
                  (data['photo'] ?? data['profile_image'])?.toString() ??
                      _profileImageUrl;

              // Map Gender selection
              final String? apiGender = data['gender']?.toString();
              if (apiGender != null && apiGender.isNotEmpty) {
                for (var opt in _genderOptions) {
                  if (opt['value']?.toString() == apiGender ||
                      opt['name']?.toString().toLowerCase() ==
                          apiGender.toLowerCase()) {
                    _selectedGender = opt['name'] ?? '';
                    break;
                  }
                }
              }

              // Map Physical Challenge selection
              final String? apiPC = data['physical_challenge']?.toString();
              if (apiPC != null && apiPC.isNotEmpty) {
                for (var opt in _physicallyChallengedOptions) {
                  if (opt['value']?.toString() == apiPC ||
                      opt['name']?.toString().toLowerCase() ==
                          apiPC.toLowerCase()) {
                    _isPhysicallyChallenged = opt['name'] ?? 'No';
                    break;
                  }
                }
              }
            });
          }
        }
      } catch (e) {
        debugPrint('Error fetching profile: $e');
      }
    } catch (e) {
      debugPrint('Error in _fetchData: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 100,
      );
      if (pickedFile != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Crop Profile Image',
                toolbarColor: AppColors.primary,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: false,
                cropStyle: CropStyle.circle,
                aspectRatioPresets: [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9
                ]),
            IOSUiSettings(
              title: 'Crop Profile Image',
              cropStyle: CropStyle.circle,
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ],
            ),
          ],
        );
        if (croppedFile != null) {
          setState(() {
            _profileImage = File(croppedFile.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitProfile() async {
    if (_isLoading) return;
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _selectedGender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all mandatory fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (route) => false,
          );
        }
        return;
      }
      final cachedMobile = prefs.getString('mobile') ?? '';

      // Map gender name to value
      String genderVal = '';
      for (var opt in _genderOptions) {
        if (opt['name'] == _selectedGender) {
          genderVal = opt['value']?.toString() ?? '';
          break;
        }
      }
      if (genderVal.isEmpty) genderVal = _selectedGender;

      // Map physical challenge name to value
      String pcVal = '';
      for (var opt in _physicallyChallengedOptions) {
        if (opt['name'] == _isPhysicallyChallenged) {
          pcVal = opt['value']?.toString() ?? '';
          break;
        }
      }
      if (pcVal.isEmpty) pcVal = _isPhysicallyChallenged;

      final response = await ProfileUpdateApi.updateProfile(
        userId: userId,
        name: _nameController.text.trim(),
        mobile: cachedMobile,
        email: _emailController.text.trim(),
        dob: _dobController.text.trim(),
        gender: genderVal,
        physicalChallenge: pcVal,
        condType: _condType,
        affectArea: _affectArea,
        profileImage: _profileImage,
      );

      if (response['status'] == 'success' || response['error'] == false) {
        await prefs.setString('name', _nameController.text.trim());
        await prefs.setString('email', _emailController.text.trim());
        await prefs.setString('gender', _selectedGender);
        await prefs.setString('dob', _dobController.text.trim());
        await prefs.setString('physical_challenge', _isPhysicallyChallenged);
        await prefs.setString('cond_type', _condType);
        await prefs.setString('affect_area', _affectArea);

        if (_profileImage != null) {
          await prefs.setString('profile_pic_path', _profileImage!.path);
        }

        final data = response['data'];
        if (data != null && data is Map) {
          final imageUrl = data['photo'] ?? data['profile_image'];
          if (imageUrl != null) {
            await prefs.setString('profile_image_url', imageUrl.toString());
          }
        }

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QualificationScreen()),
        );
      } else {
        final String errorMsg =
            response['message'] ?? 'Failed to update profile';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint('Submit profile error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField(
      String label,
      String hint,
      TextEditingController controller,
      Color textColor,
      Color subtitleColor,
      Color borderColor, {
        Widget? suffixIcon,
        bool readOnly = false,
        VoidCallback? onTap,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 0.035.sw,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: 0.02.sw),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(0.02.sw),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(
                color: subtitleColor,
                fontSize: 0.035.sw,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 0.04.sw,
                vertical: 0.035.sw,
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderButton(String gender, double screenWidth, Color cardBg) {
    bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 0.06.sw,
          vertical: 0.02.sw,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : cardBg,
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(0.06.sw),
        ),
        child: Text(
          gender,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontSize: 0.035.sw,
          ),
        ),
      ),
    );
  }

  Widget _buildChallengedButton(String option, double screenWidth, Color cardBg) {
    bool isSelected = _isPhysicallyChallenged == option;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPhysicallyChallenged = option;
        });

        String val = '';
        for (var opt in _physicallyChallengedOptions) {
          if (opt['name'] == option) {
            val = opt['value']?.toString() ?? '';
            break;
          }
        }

        if (val == '1') {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => DisabilityPopup(
              initialCondition: _condType.isEmpty ? 'Select here' : _condType,
              initialArea: _affectArea.isEmpty ? 'Select here' : _affectArea,
            ),
          ).then((result) {
            if (result != null && result is Map<String, String>) {
              setState(() {
                _isPhysicallyChallenged = option;
                _condType = result['cond_type'] ?? '';
                _affectArea = result['affect_area'] ?? '';
              });
            } else {
              if (_condType.isEmpty || _condType == 'Select here') {
                String noName = 'No';
                for (var opt in _physicallyChallengedOptions) {
                  if (opt['value'] == '2') {
                    noName = opt['name'] ?? 'No';
                    break;
                  }
                }
                setState(() {
                  _isPhysicallyChallenged = noName;
                });
              }
            }
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 0.06.sw,
          vertical: 0.02.sw,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : cardBg,
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(0.06.sw),
        ),
        child: Text(
          option,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontSize: 0.035.sw,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear(); // Clear persistent login
            if (!context.mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
          padding: EdgeInsets.all(0.05.sw),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Box
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(0.05.sw),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7EFFF),
                  borderRadius: BorderRadius.circular(0.04.sw),
                ),
                child: Column(
                  children: [
                    Text(
                      "Let's Build Your Profile !",
                      style: TextStyle(
                        fontSize: 0.045.sw,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 0.01.sh),
                    Text(
                      "Enter your details, so that employers can find you easily to a job.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 0.032.sw,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 0.03.sh),

              // Profile Photo placeholder
              Center(
                child: GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Column(
                    children: [
                      Container(
                        width: 0.25.sw,
                        height: 0.25.sw,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                          image: _profileImage != null
                              ? DecorationImage(
                            image: FileImage(_profileImage!),
                            fit: BoxFit.cover,
                          )
                              : (_profileImageUrl != null &&
                              _profileImageUrl!.isNotEmpty
                              ? DecorationImage(
                            image: NetworkImage(
                              _profileImageUrl!.startsWith('http')
                                  ? _profileImageUrl!
                                  : (_profileImageUrl!.startsWith(
                                '/',
                              )
                                  ? 'https://truejobs.in$_profileImageUrl'
                                  : 'https://truejobs.in/$_profileImageUrl'),
                            ),
                            fit: BoxFit.cover,
                          )
                              : null),
                        ),
                        child:
                        _profileImage == null &&
                            (_profileImageUrl == null ||
                                _profileImageUrl!.isEmpty)
                            ? Icon(
                          Icons.person,
                          size: 0.15.sw,
                          color: Colors.white,
                        )
                            : null,
                      ),
                      SizedBox(height: 0.01.sh),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: AppColors.primary,
                            size: 0.04.sw,
                          ),
                          SizedBox(width: 0.01.sw),
                          Text(
                            _profileImage != null
                                ? 'Change Photo'
                                : 'Add Photo',
                            style: TextStyle(
                              fontSize: 0.035.sw,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 0.03.sh),

              // Name
              _buildTextField('Name', 'Enter Your Full Name', _nameController, textColor, subtitleColor, borderColor),
              SizedBox(height: 0.02.sh),

              // Email
              _buildTextField(
                'Email address',
                'Enter Your Email Address',
                _emailController,
                textColor,
                subtitleColor,
                borderColor,
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 0.01.sw,
                  bottom: 0.02.sh,
                ),
                child: Text(
                  "We 'll send updates to this email",
                  style: TextStyle(
                    fontSize: 0.03.sw,
                    color: subtitleColor,
                  ),
                ),
              ),

              // Date of Birth
              _buildTextField(
                'Date of Birth',
                'DD/MM/YYYY',
                _dobController,
                textColor,
                subtitleColor,
                borderColor,
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                            onSurface: textColor,
                            surface: bgColor,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    String formattedDate =
                        "${pickedDate.day.toString().padLeft(2, '0')}/"
                        "${pickedDate.month.toString().padLeft(2, '0')}/"
                        "${pickedDate.year}";
                    setState(() {
                      _dobController.text = formattedDate;
                    });
                  }
                },
                suffixIcon: Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.primary,
                  size: 0.05.sw,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 0.01.sw,
                  bottom: 0.02.sh,
                ),
                child: Text(
                  "As per official documents",
                  style: TextStyle(
                    fontSize: 0.03.sw,
                    color: subtitleColor,
                  ),
                ),
              ),

              // Gender
              Text(
                'Select your Gender',
                style: TextStyle(
                  fontSize: 0.035.sw,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 0.02.sw),
              Row(
                children: _genderOptions.map((opt) {
                  final name = opt['name'] ?? '';
                  final idx = _genderOptions.indexOf(opt);
                  return Row(
                    children: [
                      if (idx > 0) SizedBox(width: 0.03.sw),
                      _buildGenderButton(name, screenWidth, cardBg),
                    ],
                  );
                }).toList(),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 0.02.sw,
                  bottom: 0.02.sh,
                ),
                child: Text(
                  "As per official documents",
                  style: TextStyle(
                    fontSize: 0.03.sw,
                    color: subtitleColor,
                  ),
                ),
              ),

              // Physically Challenged
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Physically Challenged',
                    style: TextStyle(
                      fontSize: 0.035.sw,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Row(
                    children: _physicallyChallengedOptions.map((opt) {
                      final name = opt['name'] ?? '';
                      final idx = _physicallyChallengedOptions.indexOf(opt);
                      return Row(
                        children: [
                          if (idx > 0) SizedBox(width: 0.03.sw),
                          _buildChallengedButton(name, screenWidth, cardBg),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),

              SizedBox(height: 0.04.sh),

              CustomNextButton(onPressed: _submitProfile),
              SizedBox(height: 0.02.sh),
            ],
          ),
        ),
      ),
    );
  }
}
