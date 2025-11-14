import 'package:flutter/material.dart';
import 'detail.dart'; 

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  bool isDarkMode = false;

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
          children: [
            // ====== HEADER ======
            Stack(
              children: [
                // Background header
                Container(
                  height: 280,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/bg_beranda.jpg'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                ),

                // Overlay gelap
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                ),

                // Profil + tombol search & notifikasi
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundImage:
                            AssetImage('assets/images/profile1.png'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Selamat datang,',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            Text(
                              'Alffa',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tombol search dan notifikasi
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              children: [
                                // Tombol Search
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    iconSize: 20,
                                    icon: const Icon(
                                      Icons.search_rounded,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Tombol Notifikasi
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    iconSize: 20,
                                    icon: const Icon(
                                      Icons.notifications_none_rounded,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Lokasi, suhu & kelembapan
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Lokasi
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on,
                                    size: 20, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'Nganjuk, Jawa Timur',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Suhu & kelembapan
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Suhu',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 14),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '34°C',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 30),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Kelembapan',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 14),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '30%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '13:00',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Cuaca
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/cuaca1.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Cerah Berawan',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ===== Bagian Deteksi Hari Ini =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
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

  // ===== Widget Card Deteksi =====
  Widget _buildDeteksiCard({
    required String waktu,
    required String status,
    required Color statusColor,
    required String suhu,
    required String kelembapan,
    required String imagePath,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEE5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.asset(
              imagePath,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      waktu,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7D9B67),
                      ),
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
