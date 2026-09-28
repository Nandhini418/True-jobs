import 'package:flutter/material.dart';
import '../services/api/company_details_api.dart';

class CompanyLogoWidget extends StatefulWidget {
  final String companyId;
  final String fallbackText;
  final Color fallbackBgColor;
  final Color fallbackTextColor;
  final double radius;

  const CompanyLogoWidget({
    super.key,
    required this.companyId,
    required this.fallbackText,
    required this.fallbackBgColor,
    required this.fallbackTextColor,
    this.radius = 20.0,
  });

  @override
  State<CompanyLogoWidget> createState() => _CompanyLogoWidgetState();
}

class _CompanyLogoWidgetState extends State<CompanyLogoWidget> {
  static final Map<String, String?> _logoCache = {};
  String? _logoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLogo();
  }

  @override
  void didUpdateWidget(CompanyLogoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.companyId != widget.companyId) {
      _loadLogo();
    }
  }

  Future<void> _loadLogo() async {
    final id = widget.companyId;
    if (id.isEmpty || id == 'null') {
      return;
    }

    if (_logoCache.containsKey(id)) {
      if (mounted) {
        setState(() {
          _logoUrl = _logoCache[id];
        });
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final res = await CompanyDetailsApi.fetchCompanyDetails(companyId: id);
      if (res['status'] == 'success' || res['error'] == false) {
        final data = res['data'];
        if (data != null && data is Map) {
          final logo = data['company_logo']?.toString();
          if (logo != null && logo.trim().isNotEmpty) {
            String finalUrl = logo;
            if (!finalUrl.startsWith('http')) {
               if (finalUrl.startsWith('/')) {
                 finalUrl = 'https://truejobs.in$finalUrl';
               } else {
                 finalUrl = 'https://truejobs.in/$finalUrl';
               }
            }
            _logoCache[id] = finalUrl;
            if (mounted) {
              setState(() {
                _logoUrl = finalUrl;
              });
            }
          } else {
            _logoCache[id] = null;
          }
        } else {
          _logoCache[id] = null;
        }
      } else {
        _logoCache[id] = null;
      }
    } catch (e) {
      // Ignore errors for now, allow retry later if needed
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
    if (_logoUrl != null && _logoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(_logoUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          // If image fails to load, fallback to text
        },
        child: _logoUrl == null ? _buildFallback() : null, // The error fallback won't automatically trigger this child build, but it avoids empty if NetworkImage succeeds.
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: widget.fallbackBgColor,
      child: Text(
        widget.fallbackText,
        style: TextStyle(
          color: widget.fallbackTextColor,
          fontWeight: FontWeight.bold,
          fontSize: widget.radius * 0.8,
        ),
      ),
    );
  }
}
