import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Services components
import 'package:hydrosee/services/auth_service.dart';

// Widget components
import 'package:hydrosee/widgets/button_primary.dart';
import 'package:hydrosee/widgets/button_secondary.dart';
import 'package:hydrosee/widgets/textfield_custom.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  // Future<UserCredential?> signInWithGoogle() async {
  //   try {
  //     final GoogleSignIn googleSignIn = GoogleSignIn();
  //     // Trigger the authentication flow
  //     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

  //     if (googleUser == null) return null;

  //     // Obtain the auth details from the request
  //     // final GoogleSignInAuthentication googleAuth = googleUser.authentication;
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     // Create a new credential
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     // Once signed in, return the UserCredential
  //     return await FirebaseAuth.instance.signInWithCredential(credential);

  //     // if (!context.mounted) return null;
  //     // Navigator.pushReplacementNamed(context, '/home');

  //     // return credential;
  //   } catch (e) {
  //     print("Error Google Sign-In: $e");
  //     // if (context.mounted) {
  //     //   ScaffoldMessenger.of(context).showSnackBar(
  //     //     SnackBar(content: Text("Login dengan Google gagal: $e")),
  //     //   );
  //     // }
  //     // return null;
  //   }
  // }

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
              // ===== Logo =====
              Image.asset(
                'assets/images/logo_1.png',
                width: 80,
                height: 80,
              ),

              const SizedBox(height: 20),

              // ===== Judul =====
              Text(
                "Masuk ke Akun",
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF275902),
                ),
              ),

              const SizedBox(height: 8),

              // ===== Deskripsi =====
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

              // ===== Input Username =====
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Username",
                  style: GoogleFonts.inter(
                    color: Color(0xFF7D9B67),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              TextFieldCustom(hintText: "Masukkan username..."),

              // TextField(
              //   style: const TextStyle(
              //     fontSize: 14, // 🔹 ukuran teks input lebih kecil
              //     color: Color(0xFF527A34),
              //   ),
              //   decoration: InputDecoration(
              //     prefixIcon: const Icon(
              //       Icons.person_outline,
              //       color: Color(0xFF275902),
              //       size:
              //           20, // 🔹 ikon juga sedikit diperkecil agar proporsional
              //     ),
              //     hintText: "Masukkan username...",
              //     hintStyle: const TextStyle(
              //       color: Color(0xFF527A34),
              //       fontSize: 13, // 🔹 teks hint juga lebih kecil
              //     ),
              //     filled: true,
              //     fillColor: const Color(0xFFE9EEE5),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(30),
              //       borderSide: BorderSide.none,
              //     ),
              //     contentPadding: const EdgeInsets.symmetric(
              //       vertical: 12, // 🔹 sedikit dikurangi
              //       horizontal: 18,
              //     ),
              //   ),
              // ),

              const SizedBox(height: 20),

              // ===== Input Id Alat =====
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Id Alat",
                  style: GoogleFonts.inter(
                    color: Color(0xFF7D9B67),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                style: const TextStyle(
                  fontSize: 14, // 🔹 ukuran teks input lebih kecil
                  color: Color(0xFF527A34),
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF275902),
                    size:
                        20, // 🔹 ikon juga sedikit diperkecil agar proporsional
                  ),
                  hintText: "Masukkan id alatmu...",
                  hintStyle: const TextStyle(
                    color: Color(0xFF527A34),
                    fontSize: 13, // 🔹 teks hint juga lebih kecil
                  ),
                  filled: true,
                  fillColor: const Color(0xFFE9EEE5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12, // 🔹 sedikit dikurangi
                    horizontal: 18,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // ===== Tombol Daftar Akun =====
              SizedBox(
                  width: double.infinity,
                  child: ButtonSecondary(
                    text: 'Masuk',
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/Home');
                    },
                  ),
                  //   ElevatedButton(
                  //   onPressed: () {
                  //     Navigator.pushReplacementNamed(context, '/home');
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: const Color(0xFFA9BD99),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(30),
                  //     ),
                  //     padding: const EdgeInsets.symmetric(vertical: 14),
                  //     elevation: 0,
                  //   ),
                  //   child: Text(
                  //     "Masuk",
                  //     style: GoogleFonts.inter(
                  //       color: Colors.white,
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
              ),

              const SizedBox(height: 25),

              // ===== Garis dan teks "atau" =====
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

              // ===== Tombol Masuk dengan Google =====
              SizedBox(
                width: double.infinity,
                child: ButtonPrimary(
                  text: 'Masuk dengan Google',
                  iconPath: 'assets/images/google.png',
                  onPressed: () async {
                    final authService = AuthService();
                    final userCredential = await authService.signInWithGoogle();

                    if (userCredential != null) {
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Login dengan Google dibatalkan atau gagal')),
                      );
                    }
                  },
                ),
              ),

              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton.icon(
              //     onPressed: () async {
              //       final UserCredential = await signInWithGoogle();

              //       if (UserCredential != null){
              //         Navigator.pushReplacementNamed(context, '/home');
              //       } else{
              //         ScaffoldMessenger.of(context).showSnackBar(
              //           const SnackBar(content: Text('Login dengan Google gagal')),
              //         );
              //       }
              //     },
              //     icon: Image.asset(
              //       'assets/images/google.png',
              //       width: 22,
              //       height: 22,
              //     ),
              //     label: Text(
              //       "Masuk dengan Google",
              //       style: GoogleFonts.inter(
              //         color: Colors.white,
              //         fontSize: 16,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: const Color(0xFF527A34),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(30),
              //       ),
              //       padding: const EdgeInsets.symmetric(vertical: 14),
              //       elevation: 0,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
