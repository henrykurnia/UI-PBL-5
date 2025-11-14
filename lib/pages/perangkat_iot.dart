import 'package:flutter/material.dart';

class PerangkatIoTPage extends StatelessWidget {
  final bool perangkatTersedia; // true kalau ada perangkat

  const PerangkatIoTPage({super.key, required this.perangkatTersedia});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F6),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFE9EEE5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF527A34), size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          "Perangkat IoT Terdeteksi",
          style: TextStyle(
            color: Color(0xFF275902),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: perangkatTersedia
          ? _buildPerangkatList(context)
          : _buildTidakAdaPerangkat(context),
    );
  }

  Widget _buildPerangkatList(BuildContext context) {
    final perangkat = [
      "ESP32CAM_001",
      "ESP32_001",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: perangkat
            .map((nama) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9EEE5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bluetooth_rounded,
                              color: Color(0xFF527A34), size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            "Nama Perangkat",
                            style: TextStyle(
                              color: Color(0xFF527A34),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        nama,
                        style: const TextStyle(
                          color: Color(0xFF527A34),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF527A34),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Koneksikan Perangkat",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
//  jika tidak ada
  Widget _buildTidakAdaPerangkat(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/iot_not_found.png', 
            width: 180,
            height: 160,
          ),
          const SizedBox(height: 30),
          const Text(
            "Perangkat Tidak Ditemukan",
            style: TextStyle(
              color: Color(0xFF275902),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Nyalakan Bluetooth di perangkat anda untuk mendeteksi device IoT",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF527A34),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF527A34),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: const Text(
                "Nyalakan Bluetooth",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
