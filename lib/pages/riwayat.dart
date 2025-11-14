import 'package:flutter/material.dart';
import 'detail.dart'; 
import 'package:intl/intl.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  DateTime? selectedDate;
  int selectedFilter = 0;

  final List<String> filters = [
    "1 Hari yang lalu",
    "7 Hari yang lalu",
    "30 Hari yang lalu",
  ];

  final List<Map<String, dynamic>> data1Hari = [
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
  ];

  final List<Map<String, dynamic>> data7Hari = []; 
  final List<Map<String, dynamic>> data30Hari = []; 

  List<Map<String, dynamic>> get currentData {
    switch (selectedFilter) {
      case 0:
        return data1Hari;
      case 1:
        return data7Hari;
      case 2:
        return data30Hari;
      default:
        return [];
    }
  }

  String get formattedDate {
    if (selectedDate == null) return "Pilih Tanggal...";
    return DateFormat('dd MMM yyyy').format(selectedDate!);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 225,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/bg_riwayat.jpg'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                ),
                Container(
                  height: 225,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 70, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 45),

                        // === Tombol Filter Hari ===
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(filters.length, (index) {
                            final bool active = selectedFilter == index;
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedFilter = index;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: active
                                          ? const Color(0xFF275902)
                                          : Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      filters[index],
                                      style: TextStyle(
                                        color: active
                                            ? Colors.white
                                            : Colors.white70,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daftar Riwayat Deteksi",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (currentData.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          "Tidak ada deteksi",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: currentData.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildDeteksiCard(
                            waktu: item['waktu'],
                            status: item['status'],
                            statusColor: item['statusColor'],
                            suhu: item['suhu'],
                            kelembapan: item['kelembapan'],
                            imagePath: item['imagePath'],
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
  Widget _buildDeteksiCard({
    required String waktu,
    required String status,
    required Color statusColor,
    required String suhu,
    required String kelembapan,
    required String imagePath,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailDeteksiPage(
              imagePath: imagePath,
              suhu: suhu,
              kelembapan: kelembapan,
              status: status,
              waktu: waktu,
            ),
          ),
        );
      },
      child: Container(
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
      ),
    );
  }
}
