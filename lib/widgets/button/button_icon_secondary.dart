import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hydrosee/theme/colors.dart';

class ButtonIconSecondary extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const ButtonIconSecondary({
    // Key? key
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<ButtonIconSecondary> createState() => _ButtonIconSecondaryState();
}

class _ButtonIconSecondaryState extends State<ButtonIconSecondary> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: widget.onPressed,
      label: Text(
        widget.text,
        style: GoogleFonts.inter(
          // color: Colors.white,
          color: AppColor.primary_0,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primary_4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
      ),
    );
  }
}
