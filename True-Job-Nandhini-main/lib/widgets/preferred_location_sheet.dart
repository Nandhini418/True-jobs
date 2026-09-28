import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/api/preferred_location_api.dart';

class PreferredLocationSheet extends StatefulWidget {
  final List<String> initialLocations;

  const PreferredLocationSheet({
    super.key,
    required this.initialLocations,
  });

  @override
  State<PreferredLocationSheet> createState() => _PreferredLocationSheetState();
}

class _PreferredLocationSheetState extends State<PreferredLocationSheet> {
  final List<String> _selectedLocations = [];
  bool _isLoading = true;
  String? _error;
  List<String> _locations = [];
  List<String> _filteredLocations = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLocations.addAll(widget.initialLocations);
    _fetchLocations();
    _searchController.addListener(_filterLocations);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterLocations);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await PreferredLocationApi.fetchPreferredLocations();
      if (!mounted) return;

      if (res['error'] == false && res['dropdown'] != null) {
        final List rawList = res['dropdown'];
        final List<String> fetched = rawList
            .map((e) => e['label']?.toString() ?? '')
            .where((label) => label.isNotEmpty)
            .toList();

        setState(() {
          _locations = fetched;
          _filteredLocations = fetched;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = res['message'] ?? 'Failed to load locations';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _filterLocations() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLocations = _locations;
      } else {
        _filteredLocations = _locations
            .where((loc) => loc.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _toggleSelection(String location) {
    setState(() {
      if (_selectedLocations.contains(location)) {
        _selectedLocations.remove(location);
      } else {
        _selectedLocations.add(location);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double sw = size.width;
    final double sh = size.height;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color borderColor = AppColors.dynamicBorder;
    final Color cardBg = AppColors.dynamicCardBg;
    final Color subtitleColor = AppColors.dynamicSubtitle;

    return Container(
      height: sh * 0.75,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle/indicator
          SizedBox(height: sw * 0.03),
          Container(
            width: sw * 0.12,
            height: 4,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: sw * 0.02),

          // Header Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.add_location_alt_outlined,
                      color: textColor,
                      size: sw * 0.06,
                    ),
                    SizedBox(width: sw * 0.025),
                    Text(
                      'Preferred Location',
                      style: TextStyle(
                        fontSize: sw * 0.046,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: textColor, size: sw * 0.06),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Divider(color: borderColor, thickness: 1),

          // Search Field
          Padding(
            padding: EdgeInsets.all(sw * 0.04),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Location...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: subtitleColor),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              style: TextStyle(fontSize: sw * 0.038, color: textColor),
            ),
          ),

          // Body Content (Loading / Error / List)
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(sw * 0.05),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: sw * 0.03),
                              ElevatedButton.icon(
                                onPressed: _fetchLocations,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filteredLocations.isEmpty
                        ? Center(
                            child: Text(
                              'No locations match your search',
                              style: TextStyle(color: subtitleColor, fontSize: sw * 0.038),
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                            itemCount: _filteredLocations.length,
                            itemBuilder: (context, index) {
                              final location = _filteredLocations[index];
                              final bool isSelected = _selectedLocations.contains(location);

                              return InkWell(
                                onTap: () => _toggleSelection(location),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: sw * 0.02),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: sw * 0.03,
                                    vertical: sw * 0.03,
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
                                    children: [
                                      Expanded(
                                        child: Text(
                                          location,
                                          style: TextStyle(
                                            fontSize: sw * 0.038,
                                            color: isSelected ? AppColors.primary : textColor,
                                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                        color: isSelected ? AppColors.primary : subtitleColor,
                                        size: sw * 0.055,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),

          Divider(color: borderColor, thickness: 1),

          // Footer buttons
          Padding(
            padding: EdgeInsets.all(sw * 0.04),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: sw * 0.12,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F5F5),
                        foregroundColor: textColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: SizedBox(
                    height: sw * 0.12,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, _selectedLocations),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
