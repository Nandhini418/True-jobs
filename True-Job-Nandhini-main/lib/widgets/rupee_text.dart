import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RupeeText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double? iconHeight;

  const RupeeText({
    super.key,
    required this.text,
    required this.style,
    this.iconHeight,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle poppinsStyle = GoogleFonts.poppins(textStyle: style);

    final String cleanText = text.replaceAll(RegExp(r'₹\s+'), '₹');

    if (!cleanText.contains('₹')) {
      return Text(cleanText, style: poppinsStyle);
    }

    final parts = cleanText.split('₹');
    final List<InlineSpan> children = [];

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        children.add(TextSpan(text: parts[i], style: poppinsStyle));
      }
      if (i < parts.length - 1) {
        children.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Image.asset(
              'assets/rupee.png',
              height: iconHeight ?? (style.fontSize ?? 15.0) * 1.5,
              width: iconHeight ?? (style.fontSize ?? 15.0) * 1.5,
              color: style.color ?? Colors.black,
            ),
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(children: children, style: poppinsStyle),
    );
  }
}
