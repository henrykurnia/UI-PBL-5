import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import 'package:geolocator/geolocator.dart';

// package
import 'package:loading_animation_widget/loading_animation_widget.dart';

// theme
import 'package:hydrosee/theme/colors.dart';

// config
// import 'package:hydrosee/config/firebase_config.dart';

// service
import 'package:hydrosee/services/api_service.dart';

// model
import 'package:hydrosee/models/full_weather_model.dart';

class CuacaPage extends StatefulWidget {
  CuacaPage({super.key});

  @override
  State<CuacaPage> createState() => _CuacaPage();
}

class _CuacaPage extends State<CuacaPage> {
  // const CuacaPage({super.key});
  FullWeatherModel? weatherData;
  bool isLoading = true;

  String currentTime = '00:00';
  String currentDay = '';

  @override
  void initState() {
    super.initState();
    // Inisialisasi waktu saat ini
    _updateCurrentTime();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initLocation();
    });
    // _userDataFuture = _authService.getStoredUser();
  }

  // Fungsi untuk mendapatkan nama hari Bahasa Indonesia secara manual
  String getIndonesianDayName(DateTime date) {
    final int dayOfWeek = date.weekday;
    switch (dayOfWeek) {
      case 1:
        return "Senin";
      case 2:
        return "Selasa";
      case 3:
        return "Rabu";
      case 4:
        return "Kamis";
      case 5:
        return "Jumat";
      case 6:
        return "Sabtu";
      case 7:
        return "Minggu";
      default:
        return "";
    }
  }

  // Fungsi untuk mendapatkan nama bulan Bahasa Indonesia secara manual
  String getIndonesianMonthName(int month) {
    const List<String> months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des"
    ];
    if (month >= 1 && month <= 12) {
      return months[month];
    }
    return "";
  }

  void _updateCurrentTime() {
    final now = DateTime.now();
    // Menggunakan fungsi manual kita untuk hari dan bulan
    final String hari = getIndonesianDayName(now);
    final String tanggal = now.day.toString();
    final String bulan = getIndonesianMonthName(now.month);

    setState(() {
      currentTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      currentDay = "$hari $tanggal $bulan"; // Contoh: Senin, 2 Des
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

      final Map<String, dynamic>? data =
          await ApiService.getWeather(pos.latitude, pos.longitude);

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

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    // String tanggal = _updateCurrentTime();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======= BAGIAN HEADER =======
            Stack(
              children: [
                
                Container(
                  height: 490,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/bg_cuaca.jpg"),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                ),

                
                Container(
                  height: 450,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                ),

                // konten utama
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 40),

                        // Judul & tanggal
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedLocation01,
                                  color: AppColor.primary_0,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  isLoading
                                      ? "..."
                                      : weatherData != null
                                          ? "${weatherData!.location.city} "
                                          : "no ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  isLoading ? "..., " : currentDay,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  ', ',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  isLoading ? "..., " : currentTime,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 24),

                        // ====== Info suhu utama ======
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 2,
                                  sigmaY: 2,
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 14),
                                  decoration: BoxDecoration(
                                      color:
                                          AppColor.primary_0.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            AppColor.primary_0.withOpacity(0.5),
                                        style: BorderStyle.solid,
                                        width: 0.5,
                                      )),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  HugeIcon(
                                                    icon: HugeIcons
                                                        .strokeRoundedTemperature,
                                                    color: AppColor.primary_1,
                                                    size: 12,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "Suhu",
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 2),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    isLoading
                                                        ? "..."
                                                        : weatherData != null
                                                            ? "${weatherData!.current.temperatureC.round()}"
                                                            : "...",
                                                    style: const TextStyle(
                                                      color: AppColor.primary_0,
                                                      fontSize:
                                                          32, // Sedikit lebih kecil dari sebelumnya
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        "°C",
                                                        style: const TextStyle(
                                                          color: AppColor
                                                              .primary_0,
                                                          fontSize:
                                                              16, // Sedikit lebih kecil dari sebelumnya
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  HugeIcon(
                                                    icon: HugeIcons
                                                        .strokeRoundedFastWind,
                                                    color: AppColor.primary_1,
                                                    size: 12,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "Angin",
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 2),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    isLoading
                                                        ? "..."
                                                        : weatherData != null
                                                            ? "${weatherData!.current.windSpeedMps} "
                                                            : "...",
                                                    // "2 m/s",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "m/s",
                                                        style: const TextStyle(
                                                          color: AppColor
                                                              .primary_0,
                                                          fontSize:
                                                              12, // Sedikit lebih kecil dari sebelumnya
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 3,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        ],
                                      ),

                                      SizedBox(width: 30),

                                      // Kolom kanan: Kelembapan & Angin
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              HugeIcon(
                                                icon: HugeIcons
                                                    .strokeRoundedHumidity,
                                                color: AppColor.primary_1,
                                                size: 12,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Kelembapan",
                                                style: TextStyle(
                                                  color: AppColor.primary_1,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 2),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                isLoading
                                                    ? "..."
                                                    : weatherData != null
                                                        ? "${weatherData!.current.humidity.round()} "
                                                        : "...",
                                                // "2 m/s",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Text(
                                                    "%",
                                                    style: const TextStyle(
                                                      color: AppColor.primary_0,
                                                      fontSize:
                                                          12, // Sedikit lebih kecil dari sebelumnya
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 3,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  isLoading
                                      ? SizedBox(
                                          width: 40,
                                          // height: 40,
                                          child: CircularProgressIndicator(
                                              color: Colors.white))
                                      : Image.asset(
                                          weatherData != null
                                              ? getWeatherIcon(weatherData!
                                                  .current.condition)
                                              : "assets/weather_icon/01.sun-light.png",
                                          width: 80,
                                          fit: BoxFit.contain,
                                        ),
                                  SizedBox(height: 4),
                                  Text(
                                    weatherData != null
                                        ? weatherData!.current.condition
                                            .split(' ')
                                            .join('\n')
                                        : "loading",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // ====== Prediksi per jam ======
                        const Text(
                          "Prediksi Per Jam",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 145,
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white))
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: (weatherData
                                                  ?.hourlyForecasts.length ??
                                              0) >
                                          8
                                      ? 8
                                      : (weatherData?.hourlyForecasts.length ??
                                          0),
                                  itemBuilder: (context, index) {
                                    final hourly =
                                        weatherData!.hourlyForecasts[index];
                                    // Ambil Jam (format HH.00)
                                    final String jam =
                                        "${hourly.timestamp.hour.toString().padLeft(2, '0')}.00";

                                    return ClipRRect(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 2,
                                          sigmaY: 2,
                                        ),
                                        child: Container(
                                          width: 145,
                                          margin:  EdgeInsets.only(right: 12),
                                          padding:  EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color:
                                                  AppColor.primary_0.withOpacity(0.5),
                                              style: BorderStyle.solid,
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                getWeatherIcon(hourly.condition),
                                                width: 60,
                                                height: 60,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                jam,
                                                style: GoogleFonts.inter(color: AppColor.primary_1, fontSize: 12, fontWeight: FontWeight.w500)
                                              ),
                                              Text(hourly.condition, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColor.primary_0, fontSize: 12, fontWeight: FontWeight.w500)),
                                              // Text("${hourly.temperatureC.round()}°C", style: const TextStyle(color: AppColor.primary_2, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ====== Cuaca 4 Hari Kedepan ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "4 Hari Kedepan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primary_100,
                    ),
                  ),

                  const SizedBox(height: 12),

                  isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: AppColor.primary_4
                        )
                      ) :
                    GridView.builder(
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1, 
                        ),
                        // Ambil 4 hari (mulai besok, indeks 1 sampai 4)
                        // Pastikan data cukup, jika tidak ambil seadanya
                        itemCount: (weatherData?.dailyForecasts.length ?? 0) > 4 ? 4 : (weatherData?.dailyForecasts.length ?? 0),
                        itemBuilder: (context, index) {
                          // Ambil data (mulai dari besok jika index 0 adalah hari ini, sesuaikan logika modelmu)
                          // Biasanya API daily[0] adalah hari ini. Jika mau besok, pakai index + 1
                          // Di sini kita pakai index biasa dulu
                          final daily = weatherData!.dailyForecasts[index];
                          
                          // GUNAKAN FUNGSI MANUAL KITA
                          final String namaHari = getIndonesianDayName(daily.timestamp);

                          final bool isAktif = index == 0;
                          final Color warnaCard = isAktif ? AppColor.primary_4 : AppColor.primary_1;
                          final Color warnaTeks = isAktif ? AppColor.primary_1 : AppColor.primary_8;

                          return Container(
                            decoration: BoxDecoration(
                              color: warnaCard,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(2, 2)),
                              ],
                            ),
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  namaHari, // Sudah Bahasa Indonesia!
                                  style: TextStyle(color: warnaTeks, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                // Spacer(),
                                Image.asset(
                                  getWeatherIcon(daily.condition),
                                  width: 45, height: 45,
                                ),
                                // const SizedBox(height: 8),
                                Text(
                                  "${daily.maxTemperatureC.round()}°C",
                                  style: TextStyle(color: warnaTeks, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Humidity ${daily.humidity}%",
                                  style: TextStyle(color: warnaTeks.withOpacity(0.8), fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
