import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:limitless_flutter/features/quotes/domain/quote.dart';

class QuoteDisplay extends StatelessWidget {
  final Quote quote;

  const QuoteDisplay({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    final isDarkNow = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkNow
        ? Colors.white.withAlpha(64)
        : Colors.grey.withAlpha(64);
    final backgroundColor = isDarkNow
        ? Colors.white.withAlpha(64)
        : Colors.grey.withAlpha(64);

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Text(
            quote.text.toString(),
            textAlign: TextAlign.center,
            style: GoogleFonts.merriweather(
              fontStyle: FontStyle.italic,
              fontSize: 32,
              height: 1.3,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
