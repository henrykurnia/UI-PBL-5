import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:hydrosee/theme/colors.dart';

class ActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const ActionButton({super.key, required this.icon, required this.onPressed});

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.primary_05,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: widget.onPressed, 
        icon: Icon(
          widget.icon,
          size:  24,
          color: AppColor.primary_5,
        ),
      ),
    );
  }
}
