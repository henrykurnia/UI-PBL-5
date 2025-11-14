import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FailedLoginPage extends StatelessWidget {
  const FailedLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Gagal Masuk",
              style: GoogleFonts.inter(
                color: const Color(0xFF275902),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Akunmu tidak ditemukan, Silahkan lanjutkan login menggunakan akun lainnya atau pastikan akunmu valid",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            Image.asset(
              "assets/images/gagal.png",
              width: 220,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA9BD99),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  "Masuk Akun Lagi",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(child: Container(height: 1, color: Colors.grey[400])),
                const SizedBox(width: 10),
                Text("Atau", style: GoogleFonts.inter(color: Colors.grey[700])),
                const SizedBox(width: 10),
                Expanded(child: Container(height: 1, color: Colors.grey[400])),
              ],
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Image.asset("assets/images/google.png",
                    width: 22, height: 22),
                label: Text(
                  "Masuk dengan Google",
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
