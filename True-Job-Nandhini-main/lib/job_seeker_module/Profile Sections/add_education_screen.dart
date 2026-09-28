import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truejobs/services/api/board_api.dart';
import 'package:truejobs/services/api/stream_api.dart';
import 'package:truejobs/services/api/ug_course_api.dart';
import 'package:truejobs/services/api/pg_course_api.dart';
import 'package:truejobs/services/api/diploma_api.dart';
import 'package:truejobs/services/api/iti_trade_api.dart';
import 'package:truejobs/services/api/educational_select_api.dart';
import 'package:truejobs/services/api/educational_insert_api.dart';
import '../../constants/app_colors.dart';

/// Model to hold one saved education entry
class EducationEntry {
  final String type; // '10th', '12th', 'UG', 'PG', 'Diploma', 'ITI'
  final Map<String, String> details;

  EducationEntry({required this.type, required this.details});

  /// Returns a short display label for the card
  String get displayTitle {
    switch (type) {
      case '10th':
        return '10th Standard';
      case '12th':
        return '12th Standard';
      case 'UG':
        return details['courseName'] ?? 'Under Graduate';
      case 'PG':
        return details['courseName'] ?? 'Post Graduate';
      case 'Diploma':
        return details['courseName'] ?? 'Diploma';
      case 'ITI':
        return details['tradeName'] ?? 'ITI';
      default:
        return type;
    }
  }

  String get displaySubtitle {
    switch (type) {
      case '10th':
        return details['schoolName'] ?? '';
      case '12th':
        return details['schoolName'] ?? '';
      case 'UG':
      case 'PG':
        return details['collegeName'] ?? '';
      case 'Diploma':
        return details['instituteName'] ?? '';
      case 'ITI':
        return details['instituteName'] ?? '';
      default:
        return '';
    }
  }
}

class AddEducationScreen extends StatefulWidget {
  final EducationEntry? existingEntry; // non-null when editing

  const AddEducationScreen({super.key, this.existingEntry});

  @override
  State<AddEducationScreen> createState() => _AddEducationScreenState();
}

class _AddEducationScreenState extends State<AddEducationScreen> {
  String? _selectedType; // '10th','12th','UG','PG','Diploma','ITI'

  // ── Metadata API Lookups ──────────────────────────────────────
  List<String> _boards = ['CBSE', 'ICSE', 'State Board', 'Others'];
  final Map<String, String> _boardMap = {};
  List<String> _streams = ['Science', 'Commerce', 'Arts', 'Others'];
  final Map<String, String> _streamMap = {};
  List<String> _ugCourses = [
    'B.Tech / B.E.',
    'B.Ed',
    'B.Pharma',
    'BHM / BHMCT',
  ];
  final Map<String, String> _ugCourseMap = {};
  List<String> _pgCourses = ['M.Tech / M.E.', 'MBA', 'M.Pharma', 'M.Ed'];
  final Map<String, String> _pgCourseMap = {};
  List<String> _diplomas = [
    'Mechanical',
    'Electrical',
    'Civil',
    'Computer Science',
  ];
  final Map<String, String> _diplomaMap = {};
  List<String> _trades = ['Electrician', 'Fitter', 'Welder', 'Mechanic'];
  final Map<String, String> _tradeMap = {};

  bool _isMetadataLoading = false;

  // ── 10th controllers ──────────────────────────────────────────
  final _tenth_school = TextEditingController();
  String? _tenth_board; // 'CBSE','ICSE','State Board','Others'
  final _tenth_passing = TextEditingController();
  final _tenth_marks = TextEditingController();

  // ── 12th controllers ──────────────────────────────────────────
  final _twelfth_school = TextEditingController();
  String? _twelfth_board;
  String? _twelfth_stream; // 'Science','Commerce','Arts','Others'
  final _twelfth_passing = TextEditingController();
  final _twelfth_marks = TextEditingController();

  // ── UG controllers ────────────────────────────────────────────
  final _ug_course = TextEditingController();
  final _ug_specialization = TextEditingController();
  final _ug_college = TextEditingController();
  final _ug_university = TextEditingController();
  final _ug_duration = TextEditingController();
  final _ug_passing = TextEditingController();
  final _ug_marks = TextEditingController();

  // ── PG controllers ────────────────────────────────────────────
  final _pg_course = TextEditingController();
  final _pg_specialization = TextEditingController();
  final _pg_college = TextEditingController();
  final _pg_university = TextEditingController();
  final _pg_duration = TextEditingController();
  final _pg_passing = TextEditingController();
  final _pg_marks = TextEditingController();

  // ── Diploma controllers ───────────────────────────────────────
  final _dip_course = TextEditingController();
  final _dip_institute = TextEditingController();
  final _dip_board = TextEditingController();
  final _dip_duration = TextEditingController();
  final _dip_passing = TextEditingController();
  final _dip_marks = TextEditingController();

