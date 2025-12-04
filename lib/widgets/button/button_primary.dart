import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hydrosee/theme/colors.dart';

// ✅ PERBAIKAN 1: Ubah menjadi StatelessWidget
class ButtonPrimary extends StatelessWidget {
  final String text;
  // ✅ PERBAIKAN 2: Jadikan onPressed Nullable
  final VoidCallback? onPressed; 

  const ButtonPrimary({
    super.key,
    required this.text,
    this.onPressed, // ✅ Hapus 'required' agar bisa menerima null
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan warna tombol berdasarkan status onPressed
    final bool isDisabled = onPressed == null;
    final Color buttonColor = isDisabled ? AppColor.primary_3.withOpacity(0.7) : AppColor.primary_4;

    // ✅ PERBAIKAN 3: Gunakan ElevatedButton biasa (jika tidak ada ikon)
    return ElevatedButton(
      // Properti onPressed akan otomatis menerima null dan menonaktifkan tombol
      onPressed: onPressed, 
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor, // Gunakan warna yang sudah disesuaikan
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
        // Tambahan: Agar teks tetap terlihat saat tombol nonaktif
        foregroundColor: AppColor.primary_0, 
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: AppColor.primary_0,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}