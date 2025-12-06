import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Firebase
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// Services components
import 'package:hydrosee/services/auth_service.dart';

// Widget components
import 'package:hydrosee/widgets/button/button_icon_primary.dart';

// color theme
import 'package:hydrosee/theme/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  bool isLoading = false; 

  Future<void> _handlegoogleSignIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = await _authService.signInWithGoogle();
      
      if (user != null && mounted) {
        // Navigate to home screen
        Navigator.pushReplacementNamed(context, '/login_true');
      } else if (mounted) {
        // Show error
        Navigator.pushReplacementNamed(context, '/login_false');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary_0,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             
              Image.asset(
                'assets/images/logo_1.png',
                width: 128,
                height: 128,
              ),

              const SizedBox(height: 20),

             
              Text(
                "Jelajahi Aplikasi",
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF275902),
                ),
              ),

              const SizedBox(height: 8),

              
              Text(
                "Silamat datang user, untuk mengakses aplikasi silahkan tautkan google anda untuk membuat atau memasuki akun anda.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.grey[700],
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 40),

            
              SizedBox(
                width: double.infinity,
                child: ButtonIconPrimary(
                  text: 'Masuk dengan Google',
                  iconPath: 'assets/images/google.png',
                  onPressed: _handlegoogleSignIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
