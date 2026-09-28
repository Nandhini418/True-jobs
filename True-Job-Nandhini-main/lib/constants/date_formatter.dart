import 'package:flutter/foundation.dart';

String convertToRelativeTime(dynamic dtime) {
  if (dtime == null) return '';
  final String dateStr = dtime.toString().trim();
  if (dateStr.isEmpty) return '';

  // If it's already in relative format like "4d ago", "Today", "Posted ...", return as is.
  final String lowercase = dateStr.toLowerCase();
  if (lowercase.contains('ago') ||
      lowercase == 'today' ||
      lowercase == 'yesterday' ||
      lowercase.endsWith('h') ||
      lowercase.endsWith('d') ||
      lowercase.endsWith('m') ||
      lowercase.endsWith('w') ||
      lowercase.endsWith('y')) {
    return dateStr;
  }

  try {
    DateTime? parsedDate = DateTime.tryParse(dateStr) ??
        DateTime.tryParse(dateStr.replaceAll(' ', 'T'));

    if (parsedDate == null) {
      return dateStr;
    }

    final DateTime now = DateTime.now();
    final Duration difference = now.difference(parsedDate);

    if (difference.isNegative) {
      return 'Just now';
    }

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'min ago' : 'mins ago'}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hr ago' : 'hrs ago'}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day ago' : 'days ago'}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week ago' : 'weeks ago'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month ago' : 'months ago'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year ago' : 'years ago'}';
    }
  } catch (e) {
    debugPrint('Error parsing date: $e');
    return dateStr;
  }
}
