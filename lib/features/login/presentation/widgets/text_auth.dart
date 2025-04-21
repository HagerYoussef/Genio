import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextAuth extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight fontWeight;
  final Color color;
  const TextAuth({super.key, required this.text, required this.size, required this.fontWeight, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontWeight: fontWeight,
        fontSize: size,
        color: color,
      ),
    );
  }
}