import 'dart:ui';

import 'package:flutter/material.dart';
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

// model
import 'package:hydrosee/models/weather_model.dart';
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
  late Future<UserModel?> _userDataFuture;

  WeatherModel? weatherData;
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

      final data = await ApiService.getWeather(pos.latitude, pos.longitude);

      if (data != null) {
        setState(() {
          weatherData = WeatherModel.fromJson(data);

          _updateCurrentTime(); // Perbarui waktu setelah data cuaca dimuat
        });
      } else {
        _showSnackbar("Gagal mengambil data cuaca.");
      }
    } catch (e) {
      _showSnackbar("Terjadi kesalahan: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false; // Selesai loading
      });
    }
  }

  bool isDarkMode = false;

  String getWeatherIcon(String main) {
    switch (main) {
      case "Clear":
        return "assets/weather_icon/01.sun-light.png";
      case "Clouds":
        return "assets/weather_icon/15.cloud-light.png";
      case "Rain":
        return "assets/weather_icon/18.heavy-rain-light.png";
      case "Drizzle":
        return "assets/weather_icon/18.heavy-rain-light.png";
      case "Thunderstorm":
        return "assets/weather_icon/13.thunderstorm-light.png";
      case "Atmosphere": // Ini bisa jadi Fog, Mist, Haze, dll.
        return "assets/weather_icon/21.heavy-wind-light.png"; // Icon umum untuk kondisi atmosfer
      default:
        return "assets/weather_icon/01.sun-light.png";
    }
  }

  String getNameWeather(String main) {
    switch (main) {
      case "Clear":
        return "Cerah";
      case "Clouds":
        return "Berawan";
      case "Rain":
        return "Hujan Lebat";
      case "Drizzle":
        return "Hujan";
      case "Thunderstorm":
        return "Hujan Petir";
      case "Atmosphere": // Ini bisa jadi Fog, Mist, Haze, dll.
        return "Berembun"; // Icon umum untuk kondisi atmosfer
      default:
        return "cerah";
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

  Widget _buildSensorData() {
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
        String temperatureText = "--°C";
        String humidityText = "--%";

        if (snapshot.connectionState == ConnectionState.waiting) {
          temperatureText = "...";
          humidityText = "...";
        } else if (snapshot.hasError) {
          temperatureText = "Err";
          humidityText = "Err";
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
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 2,
                  sigmaY: 2,
                ),
                child: Container(
                  width: 105,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedTemperature,
                            color: AppColor.primary_1,
                            size: 14,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Suhu',
                            style: TextStyle(
                                color: AppColor.primary_1, fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        temperatureText,
                        style: const TextStyle(
                          color: AppColor.primary_0,
                          fontSize: 24, // Sedikit lebih kecil dari sebelumnya
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 2,
                    sigmaY: 2,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedHumidity,
                              color: AppColor.primary_1,
                              size: 14,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Kelembapan',
                              style: TextStyle(
                                  color: AppColor.primary_1, fontSize: 12),
                            ),
                          ],
                        ),
                        Text(
                          humidityText,
                          style: const TextStyle(
                            color: AppColor.primary_0,
                            fontSize: 24, // Sama dengan suhu
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // const SizedBox(height: 10),
                        // Row(
                        //   mainAxisSize: MainAxisSize.max,
                        //   mainAxisAlignment: MainAxisAlignment.end,
                        //   children: [
                        //     Text(
                        //       currentTime, // Waktu saat ini
                        //       style: const TextStyle(
                        //         color: Colors.white70,
                        //         fontSize: 14,
                        //       ),
                        //     ),
                        //   ],
                        // )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ====== HEADER RESPONSIVE (DIPERBAIKI UNTUK TAMPILAN GAMBAR) ======
  Widget buildHeader(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // final double screenHeight = MediaQuery.of(context).size.height;
    // final double headerHeight = screenHeight < 700 ? 250 : 280; // Tinggi header mungkin perlu sedikit lebih tinggi

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
                //  Ini menggantikan SizedBox(child: Row( ... )) yang kamu berikan
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
                                    backgroundImage:
                                        AssetImage('assets/default_profile.png') as ImageProvider,
                                    backgroundColor: AppColor.primary_1,
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Selamat datang,',
                                          style: TextStyle(color: Colors.white70, fontSize: 14),
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
                              children: <Widget> [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundImage: user.photoUrl != null 
                                    ? NetworkImage(user.photoUrl!) 
                                    : const AssetImage('assets/default_profile.png') 
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
                                          : user.email,// Ganti dengan nama user jika ada
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
                        )
                      ],
                    ),
                    // Row(
                    //   mainAxisSize: MainAxisSize.min,
                    //   children: [
                    //     const CircleAvatar(
                    //       radius: 26,
                    //       backgroundImage:
                    //           AssetImage('assets/images/profile1.png'),
                    //     ),
                    //     const SizedBox(width: 12),
                    //     // Flexible/Expanded sangat penting agar teks nama tidak overflow
                    //     Flexible(
                    //       child: Column(
                    //         mainAxisSize: MainAxisSize.min,
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: const [
                    //           Text(
                    //             'Selamat datang,',
                    //             style: TextStyle(
                    //                 color: Colors.white70, fontSize: 14),
                    //           ),
                    //           Text(
                    //             'Andriyana', // Ganti dengan nama user jika ada
                    //             style: TextStyle(
                    //               color: Colors.white,
                    //               fontSize: 18,
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //             overflow: TextOverflow.ellipsis,
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),

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
                                      borderRadius: BorderRadius.circular(1000),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize
                                          .max, // Agar container tidak melebar
                                      children: [
                                        const Icon(Icons.location_on,
                                            color: Colors.white, size: 20),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            isLoading
                                                ? "..."
                                                : weatherData != null
                                                    ? "${weatherData!.name} "
                                                    : "loading city....",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
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
                              // padding: const EdgeInsets.all(16),
                              // decoration: BoxDecoration(
                              //   color: Colors.white.withOpacity(0.25),
                              //   borderRadius: BorderRadius.circular(20),
                              // ),
                              child: _buildSensorData(),
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
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  isLoading
                                      ? const SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: CircularProgressIndicator(
                                              color: Colors.white))
                                      : Image.asset(
                                          weatherData != null
                                              ? getWeatherIcon(
                                                  weatherData!.condition)
                                              : "assets/weather_icon/01.sun-light.png",
                                          // width: screenWidth * 0.2, // Icon sedikit lebih besar
                                          // height: screenWidth * 0.2,
                                          width: 85,
                                          // height: ,
                                          fit: BoxFit.contain,
                                        ),
                                  const SizedBox(height: 6),
                                  Text(
                                    weatherData != null
                                        ? getNameWeather(weatherData!.condition)
                                        : "Cerah",
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
          ),
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
