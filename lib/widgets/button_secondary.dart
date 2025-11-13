import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonSecondary extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const ButtonSecondary({
    // Key? key
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<ButtonSecondary> createState() => _ButtonSecondaryState();
}

class _ButtonSecondaryState extends State<ButtonSecondary> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: widget.onPressed,
      label: Text(
        widget.text,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFA9BD99),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
      ),
    );
  }
}
