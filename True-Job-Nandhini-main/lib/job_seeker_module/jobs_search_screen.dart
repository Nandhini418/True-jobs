import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/widgets/guest_popup.dart';
import 'package:truejobs/job_seeker_module/Jobs%20Sections/jobs_screen.dart';
import '../utils/smooth_page_route.dart';
import '../services/api/location_search_api.dart';
import '../services/api/job_search_api.dart';

class JobSearchScreen extends StatefulWidget {
  final bool returnResults;
  const JobSearchScreen({super.key, this.returnResults = false});

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();

  List<String> _recentSearches = [];
  bool _hasTyped = false;
  bool _isJobSelected = true; // true = Jobs, false = Internships
  static const int _maxRecent = 8;

  List<String> _jobSuggestions = [];
  List<String> _locationSuggestions = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _focusNode.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  // ── SharedPreferences ──────────────────────────────────────────────────────

  Future<String> _getPrefsKey() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isGuest = prefs.getBool('is_guest') ?? false;
    if (isGuest) {
      return 'guest_job_searches';
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
      return 'user_${userId}_job_searches';
    }
    return 'recent_job_searches';
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getPrefsKey();
    if (mounted) {
      setState(() {
        _recentSearches = prefs.getStringList(key) ?? [];
      });
    }
  }

  Future<void> _saveSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    // Move to front if already exists, else prepend
    _recentSearches.remove(q);
    _recentSearches.insert(0, q);

    // Cap list size
    if (_recentSearches.length > _maxRecent) {
      _recentSearches = _recentSearches.sublist(0, _maxRecent);
    }

    final prefs = await SharedPreferences.getInstance();
    final key = await _getPrefsKey();
    await prefs.setStringList(key, _recentSearches);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _removeSearch(String query) async {
    _recentSearches.remove(query);
    final prefs = await SharedPreferences.getInstance();
    final key = await _getPrefsKey();
    await prefs.setStringList(key, _recentSearches);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _clearAllSearches() async {
    _recentSearches.clear();
    final prefs = await SharedPreferences.getInstance();
    final key = await _getPrefsKey();
    await prefs.remove(key);
    if (mounted) {
      setState(() {});
    }
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _onSubmit(String value) async {
    if (await checkAndShowGuestPopup(context)) return;
    _navigateAndSearch();
  }

  void _onChipTap(String query) async {
    if (await checkAndShowGuestPopup(context)) return;
    _searchController.text = query;
    _searchController.selection = TextSelection.collapsed(offset: query.length);
    _navigateAndSearch();
  }

  void _onShowJobs() async {
    if (await checkAndShowGuestPopup(context)) return;
    _navigateAndSearch();
  }

  void _navigateAndSearch() {
    final q = _searchController.text.trim();
    final loc = _locationController.text.trim();
    if (q.isEmpty || loc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both designation/skill and location to search'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    _saveSearch(q);
    setState(() => _hasTyped = true);
    if (widget.returnResults) {
      Navigator.of(context).pop({
        'searchQuery': q,
        'location': loc,
      });
    } else {
      Navigator.of(context).pushReplacement(
        SmoothPageRoute(
          child: JobsScreen(
            searchQuery: q,
            location: loc,
          ),
        ),
      );
    }
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final Color bgColor = AppColors.dynamicBg;
    final Color cardBg = AppColors.dynamicCardBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: textColor,
            size: sw * 0.05,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.05,
            vertical: sw * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ──────────────────────────────────────────────────
              Text(
                'Find opportunities for you',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: sw * 0.045,
                ),
              ),
              SizedBox(height: sw * 0.05),

              // ── Internships / Jobs toggle ──────────────────────────────
              Row(
                children: [
                  _buildRadioOption(
                    sw,
                    textColor,
                    subtitleColor,
                    label: 'Internships',
                    selected: !_isJobSelected,
                    onTap: () => setState(() => _isJobSelected = false),
                  ),
                  SizedBox(width: sw * 0.06),
                  _buildRadioOption(
                    sw,
                    textColor,
                    subtitleColor,
                    label: 'Jobs',
                    selected: _isJobSelected,
                    onTap: () => setState(() => _isJobSelected = true),
                  ),
                ],
              ),
              SizedBox(height: sw * 0.05),

              // ── Designation / skill / company field ────────────────────
              _buildSearchField(
                sw,
                cardBg,
                textColor,
                subtitleColor,
                borderColor,
                controller: _searchController,
                focusNode: _focusNode,
                hint: 'Designation, skill and company',
                onChanged: (val) async {
                  if (mounted) {
                    setState(() {
                      _hasTyped = val.trim().isNotEmpty;
                    });
                  }
                  if (val.trim().isNotEmpty) {
                    try {
                      final res = await JobSearchApi.searchJobs(query: val.trim());
                      if (res['status'] == 'success' && mounted) {
                        final List<dynamic> data = res['data'] ?? [];
                        setState(() {
                          _jobSuggestions = data.map((e) => e.toString()).toList();
                        });
                      }
                    } catch (_) {}
                  } else {
                    if (mounted) {
                      setState(() {
                        _jobSuggestions = [];
                      });
                    }
                  }
                },
                onSubmitted: _onSubmit,
              ),
              if (_jobSuggestions.isNotEmpty) ...[
                SizedBox(height: sw * 0.02),
                Container(
                  constraints: BoxConstraints(maxHeight: sw * 0.5),
                  decoration: BoxDecoration(
                    color: cardBg,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _jobSuggestions.length,
                    itemBuilder: (context, index) {
                      final s = _jobSuggestions[index];
                      return ListTile(
                        leading: Icon(Icons.search, size: sw * 0.045, color: subtitleColor),
                        title: Text(
                          s,
                          style: TextStyle(
                            color: textColor,
                            fontSize: sw * 0.038,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          _searchController.text = s;
                          _searchController.selection = TextSelection.collapsed(offset: s.length);
                          setState(() {
                            _jobSuggestions = [];
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
              SizedBox(height: sw * 0.04),

              // ── Location field ─────────────────────────────────────────
              _buildSearchField(
                sw,
                cardBg,
                textColor,
                subtitleColor,
                borderColor,
                controller: _locationController,
                focusNode: _locationFocusNode,
                hint: 'Location',
                onChanged: (val) async {
                  if (val.trim().isNotEmpty) {
                    try {
                      final res = await LocationSearchApi.searchLocations(query: val.trim());
                      if (res['status'] == 'success' && mounted) {
                        final List<dynamic> data = res['data'] ?? [];
                        setState(() {
                          _locationSuggestions = data.map((e) => e.toString()).toList();
                        });
                      }
                    } catch (_) {}
                  } else {
                    if (mounted) {
                      setState(() {
                        _locationSuggestions = [];
                      });
                    }
                  }
                },
                onSubmitted: (_) => _onShowJobs(),
              ),
              if (_locationSuggestions.isNotEmpty) ...[
                SizedBox(height: sw * 0.02),
                Container(
                  constraints: BoxConstraints(maxHeight: sw * 0.5),
                  decoration: BoxDecoration(
                    color: cardBg,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _locationSuggestions.length,
                    itemBuilder: (context, index) {
                      final s = _locationSuggestions[index];
                      return ListTile(
                        leading: Icon(Icons.location_on, size: sw * 0.045, color: subtitleColor),
                        title: Text(
                          s,
                          style: TextStyle(
                            color: textColor,
                            fontSize: sw * 0.038,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          _locationController.text = s;
                          _locationController.selection = TextSelection.collapsed(offset: s.length);
                          setState(() {
                            _locationSuggestions = [];
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
              SizedBox(height: sw * 0.06),

              // ── Show jobs button ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onShowJobs,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: sw * 0.042),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw * 0.08),
                    ),
                  ),
                  child: Text(
                    'Show jobs',
                    style: TextStyle(
                      fontSize: sw * 0.042,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: sw * 0.06),

              // ── Recent Searches ────────────────────────────────────────
              if (_recentSearches.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent searches',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: sw * 0.042,
                      ),
                    ),
                    GestureDetector(
                      onTap: _clearAllSearches,
                      child: Text(
                        'Clear all',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: sw * 0.035,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sw * 0.03),
                Wrap(
                  spacing: sw * 0.025,
                  runSpacing: sw * 0.025,
                  children: _recentSearches.map((query) {
                    return GestureDetector(
                      onTap: () => _onChipTap(query),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.04,
                          vertical: sw * 0.02,
                        ),
                        decoration: BoxDecoration(
                          color: cardBg,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(sw * 0.06),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history,
                              size: sw * 0.035,
                              color: subtitleColor,
                            ),
                            SizedBox(width: sw * 0.015),
                            Text(
                              query,
                              style: TextStyle(
                                fontSize: sw * 0.035,
                                color: textColor,
                              ),
                            ),
                            SizedBox(width: sw * 0.02),
                            Icon(
                              Icons.trending_up,
                              size: sw * 0.035,
                              color: AppColors.iconGreen,
                            ),
                            SizedBox(width: sw * 0.015),
                            GestureDetector(
                              onTap: () => _removeSearch(query),
                              child: Icon(
                                Icons.close,
                                size: sw * 0.035,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Reusable radio option widget ───────────────────────────────────────────
  Widget _buildRadioOption(
      double sw,
      Color textColor,
      Color subtitleColor, {
        required String label,
        required bool selected,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: sw * 0.04,
            height: sw * 0.04,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? textColor : subtitleColor,
                width: sw * 0.004,
              ),
            ),
            child: selected
                ? Center(
              child: Container(
                width: sw * 0.02,
                height: sw * 0.02,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: textColor,
                ),
              ),
            )
                : null,
          ),
          SizedBox(width: sw * 0.02),
          Text(
            label,
            style: TextStyle(
              fontSize: sw * 0.04,
              color: textColor,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ── Reusable search input field ────────────────────────────────────────────
  Widget _buildSearchField(
      double sw,
      Color cardBg,
      Color textColor,
      Color subtitleColor,
      Color borderColor, {
        required TextEditingController controller,
        required FocusNode focusNode,
        required String hint,
        required void Function(String) onChanged,
        required void Function(String) onSubmitted,
      }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.045,
        vertical: sw * 0.01,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(sw * 0.02),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.search,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: subtitleColor,
            fontSize: sw * 0.04,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: sw * 0.03),
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}