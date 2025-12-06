import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hydrosee/theme/colors.dart';
import 'detail.dart'; // pastikan path ini sesuai letak file detail.dart kamu
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

// package
import 'package:hugeicons/hugeicons.dart';

// config
import 'package:hydrosee/config/firebase_config.dart';

// service
import 'package:hydrosee/services/api_service.dart';
import 'package:hydrosee/services/auth_service.dart';
// import 'package:hydrosee/services/location_weather.dart';

// model
import 'package:hydrosee/models/full_weather_model.dart';
import 'package:hydrosee/models/user_model.dart';

class BerandaPage extends StatefulWidget {
  final DatabaseReference databaseRef =
      FirebaseDatabase.instance.ref(FirebaseConfig.backendUrl);

  BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  final AuthService _authService = AuthService();
  // final LocationWeather _locationWeatherService = LocationWeather();
  late Future<UserModel?> _userDataFuture;

  FullWeatherModel? weatherData;
  bool isLoading = true; // State untuk loading data
  String locationName =
      'Nganjuk, Jawa Timur'; // Ganti dengan nama lokasi default atau hasil API
  String currentTime = '00:00'; // Untuk menyimpan waktu saat ini

  @override
  void initState() {
    super.initState();
    // Inisialisasi waktu saat ini
    _updateCurrentTime();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initLocation();
    });
    _userDataFuture = _authService.getStoredUser();
  }

  // Fungsi untuk memperbarui waktu saat ini
  void _updateCurrentTime() {
    final now = DateTime.now();
    setState(() {
      currentTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    });
  }

  Future<void> initLocation() async {
    setState(() {
      isLoading = true; // Mulai loading
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackbar(
            "Izin lokasi ditolak permanen. Harap aktifkan di Pengaturan.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      Position pos = await Geolocator.getCurrentPosition();

      final Map<String, dynamic>? data = await ApiService.getWeather(pos.latitude, pos.longitude);

      if (data != null) {
        setState(() {
          weatherData = FullWeatherModel.fromJson(data);
          
          // Asumsi kamu menggunakan data lokasi dari FullWeatherModel untuk UI lain,
          // jika masih perlu variabel terpisah:
          // locationData = weatherData.location; 

          _updateCurrentTime(); // Perbarui waktu
        });
      } else {
        _showSnackbar("Data cuaca atau lokasi tidak lengkap dari API.");
      }
    } catch (e) {
      _showSnackbar("Terjadi kesalahan: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false; // Selesai loading
      });
    }
  }

  // bool isDarkMode = false;F

  String getWeatherIcon(String description) {
    // Selalu ubah input ke huruf kecil untuk menghindari masalah case-sensitivity
    final String lowerDescription = description.toLowerCase();

    switch (lowerDescription) {
      // ----------------------------------------------------------------------
      // 1. KONDISI CERAH / BERAWAN (Clouds)
      // ----------------------------------------------------------------------
      case "langit cerah": // Clear sky (800)
        return "assets/weather_icon/01.sun-light.png";

      case "sedikit awan": // Few clouds (801)
        return "assets/weather_icon/07.cloudy-light.png";

      case "awan tersebar": // Scattered clouds (802)
      case "awan pecah": // Broken clouds (803)
        return "assets/weather_icon/15.cloud-light.png";

      case "awan mendung": // Overcast clouds (804)
        return "assets/weather_icon/15.cloud-light.png";

      // ----------------------------------------------------------------------
      // 2. KONDISI HUJAN & GERIMIS (Rain & Drizzle)
      // ----------------------------------------------------------------------
      case "hujan rintik-rintik": // Light rain / Drizzle (3xx, 500)
      case "gerimis intensitas tinggi":
      case "gerimis":
        return "assets/weather_icon/18.heavy-rain-light.png";

      case "hujan sedang": // Moderate rain (501)
      case "hujan lebat": // Heavy intensity rain (502)
      case "hujan berintensitas tinggi": 
      case "hujan ekstrem": // Extreme rain (504)
        return "assets/weather_icon/18.heavy-rain-light.png";
      
      // ----------------------------------------------------------------------
      // 3. KONDISI BADAI PETIR (Thunderstorm)
      // ----------------------------------------------------------------------
      case "badai petir ringan":
      case "badai petir": // Thunderstorm (2xx)
      case "badai petir lebat":
      case "badai petir dengan hujan rintik":
        return "assets/weather_icon/13.thunderstorm-light.png";

      // ----------------------------------------------------------------------
      // 4. KONDISI SALJU (Snow)
      // ----------------------------------------------------------------------
      case "salju ringan": // Light snow (600)
      case "salju":
      case "salju lebat": // Heavy snow (602)
        return "assets/weather_icon/22.snow-light.png";

      case "hujan dan salju": // Rain and snow (616)
      case "hujan salju ringan": // Light shower sleet
        return "assets/weather_icon/22.snow-light.png"; // Icon campuran

      // ----------------------------------------------------------------------
      // 5. KONDISI ATMOSFER (Mist, Fog, Haze)
      // ----------------------------------------------------------------------
      case "kabut": // Mist/Fog/Haze (7xx)
      case "kabut asap":
      case "asap":
      case "debu":
        return "assets/weather_icon/17.mist-light.png";
        
      case "tornado": // Tornado (781)
        return "assets/weather_icon/21.heavy-wind-light.png";

      // ----------------------------------------------------------------------
      // 6. DEFAULT (Fallback)
      // ----------------------------------------------------------------------
      default:
        // Fallback jika deskripsi cuaca tidak terdaftar.
        return "assets/weather_icon/01.sun-light.png";
    }
  }

  String translateStateName(String stateName) {
    // Selalu ubah input ke huruf kecil untuk memastikan kecocokan case-insensitive
    final String lowerStateName = stateName.toLowerCase();

    switch (lowerStateName) {
      // ----------------------------------------------------------------------
      // PULAU SUMATERA
      // ----------------------------------------------------------------------
      case "aceh":
        return "Aceh";
      case "north sumatra":
      case "sumatera utara":
        return "Sumatera Utara";
      case "west sumatra":
      case "sumatera barat":
        return "Sumatera Barat";
      case "riau":
        return "Riau";
      case "riau islands":
      case "kepulauan riau":
        return "Kepulauan Riau";
      case "jambi":
        return "Jambi";
      case "south sumatra":
      case "sumatera selatan":
        return "Sumatera Selatan";
      case "bengkulue":
        return "Bengkulu";
      case "lampung":
        return "Lampung";
      case "bangka belitung islands":
      case "kepulauan bangka belitung":
        return "Kepulauan Bangka Belitung";

      // ----------------------------------------------------------------------
      // PULAU JAWA & BALI
      // ----------------------------------------------------------------------
      case "banten":
        return "Banten";
      case "jakarta":
      case "jakarta special capital region":
        return "Daerah Khusus Ibukota Jakarta";
      case "west java":
      case "jawa barat":
        return "Jawa Barat";
      case "central java":
      case "jawa tengah":
        return "Jawa Tengah";
      case "yogyakarta special region":
      case "di yogyakarta":
        return "Daerah Istimewa Yogyakarta";
      case "east java":
      case "jawa timur":
        return "Jawa Timur";
      case "bali":
        return "Bali";

      // ----------------------------------------------------------------------
      // PULAU KALIMANTAN
      // ----------------------------------------------------------------------
      case "west kalimantan":
      case "kalimantan barat":
        return "Kalimantan Barat";
      case "central kalimantan":
      case "kalimantan tengah":
        return "Kalimantan Tengah";
      case "south kalimantan":
      case "kalimantan selatan":
        return "Kalimantan Selatan";
      case "east kalimantan":
      case "kalimantan timur":
        return "Kalimantan Timur";
      case "north kalimantan":
      case "kalimantan utara":
        return "Kalimantan Utara";

      // ----------------------------------------------------------------------
      // PULAU SULAWESI
      // ----------------------------------------------------------------------
      case "north sulawesi":
      case "sulawesi utara":
        return "Sulawesi Utara";
      case "gorontalo":
        return "Gorontalo";
      case "central sulawesi":
      case "sulawesi tengah":
        return "Sulawesi Tengah";
      case "west sulawesi":
      case "sulawesi barat":
        return "Sulawesi Barat";
      case "south sulawesi":
      case "sulawesi selatan":
        return "Sulawesi Selatan";
      case "south east sulawesi":
      case "sulawesi tenggara":
        return "Sulawesi Tenggara";

      // ----------------------------------------------------------------------
      // PULAU NUSA TENGGARA
      // ----------------------------------------------------------------------
      case "west nusa tenggara":
      case "nusa tenggara barat":
        return "Nusa Tenggara Barat";
      case "east nusa tenggara":
      case "nusa tenggara timur":
        return "Nusa Tenggara Timur";

      // ----------------------------------------------------------------------
      // PULAU MALUKU & PAPUA
      // ----------------------------------------------------------------------
      case "maluku":
        return "Maluku";
      case "north maluku":
      case "maluku utara":
        return "Maluku Utara";
      case "papua":
        return "Papua";
      case "west papua":
      case "papua barat":
        return "Papua Barat";
        // Tambahan 4 Provinsi baru di Papua
      case "central papua":
        return "Papua Tengah";
      case "highland papua":
        return "Papua Pegunungan";
      case "south papua":
        return "Papua Selatan";
      case "southwest papua":
        return "Papua Barat Daya";

      // ----------------------------------------------------------------------
      // DEFAULT (Fallback)
      // ----------------------------------------------------------------------
      default:
        // Mengembalikan input asli jika tidak ditemukan terjemahan
        return stateName;
    }
  }

  // contoh data deteksi
  final List<Map<String, dynamic>> dataDeteksi = [
    {
      'waktu': 'Hari Ini, 12:00',
      'status': 'Tidak Terdeteksi',
      'statusColor': const Color(0xFF275902),
      'suhu': '42°C',
      'kelembapan': '50%',
      'imagePath': 'assets/images/tdk.png',
    },
    {
      'waktu': 'Hari Ini, 12:21',
      'status': 'Terdeteksi',
      'statusColor': Colors.red,
      'suhu': '27°C',
      'kelembapan': '87%',
      'imagePath': 'assets/images/terdeteksi.png',
    },
    {
      'waktu': 'Hari Ini, 13:00',
      'status': 'Tidak Terdeteksi',
      'statusColor': const Color(0xFF275902),
      'suhu': '42°C',
      'kelembapan': '50%',
      'imagePath': 'assets/images/tdk.png',
    },
    {
      'waktu': 'Hari Ini, 13:00',
      'status': 'Tidak Terdeteksi',
      'statusColor': const Color(0xFF275902),
      'suhu': '42°C',
      'kelembapan': '50%',
      'imagePath': 'assets/images/tdk.png',
    },
    {
      'waktu': 'Hari Ini, 13:00',
      'status': 'Tidak Terdeteksi',
      'statusColor': const Color(0xFF275902),
      'suhu': '42°C',
      'kelembapan': '50%',
      'imagePath': 'assets/images/tdk.png',
    },
    {
      'waktu': 'Hari Ini, 13:00',
      'status': 'Tidak Terdeteksi',
      'statusColor': const Color(0xFF275902),
      'suhu': '42°C',
      'kelembapan': '50%',
      'imagePath': 'assets/images/tdk.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ====== HEADER ======
            buildHeader(context),

            // bagian kondisi lahan
            fieldCondition(),

            // ===== Bagian Deteksi Hari Ini =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deteksi Hari Ini',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: dataDeteksi.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailDeteksiPage(
                                  imagePath: item['imagePath'],
                                  suhu: item['suhu'],
                                  kelembapan: item['kelembapan'],
                                  status: item['status'],
                                  waktu: item['waktu'],
                                ),
                              ),
                            );
                          },
                          child: _buildDeteksiCard(
                            waktu: item['waktu'],
                            status: item['status'],
                            statusColor: item['statusColor'],
                            suhu: item['suhu'],
                            kelembapan: item['kelembapan'],
                            imagePath: item['imagePath'],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ====== HEADER RESPONSIVE (DIPERBAIKI UNTUK TAMPILAN GAMBAR) ======
  Widget buildHeader(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 315,
      child: Stack(
        children: [
          // Background dan Overlay (tetap sama)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                // image: AssetImage('assets/images/bg_beranda.jpg'),
                image: AssetImage('assets/images/bg_beranda.jpg'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            // height: 322,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
          ),

          // Isi Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            // margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40,
                ),
                // Baris profil + icon (tetap sama)
                Row(
                  // Row utama untuk menampung Profil + Nama & Tombol Ikon
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // BAGIAN KIRI: Profil & Nama User
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FutureBuilder<UserModel?>(
                            future: _userDataFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  width: 52, // radius 26 * 2
                                  height: 52, // radius 26 * 2
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const CircleAvatar(
                                      radius: 26,
                                      backgroundImage: AssetImage(
                                              'assets/default_profile.png')
                                          as ImageProvider,
                                      backgroundColor: AppColor.primary_1,
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'Selamat datang,',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14),
                                          ),
                                          Text(
                                            'Guest', // Teks default
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }

                              final UserModel user = snapshot.data!;

                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundImage: user.photoUrl != null
                                        ? NetworkImage(user.photoUrl!)
                                        : const AssetImage(
                                                'assets/default_profile.png')
                                            as ImageProvider,
                                    // backgroundColor: AppColor.primary_1,
                                  ),
                                  const SizedBox(width: 12),
                                  // Flexible/Expanded sangat penting agar teks nama tidak overflow
                                  Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Selamat datang,',
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14),
                                        ),
                                        Text(
                                          user.displayName.isNotEmpty
                                              ? user.displayName
                                              : user
                                                  .email, // Ganti dengan nama user jika ada
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            })
                      ],
                    ),

                    // BAGIAN KANAN: Tombol Ikon (Search & Notifikasi)
                    Row(
                      mainAxisSize:
                          MainAxisSize.min, // Agar Row hanya selebar isinya
                      children: [
                        // _circleButton(Icons.search),
                        // const SizedBox(width: 10),
                        _circleButton(Icons.notifications_none),
                      ],
                    ),
                  ],
                ),

                const SizedBox(
                    height: 30), // Jarak antara profil dan info cuaca

                //  BAGIAN CUACA
                // Row utama untuk menampung Kolom kiri (Lokasi + Suhu/Kelembaban) dan Card Cuaca kanan
                Expanded(
                  // Menggunakan Expanded agar sisa ruang diisi oleh konten cuaca
                  child: Row(
                    // spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kolom kiri: Lokasi (di atas) dan Suhu/Kelembaban (di bawah)
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 2,
                                    sigmaY: 2,
                                  ),
                                  child: Container(
                                    // padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(1000),
                                        border: Border.all(
                                          color: AppColor.primary_0
                                              .withOpacity(0.5),
                                          style: BorderStyle.solid,
                                          width: 0.5,
                                        )),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize
                                          .max, // Agar container tidak melebar
                                      children: [
                                        const Icon(Icons.location_on,
                                            color: Colors.white, size: 20),
                                        const SizedBox(width: 6),
                                        Text(
                                          isLoading
                                              ? "..., "
                                              : weatherData != null
                                                  ? "${weatherData!.location.city}, "
                                                  : "no ",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          isLoading
                                              ? "..."
                                              : weatherData != null
                                                  ? translateStateName(weatherData!.location.state)
                                                  : "result",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                                height:
                                    20), // Jarak antara Lokasi dan Suhu/Kelembaban

                            // Card Suhu & Kelembaban
                            Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 2,
                                          sigmaY: 2,
                                        ),
                                        child: Container(
                                          // width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: AppColor.primary_0
                                                    .withOpacity(0.5),
                                                style: BorderStyle.solid,
                                                width: 0.5,
                                              )
                                            ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Text(
                                                    'Suhu',
                                                    style: GoogleFonts.inter(
                                                        color: AppColor.primary_1,
                                                        fontSize: 12,
                                                        fontWeight:
                                                              FontWeight.w400),
                                                  ),
                                                  HugeIcon(
                                                    icon: HugeIcons
                                                        .strokeRoundedTemperature,
                                                    color: AppColor.primary_1,
                                                    size: 14,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    isLoading
                                                        ? "..."
                                                        : weatherData != null
                                                            ? "${weatherData!.current.temperatureC.round()} "
                                                            : "...",
                                                    style: const TextStyle(
                                                      color: AppColor.primary_0,
                                                      fontSize:
                                                          24, // Sedikit lebih kecil dari sebelumnya
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    "°C",
                                                    style: const TextStyle(
                                                      color: AppColor.primary_0,
                                                      fontSize:
                                                          14, // Sedikit lebih kecil dari sebelumnya
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                  ),
                                  const SizedBox(width: 10),
                                  ClipRRect(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 2,
                                        sigmaY: 2,
                                      ),
                                      child: Container(
                                        width: 120,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                            color: Colors.white
                                                .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: AppColor.primary_0
                                                  .withOpacity(0.5),
                                              style: BorderStyle.solid,
                                              width: 0.5,
                                            )),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Text(
                                                  'Kelembapan',
                                                  style: GoogleFonts.inter(
                                                      color:
                                                          AppColor.primary_1,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                                HugeIcon(
                                                  icon: HugeIcons
                                                      .strokeRoundedHumidity,
                                                  color: AppColor.primary_1,
                                                  size: 14,
                                                ),
                                              ],
                                            ),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    isLoading
                                                        ? "..."
                                                        : weatherData != null
                                                            ? "${weatherData!.current.humidity.round()} "
                                                            : "...",
                                                    style: const TextStyle(
                                                      color:
                                                          AppColor.primary_0,
                                                      fontSize:
                                                          24, // Sama dengan suhu
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    "%",
                                                    style: const TextStyle(
                                                      color:
                                                          AppColor.primary_0,
                                                      fontSize:
                                                          14, // Sama dengan suhu
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ]),
                                            const SizedBox(height: 4),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Card Cuaca (di sisi kanan)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 2,
                              sigmaY: 2,
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColor.primary_0.withOpacity(0.5),
                                    style: BorderStyle.solid,
                                    width: 0.5,
                                  )),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  isLoading
                                      ? SizedBox(
                                          width: 40,
                                          // height: 40,
                                          child: CircularProgressIndicator(
                                              color: Colors.white))
                                      : Image.asset(
                                          weatherData != null
                                              ? getWeatherIcon(
                                                  weatherData!.current.condition)
                                              : "assets/weather_icon/01.sun-light.png",
                                          width: 60,
                                          fit: BoxFit.contain,
                                        ),
                                  SizedBox(height: 6),
                                  Text(
                                    weatherData != null
                                        ? weatherData!.current.condition.split(' ') .join('\n')
                                        : "...",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth *
                                          0.035, // Ukuran teks deskripsi cuaca
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget fieldCondition() {
    // Dapatkan UID dari pengguna yang login
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

    // Jika pengguna belum login, tampilkan pesan error atau loading
    if (currentUid == null) {
      return const Text("Harap Login untuk melihat data sensor.",
          style: TextStyle(color: Colors.white));
    }

    return StreamBuilder(
      // Menggunakan widget.databaseRef yang sudah diinisialisasi di State
      stream: widget.databaseRef
          .child('devices/esp32')
          .orderByChild('ownerUid')
          .equalTo(currentUid)
          .onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        // Default values
        String temperatureText = "--";
        String humidityText = "--";

        if (snapshot.connectionState == ConnectionState.waiting) {
          temperatureText = "...";
          humidityText = "...";
        } else if (snapshot.hasError) {
          temperatureText = "00";
          humidityText = "00";
        } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final dataMap =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          // Ambil nilai suhu dan kelembapan
          // Cek tipe data: Realtime DB sering menyimpan angka sebagai int atau double.
          final tempValue = dataMap['temperature'];
          final humidValue = dataMap['humidity'];

          // Format data
          if (tempValue != null) {
            final double temperature =
                (tempValue is int) ? tempValue.toDouble() : tempValue as double;
            temperatureText = "${temperature.toStringAsFixed(1)}°C";
          }
          if (humidValue != null) {
            final double humidity = (humidValue is int)
                ? humidValue.toDouble()
                : humidValue as double;
            humidityText = "${humidity.toStringAsFixed(1)}%";
          }
        }

        // Tampilkan widget berdasarkan data yang tersedia
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            // mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kondisi Lahanmu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColor.primary_0,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primary_100.withOpacity(0.10),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Suhu",
                                style: GoogleFonts.inter(
                                    color: AppColor.primary_3,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                              HugeIcon(
                                icon:
                                    HugeIcons.strokeRoundedSoilTemperatureField,
                                color: AppColor.primary_3,
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                temperatureText,
                                style: GoogleFonts.inter(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.primary_5),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "°C",
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.primary_5),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColor.primary_0,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primary_100.withOpacity(0.10),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Kelembapan",
                                style: GoogleFonts.inter(
                                    color: AppColor.primary_3,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedSoilMoistureField,
                                color: AppColor.primary_3,
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                humidityText,
                                style: GoogleFonts.inter(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.primary_5),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "%",
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.primary_5),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _circleButton(IconData icon) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 2,
          sigmaY: 2,
        ),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColor.primary_0.withOpacity(0.5),
                style: BorderStyle.solid,
                width: 0.5,
              )),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: () {},
            iconSize: 22,
          ),
        ),
      ),
    );
  }

  // ===== Widget Card Deteksi =====
  Widget _buildDeteksiCard({
    required String waktu,
    required String status,
    required Color statusColor,
    required String suhu,
    required String kelembapan,
    required String imagePath,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.primary_0,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary_100.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: screenWidth * 0.2,
              height: screenWidth * 0.2,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      waktu,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7D9B67),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Suhu: $suhu',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF527A34),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Kelembapan: $kelembapan',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF527A34),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
