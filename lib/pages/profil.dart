import 'package:flutter/material.dart';
import 'edit_profil.dart'; 

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  bool isNotifikasiOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== HEADER PROFIL =====
            Container(
              padding: const EdgeInsets.only(top: 80, bottom: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Foto profil
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.white, width: 3),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/profile1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Nama
                  const Text(
                    "Alffa",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF275902),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Email
                  const Text(
                    "alfahidroponik@gmail.com",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7D9B67),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ===== PENGATURAN AKUN =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pengaturan Akun",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF275902),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Card pengaturan akun
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EEE5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.edit_outlined,
                          title: "Edit Profil",
                          onTap: () {
                            // ✅ Arahkan ke halaman Edit Profil
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfilPage(),
                              ),
                            );
                          },
                        ),
    
                        _buildMenuTile(
                          icon: Icons.sensors_outlined,
                          title: "Perangkat IoT",
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ===== PENGATURAN =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pengaturan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF275902),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EEE5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Notifikasi toggle
                        ListTile(
                          leading: const Icon(Icons.notifications_none_rounded,
                              color: Color(0xFF527A34)),
                          title: const Text(
                            "Notifikasi",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF527A34),
                            ),
                          ),
                          trailing: Switch(
                            value: isNotifikasiOn,
                            activeColor: const Color(0xFF275902),
                            onChanged: (value) {
                              setState(() {
                                isNotifikasiOn = value;
                              });
                            },
                          ),
                        ),
                        _buildMenuTile(
                          icon: Icons.help_outline_rounded,
                          title: "Bantuan & Support",
                          onTap: () {},
                        ),
                        _buildMenuTile(
                          icon: Icons.info_outline_rounded,
                          title: "Tentang Aplikasi",
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ===== WIDGET TILE MENU =====
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF527A34)),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF527A34),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 18,
        color: Color(0xFF527A34),
      ),
      onTap: onTap,
    );
  }
}
