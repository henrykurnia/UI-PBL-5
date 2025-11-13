import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonPrimary extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final String iconPath;

  const ButtonPrimary({
    // Key? key
    super.key,
    required this.text,
    required this.onPressed,
    required this.iconPath,
  });

  @override
  State<ButtonPrimary> createState() => _ButtonPrimaryState();
}

class _ButtonPrimaryState extends State<ButtonPrimary> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: widget.onPressed,
      icon: Image.asset(
        widget.iconPath,
        width: 22,
        height: 22,
      ),
      label: Text(
        widget.text,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF527A34),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
      ),
    );
  }
}
