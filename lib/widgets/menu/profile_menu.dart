import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hydrosee/theme/colors.dart';

class ProfileMenu extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const ProfileMenu({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  State<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        widget.icon, 
        color: widget.color ?? AppColor.primary_4,
      ),
      title: Text(
        widget.title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          color: AppColor.primary_4,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 18,
        color: AppColor.primary_4,
      ),
      onTap: widget.onTap,
    );
  }
}
