import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/login_success.dart';
import '../screens/login_failed.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             
              Image.asset(
                'assets/images/logo_1.png',
                width: 80,
                height: 80,
              ),

              const SizedBox(height: 20),

             
              Text(
                "Masuk ke Akun",
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF275902),
                ),
              ),

              const SizedBox(height: 8),

              
              Text(
                "Pilih masuk menggunakan username dan kode alat\natau menggunakan email Google",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.grey[700],
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 40),

              
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Username",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF7D9B67),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              const TextField(
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF527A34),
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: Color(0xFF275902),
                    size: 20,
                  ),
                  hintText: "Masukkan username...",
                  hintStyle: TextStyle(
                    color: Color(0xFF527A34),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: Color(0xFFE9EEE5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 18,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ===== Input Id Alat =====
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Id Alat",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF7D9B67),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              const TextField(
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF527A34),
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.qr_code_2_rounded,
                    color: Color(0xFF275902),
                    size: 20,
                  ),
                  hintText: "Masukkan id alatmu...",
                  hintStyle: TextStyle(
                    color: Color(0xFF527A34),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: Color(0xFFE9EEE5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 18,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // ===== Tombol Masuk =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // simulasi login sukses/gagal
                    const bool loginBerhasil = true;

                    if (loginBerhasil) {
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const SuccessLoginPage(),
                        ),
                      );
                    } else {
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const FailedLoginPage(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA9BD99),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: Text(
                    "Masuk",
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
                  Expanded(
                    child: Container(height: 1, color: Colors.grey[400]),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Atau",
                    style: GoogleFonts.inter(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(height: 1, color: Colors.grey[400]),
                  ),
                ],
              ),

              const SizedBox(height: 25),

            
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Image.asset(
                    'assets/images/google.png',
                    width: 22,
                    height: 22,
                  ),
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
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
