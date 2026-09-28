import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import 'job_detail_screen.dart';
import 'sticky_tab_bar_delegate.dart';
import '../../widgets/guest_popup.dart';
import '../../widgets/rupee_text.dart';
import '../../utils/smooth_page_route.dart';
import '../../services/api/company_details_api.dart';
import '../../services/api/jobs_api.dart';
import '../../constants/date_formatter.dart';
import 'package:url_launcher/url_launcher_string.dart';
class ViewCompanyScreen extends StatefulWidget {
  final Map<String, dynamic> company;

  const ViewCompanyScreen({super.key, required this.company});

  @override
  State<ViewCompanyScreen> createState() => _ViewCompanyScreenState();
}

class _ViewCompanyScreenState extends State<ViewCompanyScreen> {
  int _activeTabIndex = 0; // 0 = Overview, 1 = Jobs
  bool _isAboutExpanded = false;
  bool _isFollowing = false;
  int _culturePageIndex = 0;
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic> _companyDetails = {};
  List<Map<String, dynamic>> _companyJobs = [];

  final PageController _culturePageController = PageController();

  final List<String> _tabs = ['Overview', 'Jobs'];

  List<String> get _cultureImages {
    final culture = _companyDetails['our_culture'];
    if (culture == null) return [];
    if (culture is List) {
      return culture.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _fetchCompanyDetails();
    GoogleFonts.pendingFonts([
      GoogleFonts.poppins(),
    ]).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _fetchCompanyDetails() async {
    final String companyId = widget.company['id']?.toString() ?? '9';
    try {
      final res = await CompanyDetailsApi.fetchCompanyDetails(companyId: companyId);
      if (res['status'] == 'success' || res['error'] == false) {
        final data = res['data'];
        if (data != null && data is Map<String, dynamic>) {
          if (mounted) {
            setState(() {
              _companyDetails = data;
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _errorMessage = 'Invalid company data';
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            String msg = res['message']?.toString() ?? 'Failed to load company details';
            if (msg.toLowerCase().contains('id is required') || 
                msg.toLowerCase().contains('no company/user found')) {
              msg = 'No data found';
            }
            _errorMessage = msg;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }

    // Filter jobs for this company offline from preloaded jobs list
    try {
      final filteredJobs = (JobsApi.preloadedJobs ?? []).where((job) {
        final String recId = (job['recuriter_name'] ?? job['recruiter_name'] ?? '').toString();
        return recId == companyId;
      }).toList();
      if (mounted) {
        setState(() {
          _companyJobs = filteredJobs;
        });
      }
    } catch (e) {
      debugPrint('Error filtering jobs for company: $e');
    }
  }

  @override
  void dispose() {
    _culturePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;
    final double sh = screenSize.height;
    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;

    final companyName = _companyDetails['company_name'] ?? widget.company['name'] ?? 'Techasoft Pvt. Ltd';
    final tagline = _companyDetails['industry_type_name'] ?? widget.company['tagline'] ?? 'Information Technology';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
            size: sw * 0.055,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          companyName,
          style: TextStyle(
            color: textColor,
            fontSize: sw * 0.045,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.bookmark_border_rounded,
              color: textColor,
              size: sw * 0.06,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: textColor,
              size: sw * 0.06,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(sw * 0.05),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_rounded, size: sw * 0.12, color: Colors.red.shade400),
                          SizedBox(height: sw * 0.03),
                          Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textColor, fontSize: sw * 0.038),
                          ),
                        ],
                      ),
                    ),
                  )
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildHeader(companyName, tagline, sw),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: StickyTabBarDelegate(
                          height: sw * 0.12,
                          child: _buildTabs(sw),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _activeTabIndex == 0
                            ? _buildOverviewTab(sw, sh, companyName)
                            : _buildJobsTab(sw, sh, companyName),
                      ),
                    ],
                  ),
      ),
    );
  }

  // ---------------- Header (logo, name, tagline, follow) ----------------

  Widget _buildHeader(String companyName, String tagline, double sw) {
    final Color cardBg = AppColors.dynamicCardBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;

    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.2, sw * 0.02, sw * 0.2, sw * 0.08),
      child: Column(
        children: [
          // Logo
          _companyDetails['company_logo'] != null && _companyDetails['company_logo'].toString().trim().isNotEmpty
              ? Image.network(
                  _companyDetails['company_logo'].toString().trim(),
                  width: double.infinity,
                  height: sw * 0.13,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => _buildFallbackLogo(sw, companyName),
                )
              : _buildFallbackLogo(sw, companyName),

          SizedBox(height: sw * 0.03),

          // Company Name
          Text(
            companyName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: sw * 0.04,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          SizedBox(height: sw * 0.015),

          // Tagline
          Text(
            tagline,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: sw * 0.034,
              color: subtitleColor,
              height: 1.4,
            ),
          ),

          SizedBox(height: sw * 0.05),

          // Follow Button
          GestureDetector(
            onTap: () => setState(() => _isFollowing = !_isFollowing),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.08,
                vertical: sw * 0.025,
              ),
              decoration: BoxDecoration(
                color: _isFollowing
                    ? cardBg
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isFollowing ? Icons.check : Icons.add,
                    size: sw * 0.042,
                    color: _isFollowing
                        ? AppColors.primary
                        : Colors.white,
                  ),
                  SizedBox(width: sw * 0.02),
                  Text(
                    _isFollowing ? "Following" : "Follow",
                    style: TextStyle(
                      fontSize: sw * 0.036,
                      fontWeight: FontWeight.w600,
                      color: _isFollowing
                          ? AppColors.primary
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackLogo(double sw, String companyName) {
    return Container(
      width: sw * 0.20,
      height: sw * 0.20,
      decoration: const BoxDecoration(
        color: Color(0xFFE3F2FD),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        companyName.isNotEmpty ? companyName[0].toUpperCase() : 'T',
        style: TextStyle(
          fontSize: sw * 0.065,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  // ---------------- Overview / Jobs tab row ----------------

  Widget _buildTabs(double sw) {
    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    return Container(
      color: bgColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: borderColor,
                width: 0.8,
              ),
            ),
          ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: List.generate(_tabs.length, (index) {
                                  final isSelected = _activeTabIndex == index;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: index == _tabs.length - 1 ? 0 : sw * 0.08,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _activeTabIndex = index;
                                        });
                                      },
                                      child: IntrinsicWidth(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            const Spacer(),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 4.0,
                                              ),
                                              child: Text(
                                                _tabs[index],
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                softWrap: false,
                                                overflow: TextOverflow.visible,
                                                style: GoogleFonts.poppins(
                                                  fontSize: sw * 0.038,
                                                  fontWeight: FontWeight.w500,
                                                  color: isSelected
                                                      ? textColor
                                                      : subtitleColor,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: sw * 0.02),
                                            Container(
                                              height: 3,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : Colors.transparent,
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(3),
                                                  topRight: Radius.circular(3),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
        ),
      ),
    );
  }

  // ---------------- Overview tab content ----------------

  Widget _buildOverviewTab(double sw, double sh, String companyName) {
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color cardBg = AppColors.dynamicCardBg;

    String aboutText = _companyDetails['company_description']?.toString() ?? '';
    if (aboutText.trim().isEmpty) {
      aboutText = _companyDetails['about_company']?.toString() ?? 'No description available.';
    }
    
    final String fullAboutText = aboutText;
    final String shortAboutText = aboutText.length > 180
        ? '${aboutText.substring(0, 180)}…'
        : aboutText;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About $companyName',
            style: TextStyle(
              fontSize: sw * 0.045,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: sw * 0.025),
          Text(
            _isAboutExpanded ? fullAboutText : shortAboutText,
            style: TextStyle(
              fontSize: sw * 0.035,
              color: subtitleColor,
              height: 1.5,
            ),
          ),
          if (aboutText.length > 180) ...[
            SizedBox(height: sw * 0.015),
            GestureDetector(
              onTap: () => setState(() => _isAboutExpanded = !_isAboutExpanded),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isAboutExpanded ? 'show less' : 'read more',
                    style: TextStyle(
                      fontSize: sw * 0.035,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    _isAboutExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: sw * 0.05,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: sw * 0.06),

          Text(
            'Company Information',
            style: TextStyle(
              fontSize: sw * 0.045,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: sw * 0.03),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(sw * 0.04),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.dynamicBorder),
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.business_center_outlined, 'Industry', _companyDetails['industry_type_name'] ?? 'Information Technology', sw),
                const Divider(),
                _buildInfoRow(Icons.people_alt_outlined, 'Company Size', _companyDetails['company_size_name'] ?? '11 - 50 Employees', sw),
                if (_companyDetails['company_website'] != null && _companyDetails['company_website'].toString().trim().isNotEmpty) ...[
                  const Divider(),
                  _buildInfoRow(Icons.language_outlined, 'Website', _companyDetails['company_website'].toString(), sw, isLink: true),
                ],
              ],
            ),
          ),

          SizedBox(height: sw * 0.06),

          if (_cultureImages.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Our Culture',
                  style: TextStyle(
                    fontSize: sw * 0.045,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: sw * 0.034,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          size: sw * 0.045, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: sw * 0.03),
            SizedBox(
              height: sw * 0.4,
              child: PageView.builder(
                controller: _culturePageController,
                onPageChanged: (index) =>
                    setState(() => _culturePageIndex = index),
                itemCount: (_cultureImages.length / 2).ceil(),
                itemBuilder: (context, pageIndex) {
                  final start = pageIndex * 2;
                  final end = (start + 2) > _cultureImages.length
                      ? _cultureImages.length
                      : start + 2;
                  final pageItems = _cultureImages.sublist(start, end);
                  return Row(
                    children: pageItems
                        .map((item) =>
                        Expanded(child: _buildCultureCard(item, sw)))
                        .toList(),
                  );
                },
              ),
            ),
            SizedBox(height: sw * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                (_cultureImages.length / 2).ceil(),
                    (index) => _buildDot(index == _culturePageIndex, sw),
              ),
            ),
            SizedBox(height: sw * 0.06),
          ],

          _buildEmployeeBenefitsCard(sw),
          SizedBox(height: sw * 0.06),

          SizedBox(
            width: double.infinity,
            height: sh * 0.065,
            child: ElevatedButton(
              onPressed: () => setState(() => _activeTabIndex = 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sw * 0.02),
                ),
              ),
              child: Text(
                'View Open Postions',
                style: TextStyle(
                  fontSize: sw * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: sw * 0.04),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, double sw, {bool isLink = false}) {
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sw * 0.015),
      child: Row(
        children: [
          Icon(icon, size: sw * 0.05, color: AppColors.primary),
          SizedBox(width: sw * 0.03),
          Text(
            '$label : ',
            style: TextStyle(
              fontSize: sw * 0.035,
              color: subtitleColor,
            ),
          ),
          //SizedBox(width: sw * 0.03),
          Expanded(
            child: isLink ? GestureDetector(
              onTap: () async {
                final url = value.startsWith('http') ? value : 'https://$value';
                if (await canLaunchUrlString(url)) {
                  await launchUrlString(url, mode: LaunchMode.externalApplication);
                } else {
                  debugPrint('Could not launch $url');
                }
              },
              child: Text(
                value,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: sw * 0.035,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ) : Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: sw * 0.035,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildCultureCard(String imageUrl, double sw) {
    final Color cardBg = AppColors.dynamicCardBg;

    return Container(
      margin: EdgeInsets.only(right: sw * 0.03),
      child: Container(
        height: sw * 0.28,
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.dynamicBorder),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive, double sw) {
    final Color borderColor = AppColors.dynamicBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(horizontal: sw * 0.01),
      width: isActive ? sw * 0.07 : sw * 0.02,
      height: sw * 0.02,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : borderColor,
        borderRadius: BorderRadius.circular(sw * 0.01),
      ),
    );
  }

  Widget _buildEmployeeBenefitsCard(double sw) {
    final Color textColor = AppColors.dynamicText;
    final Color borderColor = AppColors.dynamicBorder;

    final benefits = [
      'Health Insurance',
      'Flexible Timings',
      'Perfomsnce Bonus',
      'Paid Leave',
      'Training Programs',
      'Hybrid Works',
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      padding: EdgeInsets.all(sw * 0.05),
      child: Stack(
        children: [
          Positioned(
            right: -sw * 0.02,
            bottom: -sw * 0.02,
            child: Icon(
              Icons.sell_outlined,
              size: sw * 0.18,
              color: AppColors.iconGreen.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Employee Benefits',
                style: TextStyle(
                  fontSize: sw * 0.045,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: sw * 0.03),
              ...benefits.map((b) => _buildBenefitItem(b, sw)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String label, double sw) {
    final Color textColor = AppColors.dynamicText;

    return Padding(
      padding: EdgeInsets.only(bottom: sw * 0.025),
      child: Row(
        children: [
          Image.asset('assets/blue_tick.png', height: sw * 0.06,),
          SizedBox(width: sw * 0.025),
          Text(
            label,
            style: TextStyle(fontSize: sw * 0.036, color: textColor),
          ),
        ],
      ),
    );
  }

  // ---------------- Jobs tab content ----------------

  Widget _buildJobsTab(double sw, double sh, String companyName) {
    final Color textColor = AppColors.dynamicText;

    if (_companyJobs.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.1),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_off_outlined, size: sw * 0.12, color: AppColors.dynamicSubtitle),
              SizedBox(height: sw * 0.03),
              Text(
                'No Open Positions',
                style: TextStyle(
                  fontSize: sw * 0.04,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: sw * 0.01),
              Text(
                'This company has no active job postings currently.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: sw * 0.032,
                  color: AppColors.dynamicSubtitle,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final Map<String, int> counts = {};
    for (var j in _companyJobs) {
      final cat = (j['job_title_cat'] ?? j['job_title'] ?? 'Other').toString().trim();
      if (cat.isNotEmpty) {
        final upperCat = cat.toUpperCase();
        counts[upperCat] = (counts[upperCat] ?? 0) + 1;
      }
    }
    final List<Map<String, dynamic>> dynamicCategories = counts.entries.map((e) {
      String title = e.key;
      for (var j in _companyJobs) {
        final jCat = (j['job_title_cat'] ?? j['job_title'] ?? '').toString().trim();
        if (jCat.toUpperCase() == e.key) {
          title = jCat;
          break;
        }
      }
      return {
        'title': title,
        'openings': e.value.toString(),
      };
    }).toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        bottom: sw * 0.04,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient container
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.05,
              vertical: sw * 0.06,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFEF9FF), Color(0xFFF1B1FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.4116, 1.0],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Open Positions in $companyName',
                  style: TextStyle(
                    fontSize: sw * 0.045,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: sw * 0.04),
                // Horizontal Categories
                SizedBox(
                  height: sw * 0.24,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: dynamicCategories.length,
                    separatorBuilder: (_, __) => SizedBox(width: sw * 0.03),
                    itemBuilder: (context, index) =>
                        _buildCategoryCard(dynamicCategories[index], sw),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: sw * 0.05),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
            child: Row(
              children: [
                AnimatedUrgentBadge(sw: sw),
                SizedBox(width: sw * 0.03),
                Text(
                  'In $companyName',
                  style: TextStyle(
                    fontSize: sw * 0.04,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: sw * 0.04),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
            child: Column(
              children: _companyJobs
                  .map((job) => _buildJobCard(job, sw))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, double sw) {
    final Color cardBg = AppColors.dynamicCardBg;
    final Color textColor = AppColors.dynamicText;
    final Color borderColor = AppColors.dynamicBorder;

    return Container(
      width: sw * 0.45,
      padding: EdgeInsets.all(sw * 0.035),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category['title'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: sw * 0.036,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          Row(
            children: [
              Text(
                '${category['openings']} Openings',
                style: TextStyle(
                  fontSize: sw * 0.032,
                  color: AppColors.iconGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: sw * 0.01),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: sw * 0.025, color: AppColors.iconGreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, double sw) {
    final Color cardBg = AppColors.dynamicCardBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    final String title = (job['title'] ?? job['job_title'] ?? '').toString();
    final String company = (job['company'] ?? job['company_name'] ?? '').toString();
    final String location = (job['location'] ?? '').toString();
    final String exp = (job['exp'] ?? job['experience'] ?? '').toString();
    final String salary = (job['salary'] ?? '').toString();
    final String skills = (job['skills'] ?? '').toString();

    return GestureDetector(
      onTap: () async {
        if (await checkAndShowGuestPopup(context)) return;
        if (context.mounted) {
          Navigator.push(
            context,
            SmoothPageRoute(child: JobDetailScreen(job: job)),
          );
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: sw * 0.04),
        padding: EdgeInsets.all(sw * 0.04),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(sw * 0.03),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: sw * 0.06,
                  backgroundColor: const Color(0xFFE3F2FD),
                  child: Text(
                    company.isNotEmpty ? company.substring(0, 1).toUpperCase() : 'J',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: sw * 0.045,
                    ),
                  ),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: sw * 0.04,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        company,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: sw * 0.035,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Icon(Icons.bookmark_border_rounded,
                          size: sw * 0.045, color: subtitleColor),
                      SizedBox(width: sw * 0.01),
                      Text(
                        'Save',
                        style: TextStyle(
                          fontSize: sw * 0.034,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: sw * 0.03),
            Row(
              children: [
                Image.asset(
                  'assets/location.png',
                  height: sw * 0.047,
                  color: subtitleColor,
                ),
                SizedBox(width: sw * 0.02),
                Text(
                  location,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: sw * 0.038,
                  ),
                ),
              ],
            ),
            SizedBox(height: sw * 0.015),
            Row(
              children: [
                Icon(
                  Icons.business_center,
                  size: sw * 0.045,
                  color: subtitleColor,
                ),
                SizedBox(width: sw * 0.02),
                RupeeText(
                  text: '$exp  •  $salary',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: sw * 0.035,
                  ),
                ),
              ],
            ),
            SizedBox(height: sw * 0.02),
            Text(
              skills,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: subtitleColor,
                fontSize: sw * 0.034,
              ),
            ),
            SizedBox(height: sw * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (job['posted'] != null && job['posted'].toString().isNotEmpty)
                      ? job['posted'].toString()
                      : (job['time'] != null && job['time'].toString().isNotEmpty)
                          ? convertToRelativeTime(job['time'])
                          : 'Just now',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: sw * 0.035,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedUrgentBadge extends StatefulWidget {
  final double sw;

  const AnimatedUrgentBadge({super.key, required this.sw});

  @override
  State<AnimatedUrgentBadge> createState() => _AnimatedUrgentBadgeState();
}

class _AnimatedUrgentBadgeState extends State<AnimatedUrgentBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final String _text = 'Urgent Hiring';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000), // 4 seconds cycle
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double sw = widget.sw;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.03,
        vertical: sw * 0.015,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: Border.all(
          color: const Color(0xFFFF8A80),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/image/fire.png',
            height: sw * 0.045,
            width: sw * 0.045,
          ),
          SizedBox(width: sw * 0.015),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_text.length, (index) {
                  final char = _text[index];

                  // Characters fall one by one in interval [0.05, 0.473]
                  final double start = 0.05 + index * (0.35 / _text.length);
                  final double end = start + 0.10;

                  double charOpacity = 0.0;
                  double charYOffset = -15.0; // falling distance

                  if (_controller.value >= end) {
                    charOpacity = 1.0;
                    charYOffset = 0.0;
                  } else if (_controller.value >= start) {
                    final double relativeProgress =
                        (_controller.value - start) / (end - start);
                    final double easeInVal = Curves.easeIn.transform(relativeProgress);
                    final double easeOutVal = Curves.easeOut.transform(relativeProgress);
                    charOpacity = easeInVal;
                    charYOffset = -15.0 * (1.0 - easeOutVal);
                  }

                  // Compute letter-specific fade-out between 0.85 and 0.93
                  double fadeOutFactor = 1.0;
                  if (_controller.value >= 0.93) {
                    fadeOutFactor = 0.0;
                  } else if (_controller.value >= 0.85) {
                    final double relative = (_controller.value - 0.85) / 0.08;
                    fadeOutFactor = 1.0 - Curves.easeOut.transform(relative);
                  }

                  final double finalCharOpacity = charOpacity * fadeOutFactor;

                  if (char == ' ') {
                    return SizedBox(width: sw * 0.01);
                  }

                  return Opacity(
                    opacity: finalCharOpacity,
                    child: Transform.translate(
                      offset: Offset(0, charYOffset),
                      child: Text(
                        char,
                        style: TextStyle(
                          color: const Color(0xFFFF5252),
                          fontSize: sw * 0.035,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}