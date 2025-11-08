import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ===== Import semua halaman =====
import 'widgets/menubar.dart';
import 'pages/beranda.dart';
import 'pages/cuaca.dart';
import 'pages/riwayat.dart';
import 'pages/profil.dart';
import 'pages/welcome.dart';
import 'pages/login.dart';
import 'pages/edit_profil.dart';
import 'pages/detail.dart'; 
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hidroponik App', // ✅ Nama aplikasi
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: Colors.transparent,
      ),

      // ✅ Halaman pertama kali dibuka
      home: const WelcomePage(),

      // ✅ Daftar rute navigasi
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
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
  int selectedIndex = 0;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const BerandaPage(),
      const CuacaPage(),
      const RiwayatPage(),
      const ProfilPage(),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: pages[selectedIndex],
      bottomNavigationBar: MenuBarWidget(
        selectedIndex: selectedIndex,
        onItemTapped: onItemTapped,
      ),
    );
  }
}
