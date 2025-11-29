import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// color theme
import 'package:hydrosee/theme/colors.dart';

// button
import 'package:hydrosee/widgets/button/button_primary.dart';

class LoginTrue extends StatelessWidget{
  const LoginTrue({super.key});

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
              Text(
                "Berhasil Masuk",
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary_5
                ),
              ),

              const SizedBox(height: 20,),

              Text(
                "Silahkan lanjutkan membuka aplikasi dengan menekan tombol Lanjutkan",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.grey[700],
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 80,),

              Image.asset(
                'assets/images/logo_1.png',
                width: 128,
                height: 128,
              ),

              const SizedBox(height: 80,),

              SizedBox(
                width: double.infinity,
                child: ButtonPrimary(
                  text: 'Lanjutkan', 
                  onPressed: (){
                    Navigator.pushReplacementNamed(context, '/home');
                  }),
              ),
            ],
          ),
        )
      ),
    );
  }
}