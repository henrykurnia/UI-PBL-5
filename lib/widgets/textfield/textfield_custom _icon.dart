import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:hydrosee/theme/colors.dart';

class TextFieldCustomIcon extends StatefulWidget {
  final String hintText;
  // final String IconPath;

  const TextFieldCustomIcon({
    super.key,
    required this.hintText,
    // required this.IconPath,
  });

  @override
  State<TextFieldCustomIcon> createState() => _TextFieldCustomIconState();
}

class _TextFieldCustomIconState extends State<TextFieldCustomIcon> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(
        fontSize: 14, // 🔹 ukuran teks input lebih kecil
        color: AppColor.primary_5,
      ),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.person_outline,
          color: AppColor.primary_5,
          size: 20, // 🔹 ikon juga sedikit diperkecil agar proporsional
        ),
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: AppColor.primary_4,
          fontSize: 13, // 🔹 teks hint juga lebih kecil
        ),
        filled: true,
        fillColor: AppColor.primary_05,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12, // 🔹 sedikit dikurangi
          horizontal: 18,
        ),
      ),
    );
  }
}
