import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hydrosee/theme/colors.dart';

class ButtonPrimary extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const ButtonPrimary({
    // Key? key
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<ButtonPrimary> createState() => _ButtonPrimaryState();
}

class _ButtonPrimaryState extends State<ButtonPrimary> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: widget.onPressed,
      label: Text(
        widget.text,
        style: GoogleFonts.inter(
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
