import 'package:flutter/material.dart';
import 'package:hydrosee/theme/colors.dart';

class TextFieldCustomCategory extends StatefulWidget {
  final String? hint;
  // final String? label;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType keyboardType;

  const TextFieldCustomCategory({
    super.key,
    required this.controller,
    this.hint,
    // this.label,
    this.prefixIcon,
    this.readOnly = false,
    this.onTap,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<TextFieldCustomCategory> createState() =>
      _TextFieldCustomCategoryState();
}

class _TextFieldCustomCategoryState extends State<TextFieldCustomCategory> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      keyboardType: widget.keyboardType,
      style: const TextStyle(
        fontSize: 14, // 🔹 ukuran teks input lebih kecil
        color: AppColor.primary_5,
      ),
      decoration: InputDecoration(
        // labelText: widget.label,
        hintText: widget.hint,
        hintStyle: const TextStyle(
          color: AppColor.primary_4,
          fontSize: 13, // 🔹 teks hint juga lebih kecil
        ),
        filled: true,
        fillColor: AppColor.primary_05,
        prefixIcon: const Icon(
          Icons.arrow_drop_down,
          color: AppColor.primary_5,
          size: 20, // 🔹 ikon juga sedikit diperkecil agar proporsional
        ),

        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        // focusedBorder: OutlineInputBorder(
        //   borderSide: BorderSide(color: Theme.of(context).primaryColor),
        //   borderRadius: BorderRadius.circular(12),
        // ),
      ),
    );
  }
}
