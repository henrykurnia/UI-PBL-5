// import 'dart:ffi';

import 'package:floaty_nav_bar/floaty_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hydrosee/pages/beranda.dart';
import 'package:hydrosee/pages/welcome.dart';
import 'package:hydrosee/pages/cuaca.dart';
import 'package:hydrosee/pages/riwayat.dart';
import 'package:hydrosee/pages/profil.dart';
import 'package:hydrosee/theme/colors.dart';

// widget
// import 'package:hydrosee/widgets/menubar.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      // initialData: (context, snapShot),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // Sedang menunggu firebase cek user
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Kalau user sudah login → langsung ke Dashboard
        if (snapshot.hasData) {
          return const HomePage();
        }

        // Belum login → Welcome Page
        return const WelcomePage();
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // int selectedIndex = 0;

  // void onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      BerandaPage(),
      CuacaPage(),
      RiwayatPage(),
      ProfilPage(),
    ];

    return Scaffold(  
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: pages[_selectedIndex],
      bottomNavigationBar: FloatyNavBar(
        selectedTab: _selectedIndex,
        shape: CircleShape(),
        backgroundColor: AppColor.primary_0,
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
        tabs: [
          FloatyTab(
            isSelected: _selectedIndex == 0,
            title: 'Beranda',
            onTap: () => setState(() => _selectedIndex = 0),
            icon: Icon(
              Icons.home,
              color: _selectedIndex == 0 ? AppColor.primary_0 : AppColor.primary_5,
              size: 18,
            ),
            titleStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500
            ),
            selectedColor: AppColor.primary_5,
            unselectedColor: AppColor.primary_0,
          ),

          FloatyTab(
            isSelected: _selectedIndex == 1,
            title: 'Cuaca',
            onTap: () => setState(() => _selectedIndex = 1),
            icon: Icon(
              Icons.satellite_alt_rounded,
              color: _selectedIndex == 1 ? AppColor.primary_0 : AppColor.primary_5,
              size: 18,
            ),
            titleStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500
            ),
            selectedColor: AppColor.primary_5,
            unselectedColor: AppColor.primary_0,
          ),

          FloatyTab(
            isSelected: _selectedIndex == 2,
            title: 'Riwayat',
            onTap: () => setState(() => _selectedIndex = 2),
            icon: Icon(
              Icons.history_rounded,
              color: _selectedIndex == 2 ? AppColor.primary_0 : AppColor.primary_5,
              size: 18,
            ),
            titleStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500
            ),
            selectedColor: AppColor.primary_5,
            unselectedColor: AppColor.primary_0,
          ),

          FloatyTab(
            isSelected: _selectedIndex == 3,
            title: 'Profil',
            onTap: () => setState(() => _selectedIndex = 3),
            icon: Icon(
              Icons.person,
              color: _selectedIndex == 3 ? AppColor.primary_0 : AppColor.primary_5,
              size: 18,
            ),
            titleStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500
            ),
            selectedColor: AppColor.primary_5,
            unselectedColor: AppColor.primary_0,
          ),
        ],
      ),
      // bottomNavigationBar: MenuBarWidget(
      //   selectedIndex: selectedIndex,
      //   onItemTapped: onItemTapped,
      // ),
    );
  }
}
