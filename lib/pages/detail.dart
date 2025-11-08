import 'package:flutter/material.dart';
import '../screens/detail_view.dart'; // ✅ Import halaman zoom foto

class DetailDeteksiPage extends StatelessWidget {
  final String imagePath;
  final String suhu;
  final String kelembapan;
  final String status;
  final String waktu;

  const DetailDeteksiPage({
    super.key,
    required this.imagePath,
    required this.suhu,
    required this.kelembapan,
    required this.status,
    required this.waktu,
  });

  // ✅ Logika agar "Tidak Terdeteksi" tidak salah terbaca
  bool get isDetected =>
      status.toLowerCase().contains('terdeteksi') &&
      !status.toLowerCase().contains('tidak');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Detail Deteksi",
          style: TextStyle(
            color: Color(0xFF275902),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFD4DECC),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF527A34)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFD4DECC),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF527A34)),
              onPressed: () {},
            ),
          ),
        ],
      ),

      // ===== BODY =====
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // === Gambar Tanaman (Persegi + bisa zoom saat diklik) ===
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PhotoViewPage(imagePath: imagePath),
                  ),
                );
              },
              child: AspectRatio(
                aspectRatio: 1, // ✅ gambar persegi
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // === Suhu & Kelembapan Card ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoCard(Icons.thermostat, suhu, "Suhu"),
                _infoCard(Icons.water_drop, kelembapan, "Kelembapan"),
              ],
            ),
            const SizedBox(height: 20),

            // === Status Deteksi ===
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: isDetected ? Colors.red : const Color(0xFF275902),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isDetected ? "Terdeteksi Serangga" : "Tidak Ada Serangga",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDetected ? Colors.red : const Color(0xFF275902),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // === Waktu Deteksi ===
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF275902), // ✅ hijau tua
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Terdeteksi: ",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    waktu,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  // ===== Widget Kartu Info (tidak diubah) =====
  Widget _infoCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE9EEE5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF275902)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF275902),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF527A34),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
