import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 1. Get digits only from new value
    final String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // 2. Determine prefix strip count
    String cleaned = digits;
    int stripCount = 0;

    if (digits.length == 12 && digits.startsWith('91')) {
      cleaned = digits.substring(2);
      stripCount = 2;
    } else if (digits.length == 11 && digits.startsWith('0')) {
      cleaned = digits.substring(1);
      stripCount = 1;
    } else if (digits.length == 13 && digits.startsWith('910')) {
      cleaned = digits.substring(3);
      stripCount = 3;
    } else if (digits.length > 10 && digits.startsWith('91')) {
      cleaned = digits.substring(2);
      stripCount = 2;
    } else if (digits.length > 10 && digits.startsWith('0')) {
      cleaned = digits.substring(1);
      stripCount = 1;
    }

    // 3. Truncate cleaned to 10 digits if it's longer
    if (cleaned.length > 10) {
      cleaned = cleaned.substring(0, 10);
    }

    // 4. Calculate selection offsets based on digits before cursor
    int digitsBeforeStart = 0;
    for (int i = 0; i < newValue.selection.start && i < newValue.text.length; i++) {
      if (RegExp(r'\d').hasMatch(newValue.text[i])) {
        digitsBeforeStart++;
      }
    }

    int digitsBeforeEnd = 0;
    for (int i = 0; i < newValue.selection.end && i < newValue.text.length; i++) {
      if (RegExp(r'\d').hasMatch(newValue.text[i])) {
        digitsBeforeEnd++;
      }
    }

    int newStart = digitsBeforeStart - stripCount;
    int newEnd = digitsBeforeEnd - stripCount;

    // Clamp to [0, cleaned.length]
    newStart = newStart.clamp(0, cleaned.length);
    newEnd = newEnd.clamp(0, cleaned.length);

    return TextEditingValue(
      text: cleaned,
      selection: TextSelection(
        baseOffset: newStart,
        extentOffset: newEnd,
      ),
    );
  }
}