  // ── ITI controllers ───────────────────────────────────────────
  final _iti_trade = TextEditingController();
  final _iti_specialization = TextEditingController();
  String? _iti_board; // 'NCVT','SCVT'
  final _iti_institute = TextEditingController();
  final _iti_duration = TextEditingController();
  final _iti_passing = TextEditingController();
  final _iti_marks = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMetadata();
    if (widget.existingEntry != null) {
      _prefillFromEntry(widget.existingEntry!);
    }
  }

  Future<void> _loadMetadata() async {
    setState(() => _isMetadataLoading = true);
    try {
      // 1. Boards
      final boardRes = await BoardApi.fetchBoards();
      if (boardRes['error'] == false || boardRes['status'] == 'success') {
        final List<dynamic>? list = boardRes['data'];
        if (list != null && list.isNotEmpty) {
          final List<String> fetched = [];
          final Map<String, String> bMap = {};
          for (var item in list) {
            final String name = item['name']?.toString() ?? '';
            final String val =
                item['value']?.toString() ?? item['id']?.toString() ?? '';
            if (name.isNotEmpty) {
              fetched.add(name);
              bMap[name] = val;
            }
          }
          if (mounted && fetched.isNotEmpty) {
            setState(() {
              _boards = fetched;
              _boardMap.clear();
              _boardMap.addAll(bMap);
            });
          }
        }
      }

      // 2. Streams
      final streamRes = await StreamApi.fetchStreams();
      if (streamRes['error'] == false || streamRes['status'] == 'success') {
        final List<dynamic>? list = streamRes['data'];
        if (list != null && list.isNotEmpty) {
          final List<String> fetched = [];
          final Map<String, String> sMap = {};
          for (var item in list) {
            final String name = item['name']?.toString() ?? '';
            final String val =
                item['value']?.toString() ?? item['id']?.toString() ?? '';
            if (name.isNotEmpty) {
              fetched.add(name);
              sMap[name] = val;
            }
          }
          if (mounted && fetched.isNotEmpty) {
            setState(() {
              _streams = fetched;
              _streamMap.clear();
              _streamMap.addAll(sMap);
            });
          }
        }
      }

      // 3. UG Courses
      final ugRes = await UgCourseApi.fetchCourses();
      if (ugRes['error'] == false || ugRes['status'] == 'success') {
        final List<dynamic>? list = ugRes['data'];
        if (list != null && list.isNotEmpty) {
          final List<String> fetched = [];
          final Map<String, String> cMap = {};
          for (var item in list) {
            final String name = item['name']?.toString() ?? '';
            final String val =
                item['value']?.toString() ?? item['id']?.toString() ?? '';
            if (name.isNotEmpty) {
              fetched.add(name);
              cMap[name] = val;
            }
          }
          if (mounted && fetched.isNotEmpty) {
            setState(() {
              _ugCourses = fetched;
              _ugCourseMap.clear();
              _ugCourseMap.addAll(cMap);
            });
          }
        }
      }

      // 4. PG Courses
      final pgRes = await PgCourseApi.fetchCourses();
      if (pgRes['error'] == false || pgRes['status'] == 'success') {
        final List<dynamic>? list = pgRes['data'];
        if (list != null && list.isNotEmpty) {
          final List<String> fetched = [];
          final Map<String, String> cMap = {};
          for (var item in list) {
            final String name = item['name']?.toString() ?? '';
            final String val =
                item['value']?.toString() ?? item['id']?.toString() ?? '';
            if (name.isNotEmpty) {
              fetched.add(name);
              cMap[name] = val;
            }
          }
          if (mounted && fetched.isNotEmpty) {
            setState(() {
              _pgCourses = fetched;
              _pgCourseMap.clear();
              _pgCourseMap.addAll(cMap);
            });
          }
        }
      }

      // 5. Diplomas
      final dipRes = await DiplomaApi.fetchCourses();
      if (dipRes['error'] == false || dipRes['status'] == 'success') {
        final List<dynamic>? list = dipRes['data'];
        if (list != null && list.isNotEmpty) {
          final List<String> fetched = [];
          final Map<String, String> dMap = {};
          for (var item in list) {
            final String name = item['name']?.toString() ?? '';
            final String val =
                item['value']?.toString() ?? item['id']?.toString() ?? '';
            if (name.isNotEmpty) {
              fetched.add(name);
              dMap[name] = val;
            }
          }
          if (mounted && fetched.isNotEmpty) {
            setState(() {
              _diplomas = fetched;
              _diplomaMap.clear();
              _diplomaMap.addAll(dMap);
            });
          }
        }
      }

      // 6. ITI Trades
      final tradeRes = await ItiTradeApi.fetchTrades();
      if (tradeRes['error'] == false || tradeRes['status'] == 'success') {
        final List<dynamic>? list = tradeRes['data'];
        if (list != null && list.isNotEmpty) {
          final List<String> fetched = [];
          final Map<String, String> tMap = {};
          for (var item in list) {
            final String name = item['name']?.toString() ?? '';
            final String val =
                item['value']?.toString() ?? item['id']?.toString() ?? '';
            if (name.isNotEmpty) {
              fetched.add(name);
              tMap[name] = val;
            }
          }
          if (mounted && fetched.isNotEmpty) {
            setState(() {
              _trades = fetched;
              _tradeMap.clear();
              _tradeMap.addAll(tMap);
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading metadata in AddEducationScreen: $e');
    } finally {
      if (mounted) {
        setState(() => _isMetadataLoading = false);
      }
    }
  }

  void _prefillFromEntry(EducationEntry e) {
    _selectedType = e.type;
    final d = e.details;
    switch (e.type) {
      case '10th':
        _tenth_school.text = d['schoolName'] ?? '';
        _tenth_board = d['board'];
        _tenth_passing.text = d['passingYear'] ?? '';
        _tenth_marks.text = d['marks'] ?? '';
        break;
      case '12th':
        _twelfth_school.text = d['schoolName'] ?? '';
        _twelfth_board = d['board'];
        _twelfth_stream = d['stream'];
        _twelfth_passing.text = d['passingYear'] ?? '';
        _twelfth_marks.text = d['marks'] ?? '';
        break;
      case 'UG':
        _ug_course.text = d['courseName'] ?? '';
        _ug_specialization.text = d['specialization'] ?? '';
        _ug_college.text = d['collegeName'] ?? '';
        _ug_university.text = d['university'] ?? '';
        _ug_duration.text = d['duration'] ?? '';
        _ug_passing.text = d['passingYear'] ?? '';
        _ug_marks.text = d['marks'] ?? '';
        break;
      case 'PG':
        _pg_course.text = d['courseName'] ?? '';
        _pg_specialization.text = d['specialization'] ?? '';
        _pg_college.text = d['collegeName'] ?? '';
        _pg_university.text = d['university'] ?? '';
        _pg_duration.text = d['duration'] ?? '';
        _pg_passing.text = d['passingYear'] ?? '';
        _pg_marks.text = d['marks'] ?? '';
        break;
      case 'Diploma':
        _dip_course.text = d['courseName'] ?? '';
        _dip_institute.text = d['instituteName'] ?? '';
        _dip_board.text = d['board'] ?? '';
        _dip_duration.text = d['duration'] ?? '';
        _dip_passing.text = d['passingYear'] ?? '';
        _dip_marks.text = d['marks'] ?? '';
        break;
      case 'ITI':
        _iti_trade.text = d['tradeName'] ?? '';
        _iti_specialization.text = d['specialization'] ?? '';
        _iti_board = d['board'];
        _iti_institute.text = d['instituteName'] ?? '';
        _iti_duration.text = d['duration'] ?? '';
        _iti_passing.text = d['passingYear'] ?? '';
        _iti_marks.text = d['marks'] ?? '';
        break;
    }
  }

  @override
  void dispose() {
    _tenth_school.dispose();
    _tenth_passing.dispose();
    _tenth_marks.dispose();
    _twelfth_school.dispose();
    _twelfth_passing.dispose();
    _twelfth_marks.dispose();
    _ug_course.dispose();
    _ug_specialization.dispose();
    _ug_college.dispose();
    _ug_university.dispose();
    _ug_duration.dispose();
    _ug_passing.dispose();
    _ug_marks.dispose();
    _pg_course.dispose();
    _pg_specialization.dispose();
    _pg_college.dispose();
    _pg_university.dispose();
    _pg_duration.dispose();
    _pg_passing.dispose();
    _pg_marks.dispose();
    _dip_course.dispose();
    _dip_institute.dispose();
    _dip_board.dispose();
    _dip_duration.dispose();
    _dip_passing.dispose();
    _dip_marks.dispose();
    _iti_trade.dispose();
    _iti_specialization.dispose();
    _iti_institute.dispose();
    _iti_duration.dispose();
    _iti_passing.dispose();
    _iti_marks.dispose();
    super.dispose();
  }

  bool get _canSave {
    if (_selectedType == null) return false;
    switch (_selectedType) {
      case '10th':
        return _tenth_school.text.trim().isNotEmpty &&
            _tenth_board != null &&
            _tenth_passing.text.trim().isNotEmpty &&
            _tenth_marks.text.trim().isNotEmpty;
      case '12th':
        return _twelfth_school.text.trim().isNotEmpty &&
            _twelfth_board != null &&
            _twelfth_stream != null &&
            _twelfth_passing.text.trim().isNotEmpty &&
            _twelfth_marks.text.trim().isNotEmpty;
      case 'UG':
        return _ug_course.text.trim().isNotEmpty &&
            _ug_college.text.trim().isNotEmpty &&
            _ug_university.text.trim().isNotEmpty &&
            _ug_duration.text.trim().isNotEmpty &&
            _ug_passing.text.trim().isNotEmpty &&
            _ug_marks.text.trim().isNotEmpty;
      case 'PG':
        return _pg_course.text.trim().isNotEmpty &&
            _pg_college.text.trim().isNotEmpty &&
            _pg_university.text.trim().isNotEmpty &&
            _pg_duration.text.trim().isNotEmpty &&
            _pg_passing.text.trim().isNotEmpty &&
            _pg_marks.text.trim().isNotEmpty;
      case 'Diploma':
        return _dip_course.text.trim().isNotEmpty &&
            _dip_institute.text.trim().isNotEmpty &&
            _dip_board.text.trim().isNotEmpty &&
            _dip_duration.text.trim().isNotEmpty &&
            _dip_passing.text.trim().isNotEmpty &&
            _dip_marks.text.trim().isNotEmpty;
      case 'ITI':
        return _iti_trade.text.trim().isNotEmpty &&
            _iti_board != null &&
            _iti_institute.text.trim().isNotEmpty &&
            _iti_duration.text.trim().isNotEmpty &&
            _iti_passing.text.trim().isNotEmpty &&
            _iti_marks.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _onSave() async {
    if (!_canSave) return;

    setState(() {
      _isMetadataLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID not found. Please log in again.'),
          ),
        );
        return;
      }

      final selectRes = await EducationalSelectApi.fetchEducationalDetails(
        name: userId.toString(),
      );

      String highQualify = '';
      final Map<String, Map<String, String>> savedDetails = {};

      if (selectRes['error'] == false || selectRes['status'] == 'success') {
        final data = selectRes['data'];
        if (data != null && data is Map<String, dynamic>) {
          highQualify = data['high_qualify']?.toString() ?? '';

          final String tBoard = data['10th_board']?.toString() ?? '';
          if (tBoard.isNotEmpty && tBoard != '0') {
            savedDetails['1'] = {
              'board': tBoard,
              'school': data['10th_schl_name']?.toString() ?? '',
              'year': data['10th_year_complete']?.toString() ?? '',
              'percentage': data['10th_percent_cgpa']?.toString() ?? '',
            };
          }
          final String twBoard = data['12th_board']?.toString() ?? '';
          if (twBoard.isNotEmpty && twBoard != '0') {
            savedDetails['2'] = {
              'board': twBoard,
              'stream': data['12th_stream']?.toString() ?? '',
              'school': data['12th_schl_name']?.toString() ?? '',
              'year': data['12th_year_complete']?.toString() ?? '',
              'percentage': data['12th_percent_cgpa']?.toString() ?? '',
            };
          }
          final String ugCourse = data['ug_course']?.toString() ?? '';
          if (ugCourse.isNotEmpty && ugCourse != '0') {
            savedDetails['3'] = {
              'course': ugCourse,
              'specialization': data['ug_specialization']?.toString() ?? '',
              'institute': data['ug_college']?.toString() ?? '',
              'university': data['ug_university']?.toString() ?? '',
              'duration': data['ug_duration']?.toString() ?? '',
              'year': data['ug_year_complete']?.toString() ?? '',
              'percentage': data['ug_percent_cgpa']?.toString() ?? '',
            };
          }
          final String pgCourse = data['pg_course']?.toString() ?? '';
          if (pgCourse.isNotEmpty && pgCourse != '0') {
            savedDetails['4'] = {
              'course': pgCourse,
              'specialization': data['pg_specialization']?.toString() ?? '',
              'institute': data['pg_college']?.toString() ?? '',
              'university': data['pg_university']?.toString() ?? '',
              'duration': data['pg_duration']?.toString() ?? '',
              'year': data['pg_year_complete']?.toString() ?? '',
              'percentage': data['pg_percent_cgpa']?.toString() ?? '',
            };
          }
          final String dip = data['diploma']?.toString() ?? '';
          if (dip.isNotEmpty && dip != '0') {
            savedDetails['5'] = {
              'diploma': dip,
              'institute': data['dip_institute']?.toString() ?? '',
              'board': data['dip_board_university']?.toString() ?? '',
              'duration': data['dip_duration']?.toString() ?? '',
              'year': data['dip_year_complete']?.toString() ?? '',
              'percentage': data['dip_percent']?.toString() ?? '',
            };
          }
          final String iti = data['iti_trade']?.toString() ?? '';
          if (iti.isNotEmpty && iti != '0') {
            savedDetails['6'] = {
              'trade': iti,
              'specialization': data['iti_specialization']?.toString() ?? '',
              'institute': data['iti_institute']?.toString() ?? '',
              'boardType': data['iti_board']?.toString() == '1'
                  ? 'NCVT'
                  : (data['iti_board']?.toString() == '2' ? 'SCVT' : ''),
              'duration': data['iti_duration']?.toString() ?? '',
              'year': data['iti_year_complete']?.toString() ?? '',
              'percentage': data['iti_percent']?.toString() ?? '',
            };
          }
        }
      }

      String catKey = '';
      Map<String, String> catData = {};

      if (_selectedType == '10th') {
        catKey = '1';
        catData = {
          'board': _boardMap[_tenth_board] ?? _tenth_board ?? '',
          'school': _tenth_school.text.trim(),
          'year': _tenth_passing.text.trim(),
          'percentage': _tenth_marks.text.trim(),
        };
      } else if (_selectedType == '12th') {
        catKey = '2';
        catData = {
          'board': _boardMap[_twelfth_board] ?? _twelfth_board ?? '',
          'stream': _streamMap[_twelfth_stream] ?? _twelfth_stream ?? '',
          'school': _twelfth_school.text.trim(),
          'year': _twelfth_passing.text.trim(),
          'percentage': _twelfth_marks.text.trim(),
        };
      } else if (_selectedType == 'UG') {
        catKey = '3';
        catData = {
          'course':
              _ugCourseMap[_ug_course.text.trim()] ?? _ug_course.text.trim(),
          'specialization': _ug_specialization.text.trim(),
          'institute': _ug_college.text.trim(),
          'university': _ug_university.text.trim(),
          'duration': _ug_duration.text.trim(),
          'year': _ug_passing.text.trim(),
          'percentage': _ug_marks.text.trim(),
        };
      } else if (_selectedType == 'PG') {
        catKey = '4';
        catData = {
          'course':
              _pgCourseMap[_pg_course.text.trim()] ?? _pg_course.text.trim(),
          'specialization': _pg_specialization.text.trim(),
          'institute': _pg_college.text.trim(),
          'university': _pg_university.text.trim(),
          'duration': _pg_duration.text.trim(),
          'year': _pg_passing.text.trim(),
          'percentage': _pg_marks.text.trim(),
        };
      } else if (_selectedType == 'Diploma') {
        catKey = '5';
        catData = {
          'diploma':
              _diplomaMap[_dip_course.text.trim()] ?? _dip_course.text.trim(),
          'institute': _dip_institute.text.trim(),
          'board': _dip_board.text.trim(),
          'duration': _dip_duration.text.trim(),
          'year': _dip_passing.text.trim(),
          'percentage': _dip_marks.text.trim(),
        };
      } else if (_selectedType == 'ITI') {
        catKey = '6';
        catData = {
          'trade': _tradeMap[_iti_trade.text.trim()] ?? _iti_trade.text.trim(),
          'specialization': _iti_specialization.text.trim(),
          'institute': _iti_institute.text.trim(),
          'boardType': _iti_board ?? '',
          'duration': _iti_duration.text.trim(),
          'year': _iti_passing.text.trim(),
          'percentage': _iti_marks.text.trim(),
        };
      }

      savedDetails[catKey] = catData;

      if (savedDetails.containsKey('4')) {
        highQualify = '4';
      } else if (savedDetails.containsKey('3')) {
        highQualify = '3';
      } else if (savedDetails.containsKey('5')) {
        highQualify = '5';
      } else if (savedDetails.containsKey('6')) {
        highQualify = '6';
      } else if (savedDetails.containsKey('2')) {
        highQualify = '2';
      } else if (savedDetails.containsKey('1')) {
        highQualify = '1';
      } else {
        highQualify = '0';
      }

      final updateRes = await EducationalInsertApi.insertEducationalDetails(
        name: userId.toString(),
        highQualify: highQualify,
        savedDetails: savedDetails,
      );

      if (updateRes['error'] == false || updateRes['status'] == 'success') {
        final entry = _buildEntry();
        if (mounted) {
          Navigator.pop(context, entry);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to save details: ${updateRes['message'] ?? 'Unknown error'}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving educational details: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isMetadataLoading = false;
        });
      }
    }
  }

  EducationEntry _buildEntry() {
    switch (_selectedType!) {
      case '10th':
        return EducationEntry(
          type: '10th',
          details: {
            'schoolName': _tenth_school.text.trim(),
            'board': _tenth_board ?? '',
            'passingYear': _tenth_passing.text.trim(),
            'marks': _tenth_marks.text.trim(),
          },
        );
      case '12th':
        return EducationEntry(
          type: '12th',
          details: {
            'schoolName': _twelfth_school.text.trim(),
            'board': _twelfth_board ?? '',
            'stream': _twelfth_stream ?? '',
            'passingYear': _twelfth_passing.text.trim(),
            'marks': _twelfth_marks.text.trim(),
          },
        );
      case 'UG':
        return EducationEntry(
          type: 'UG',
          details: {
            'courseName': _ug_course.text.trim(),
            'specialization': _ug_specialization.text.trim(),
            'collegeName': _ug_college.text.trim(),
            'university': _ug_university.text.trim(),
            'marks': _ug_marks.text.trim(),
            'passingYear': _ug_passing.text.trim(),
            'duration': _ug_duration.text.trim(),
          },
        );
      case 'PG':
        return EducationEntry(
          type: 'PG',
          details: {
            'courseName': _pg_course.text.trim(),
            'specialization': _pg_specialization.text.trim(),
            'collegeName': _pg_college.text.trim(),
            'university': _pg_university.text.trim(),
            'marks': _pg_marks.text.trim(),
            'passingYear': _pg_passing.text.trim(),
            'duration': _pg_duration.text.trim(),
          },
        );
      case 'Diploma':
        return EducationEntry(
          type: 'Diploma',
          details: {
            'courseName': _dip_course.text.trim(),
            'instituteName': _dip_institute.text.trim(),
            'board': _dip_board.text.trim(),
            'marks': _dip_marks.text.trim(),
            'passingYear': _dip_passing.text.trim(),
            'duration': _dip_duration.text.trim(),
          },
        );
      case 'ITI':
      default:
        return EducationEntry(
          type: 'ITI',
          details: {
            'tradeName': _iti_trade.text.trim(),
            'specialization': _iti_specialization.text.trim(),
            'board': _iti_board ?? '',
            'instituteName': _iti_institute.text.trim(),
            'duration': _iti_duration.text.trim(),
            'passingYear': _iti_passing.text.trim(),
            'marks': _iti_marks.text.trim(),
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double sw = size.width;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color borderColor = AppColors.dynamicBorder;
    final Color cardBg = AppColors.dynamicCardBg;

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
          'Education',
          style: TextStyle(
            color: textColor,
            fontSize: sw * 0.05,
            fontWeight: FontWeight.w600,
          ),
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: _isMetadataLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: sw * 0.05,
            right: sw * 0.05,
            top: sw * 0.02,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: sw * 0.02),
                    Text(
                      'Adding your educational details help recruiters know your value as a potential candidate',
                      style: TextStyle(
                        fontSize: sw * 0.038,
                        color: AppColors.primary,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: sw * 0.08),

                    // ── Qualification type selector ───────────────
                    Text(
                      'Highest qualification/Degree pursuing',
                      style: TextStyle(
                        fontSize: sw * 0.04,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: sw * 0.04),
                    _buildTypeChips(sw, textColor, borderColor, cardBg),

                    // ── Detail form for selected type ─────────────
                    if (_selectedType != null) ...[
                      SizedBox(height: sw * 0.06),
                      _buildDetailForm(sw),
                    ],
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
            color: bgColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                    padding: EdgeInsets.symmetric(
                      vertical: sw * 0.04,
                    ),
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
                    padding: EdgeInsets.symmetric(
                      vertical: sw * 0.04,
                    ),
                    backgroundColor: _canSave
                        ? AppColors.primary
                        : const Color(0xFFE0E0E0),
                    foregroundColor: _canSave
                        ? Colors.white
                        : const Color(0xFFAAAAAA),
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

  // ── Type chip row ──────────────────────────────────────────────────────────
  Widget _buildTypeChips(double sw, Color textColor, Color borderColor, Color cardBg) {
    const types = ['10th', '12th', 'UG', 'PG', 'Diploma', 'ITI'];
    return Wrap(
      spacing: sw * 0.03,
      runSpacing: sw * 0.025,
      children: types.map((t) {
        final selected = _selectedType == t;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = t),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.045,
              vertical: sw * 0.02,
            ),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : cardBg,
              border: Border.all(
                color: selected ? AppColors.primary : borderColor,
              ),
              borderRadius: BorderRadius.circular(sw * 0.07),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t,
                  style: TextStyle(
                    fontSize: sw * 0.037,
                    color: selected ? Colors.white : textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // if (selected) ...[
                //   SizedBox(width: sw * 0.02),
                //   Icon(Icons.close, color: Colors.white, size: sw * 0.038),
                // ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Detail form dispatcher ─────────────────────────────────────────────────
  Widget _buildDetailForm(double sw) {
    switch (_selectedType) {
      case '10th':
        return _build10thForm(sw);
      case '12th':
        return _build12thForm(sw);
      case 'UG':
        return _buildUGForm(sw);
      case 'PG':
        return _buildPGForm(sw);
      case 'Diploma':
        return _buildDiplomaForm(sw);
      case 'ITI':
        return _buildITIForm(sw);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── 10th Form ─────────────────────────────────────────────────────────────
  Widget _build10thForm(double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(sw, _tenth_school, 'School Name / Institute'),
        SizedBox(height: sw * 0.05),
        _buildLabel(sw, 'Board'),
        SizedBox(height: sw * 0.03),
        _buildChipSelector(
          sw,
          options: _boards,
          selected: _tenth_board,
          onSelect: (v) => setState(() => _tenth_board = v),
        ),
        SizedBox(height: sw * 0.05),
        _buildTextField(
          sw,
          _tenth_passing,
          'Year of Completion',
          inputType: TextInputType.number,
          maxLength: 4,
        ),
        SizedBox(height: sw * 0.05),
        _buildTextField(
          sw,
          _tenth_marks,
          'Percentage / CGPA',
          inputType: TextInputType.number,
        ),
      ],
    );
  }

  // ── 12th Form ─────────────────────────────────────────────────────────────
  Widget _build12thForm(double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(sw, _twelfth_school, 'School / Junior College Name'),
        SizedBox(height: sw * 0.05),
        _buildLabel(sw, 'Board'),
        SizedBox(height: sw * 0.03),
        _buildChipSelector(
          sw,
          options: _boards,
          selected: _twelfth_board,
          onSelect: (v) => setState(() => _twelfth_board = v),
        ),
        SizedBox(height: sw * 0.05),
        _buildLabel(sw, 'Stream'),
        SizedBox(height: sw * 0.03),
        _buildChipSelector(
          sw,
          options: _streams,
          selected: _twelfth_stream,
          onSelect: (v) => setState(() => _twelfth_stream = v),
        ),
        SizedBox(height: sw * 0.05),
        _buildTextField(
          sw,
          _twelfth_passing,
          'Year of Completion',
          inputType: TextInputType.number,
          maxLength: 4,
        ),
        SizedBox(height: sw * 0.05),
        _buildTextField(
          sw,
          _twelfth_marks,
          'Percentage / CGPA',
          inputType: TextInputType.number,
        ),
      ],
    );
  }

  // ── UG Form ───────────────────────────────────────────────────────────────
  Widget _buildUGForm(double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(sw, _ug_course, 'Course name'),
        SizedBox(height: sw * 0.03),
        _buildChipSelector(
          sw,
          options: _ugCourses,
          selected: _ug_course.text.isEmpty ? null : _ug_course.text,
          onSelect: (v) => setState(() => _ug_course.text = v),
          isReadOnly: false,
        ),
        SizedBox(height: sw * 0.05),
        _buildTextField(sw, _ug_specialization, 'Specialization'),
        SizedBox(height: sw * 0.05),
        _buildTextField(sw, _ug_college, 'Institute / College'),
        SizedBox(height: sw * 0.05),
        _buildTextField(sw, _ug_university, 'University / Board'),
        SizedBox(height: sw * 0.05),
        _buildTextField(
          sw,
          _ug_marks,
          'Percentage / CGPA',
          inputType: TextInputType.number,
        ),
        SizedBox(height: sw * 0.05),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                sw,
                _ug_passing,
                'Year of Completion',
                inputType: TextInputType.number,
                maxLength: 4,
              ),
            ),
            SizedBox(width: sw * 0.04),
            Expanded(
              child: _buildTextField(
                sw,
                _ug_duration,
                'Duration',
                inputType: TextInputType.text,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── PG Form ───────────────────────────────────────────────────────────────
  Widget _buildPGForm(double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(sw, _pg_course, 'Course name'),
        SizedBox(height: sw * 0.03),
        _buildChipSelector(
          sw,
          options: _pgCourses,
          selected: _pg_course.text.isEmpty ? null : _pg_course.text,
          onSelect: (v) => setState(() => _pg_course.text = v),
          isReadOnly: false,
        ),
        SizedBox(height: sw * 0.05),
        _buildTextField(sw, _pg_specialization, 'Specialization'),
        SizedBox(height: sw * 0.05),
        _buildTextField(sw, _pg_college, 'Institute / College'),
        SizedBox(height: sw * 0.05),
        _buildTextField(sw, _pg_university, 'University / Board'),
        SizedBox(height: sw * 0.05),
        _buildTextField(
          sw,
          _pg_marks,
          'Percentage / CGPA',
          inputType: TextInputType.number,
        ),
        SizedBox(height: sw * 0.05),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                sw,
                _pg_passing,
                'Year of Completion',
                inputType: TextInputType.number,
                maxLength: 4,
              ),
            ),
            SizedBox(width: sw * 0.04),
            Expanded(
              child: _buildTextField(
                sw,
                _pg_duration,
                'Duration',
                inputType: TextInputType.text,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Diploma Form ──────────────────────────────────────────────────────────
  Widget _buildDiplomaForm(double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(sw, _dip_course, 'Course name'),
        SizedBox(height: sw * 0.03),
        _buildChipSelector(
          sw,
          options: _diplomas,
          selected: _dip_course.text.isEmpty ? null : _dip_course.text,
          onSelect: (v) => setState(() => _dip_course.text = v),
          isReadOnly: false,
        ),
        SizedBox(height: sw * 0.05),
        _buildTextField(sw, _dip_institute, 'Institute'),
        SizedBox(height: sw * 0.05),
        _buildTextField(sw, _dip_board, 'Board'),
        SizedBox(height: sw * 0.05),
        _buildTextField(
          sw,
          _dip_marks,
          'Percentage',
          inputType: TextInputType.number,
        ),
        SizedBox(height: sw * 0.05),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                sw,
                _dip_passing,
                'Year of Completion',
                inputType: TextInputType.number,
                maxLength: 4,
              ),
            ),
            SizedBox(width: sw * 0.04),
            Expanded(
              child: _buildTextField(
                sw,
                _dip_duration,
                'Duration',
                inputType: TextInputType.text,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── ITI Form ──────────────────────────────────────────────────────────────
  Widget _buildITIForm(double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(sw, _iti_trade, 'Course name'),
        SizedBox(height: sw * 0.03),
        _buildChipSelector(
          sw,
          options: _trades,
          selected: _iti_trade.text.isEmpty ? null : _iti_trade.text,
          onSelect: (v) => setState(() => _iti_trade.text = v),
          isReadOnly: false,
        ),
        SizedBox(height: sw * 0.05),
        _buildTextField(sw, _iti_specialization, 'Specialization'),
        SizedBox(height: sw * 0.05),
        _buildLabel(sw, 'Board'),
        SizedBox(height: sw * 0.03),
        _buildChipSelector(
          sw,
          options: ['NCVT', 'SCVT'],
          selected: _iti_board,
          onSelect: (v) => setState(() => _iti_board = v),
        ),
        SizedBox(height: sw * 0.05),
        _buildTextField(sw, _iti_institute, 'Institute'),
        SizedBox(height: sw * 0.05),
        _buildTextField(
          sw,
          _iti_marks,
          'Percentage',
          inputType: TextInputType.number,
        ),
        SizedBox(height: sw * 0.05),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                sw,
                _iti_passing,
                'Year of Completion',
                inputType: TextInputType.number,
                maxLength: 4,
              ),
            ),
            SizedBox(width: sw * 0.04),
            Expanded(
              child: _buildTextField(
                sw,
                _iti_duration,
                'Duration',
                inputType: TextInputType.text,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Reusable helpers ───────────────────────────────────────────────────────
  Widget _buildLabel(double sw, String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: sw * 0.04,
        fontWeight: FontWeight.w500,
        color: AppColors.dynamicText,
      ),
    );
  }

  Widget _buildTextField(
    double sw,
    TextEditingController controller,
    String label, {
    TextInputType inputType = TextInputType.text,
    int? maxLength,
    String? hint,
  }) {
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    return TextField(
      controller: controller,
      keyboardType: inputType,
      maxLength: maxLength,
      style: GoogleFonts.poppins(color: textColor, fontSize: sw * 0.038),
      inputFormatters: inputType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        labelStyle: GoogleFonts.poppins(
          color: subtitleColor,
          fontSize: sw * 0.038,
        ),
        hintStyle: GoogleFonts.poppins(
          color: subtitleColor,
          fontSize: sw * 0.036,
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

  Widget _buildChipSelector(
    double sw, {
    required List<String> options,
    required String? selected,
    required void Function(String) onSelect,
    bool wrap = false,
    bool isReadOnly = true,
  }) {
    final Color textColor = AppColors.dynamicText;
    final Color borderColor = AppColors.dynamicBorder;
    final Color cardBg = AppColors.dynamicCardBg;

    final chips = options.map((opt) {
      final isSelected = selected == opt;
      return GestureDetector(
        onTap: () => onSelect(opt),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.04,
            vertical: sw * 0.022,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : cardBg,
            border: Border.all(
              color: isSelected ? AppColors.primary : borderColor,
            ),
            borderRadius: BorderRadius.circular(sw * 0.07),
          ),
          child: Text(
            opt,
            style: GoogleFonts.poppins(
              fontSize: sw * 0.034,
              color: isSelected ? Colors.white : textColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
    }).toList();

    if (wrap) {
      return Wrap(spacing: sw * 0.025, runSpacing: sw * 0.025, children: chips);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.expand((c) => [c, SizedBox(width: sw * 0.025)]).toList()
          ..removeLast(),
      ),
    );
  }
}
