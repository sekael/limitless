import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:limitless_flutter/features/quotes/domain/quote.dart';

class QuoteDisplay extends StatelessWidget {
  final Quote quote;

  const QuoteDisplay({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Text(
      quote.text.toString(),
      textAlign: TextAlign.center,
      style: GoogleFonts.merriweather(
        fontStyle: FontStyle.italic,
        fontSize: 32,
        height: 1.3,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

  // @override
  // Widget build(BuildContext context) {
  //   return ClipRRect(
  //     borderRadius: BorderRadius.circular(20.0),
  //     child: Stack(
  //       children: [
  //         BackdropFilter(
  //           filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
  //           child: const SizedBox.expand(),
  //         ),
  //         Container(
  //           padding: const EdgeInsets.symmetric(
  //             vertical: 16.0,
  //             horizontal: 8.0,
  //           ),
  //           decoration: BoxDecoration(
  //             color: Colors.white.withAlpha(32),
  //             borderRadius: BorderRadius.circular(20.0),
  //             border: Border.all(color: Colors.white.withAlpha(40)),
  //           ),
  //           child: Text(
  //             quote.text.toString(),
  //             textAlign: TextAlign.center,
  //             style: GoogleFonts.merriweather(
  //               fontStyle: FontStyle.italic,
  //               fontSize: 32,
  //               height: 1.3,
  //               fontWeight: FontWeight.w400,
  //               color: Theme.of(context).colorScheme.onSurface,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
