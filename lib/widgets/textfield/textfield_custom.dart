import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:hydrosee/theme/colors.dart';

class TextFieldCustom extends StatefulWidget {
  final String hintText;
  // final String IconPath;

  const TextFieldCustom({
    super.key,
    required this.hintText,
    // required this.IconPath,
  });

  @override
  State<TextFieldCustom> createState() => _TextFieldCustomState();
}

class _TextFieldCustomState extends State<TextFieldCustom> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(
        fontSize: 14, // 🔹 ukuran teks input lebih kecil
        color: AppColor.primary_5,
      ),
      decoration: InputDecoration(
        // prefixIcon: const Icon(
        //   Icons.person_outline,
        //   color: Color(0xFF275902),
        //   size: 20, // 🔹 ikon juga sedikit diperkecil agar proporsional
        // ),
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
