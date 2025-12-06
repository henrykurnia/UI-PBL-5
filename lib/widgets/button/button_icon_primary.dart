import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hydrosee/theme/colors.dart';

class ButtonIconPrimary extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final String iconPath;

  const ButtonIconPrimary({
    // Key? key
    super.key,
    required this.text,
    required this.onPressed,
    required this.iconPath,
  });

  @override
  State<ButtonIconPrimary> createState() => _ButtonIconPrimaryState();
}

class _ButtonIconPrimaryState extends State<ButtonIconPrimary> {
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
