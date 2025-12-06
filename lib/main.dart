import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:floaty_nav_bar/floaty_nav_bar.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'package:custom_quick_alert/custom_quick_alert.dart';

// ===== Import semua halaman =====
// import 'widgets/menubar.dart';
import 'pages/beranda.dart';
import 'pages/cuaca.dart';
import 'pages/riwayat.dart';
import 'pages/profil.dart';
import 'pages/welcome.dart';
import 'pages/login.dart';
import 'pages/edit_profil.dart';
import 'pages/detail.dart';

// screen
import 'screens/IoT_Device.dart';
import 'screens/add_device.dart';

// notification page
import 'notification/login_true.dart';
import 'notification/login_false.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// services
import 'services/auth_wrapper.dart';

// theme
import 'theme/colors.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  CustomQuickAlert.initialize(navigatorKey);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi data lokal untuk Bahasa Indonesia ('id')
  await initializeDateFormatting('id', null);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Hidroponik App', // ✅ Nama aplikasi
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: Colors.transparent,
      ),

      // ✅ Halaman pertama kali dibuka
      // home: const WelcomePage(),
      home: const AuthWrapper(),

      // ✅ Daftar rute navigasi
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/profil': (context) => const ProfilPage(),
        '/register': (context) =>
            const Placeholder(), // nanti diganti halaman daftar
        '/edit_profil': (context) => const EditProfilPage(),
        '/detail': (context) => const DetailDeteksiPage(
              imagePath: 'assets/images/tdk.png',
              suhu: '28°C',
              kelembapan: '85%',
              status: 'Tidak Terdeteksi',
              waktu: '12:00, 12 September 2025',
            ), // ✅ Contoh route detail
        
        // route screen
        '/device': (context) => const IotDevice(),
        '/device_add': (context) => const AddDevice(),

        // route notification
        '/login_true': (context) => const LoginTrue(),
        '/login_false': (context) => const LoginFalse(),
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
              Icons.satellite_alt_outlined,
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
              Icons.history,
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

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int selectedIndex = 0;

//   void onItemTapped(int index) {
//     setState(() {
//       selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final pages = [
//       const BerandaPage(),
//       const CuacaPage(),
//       const RiwayatPage(),
//       const ProfilPage(),
//     ];

//     return Scaffold(
//       extendBody: true,
//       backgroundColor: Colors.transparent,
//       body: pages[selectedIndex],
//       bottomNavigationBar: MenuBarWidget(
//         selectedIndex: selectedIndex,
//         onItemTapped: onItemTapped,
//       ),
//     );
//   }
// }
