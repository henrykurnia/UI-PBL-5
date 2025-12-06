import 'package:flutter/material.dart';
import 'package:hydrosee/theme/colors.dart';
// import 'edit_profil.dart';
import 'package:switcher_button/switcher_button.dart';

// Services components
import 'package:hydrosee/services/auth_service.dart';

// models
import 'package:hydrosee/models/user_model.dart';

// menu profil
import 'package:hydrosee/widgets/menu/profile_menu.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final AuthService _authService = AuthService();
  late Future<UserModel?> _userDataFuture;

  bool isNotifikasiOn = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _authService.getStoredUser();
  }

  Future<void> _handleSignOut() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _authService.signOut();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== HEADER PROFIL =====
            FutureBuilder(
                future: _userDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                    return Container(
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
                              image: DecorationImage(
                                image: AssetImage('assets/default_profile.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Nama
                          Text(
                            "Guest",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF275902),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Email
                          Text(
                            "Guest@gmail.com",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7D9B67),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final UserModel user = snapshot.data!;

                  return Container(
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
                            image: DecorationImage(
                              image: user.photoUrl != null 
                                    ? NetworkImage(user.photoUrl!) 
                                    : const AssetImage('assets/default_profile.png') 
                                    as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Nama
                        Text(
                          user.displayName.isNotEmpty
                          ? user.displayName
                          : user.email,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF275902),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Email
                        Text(
                          user.email.isNotEmpty
                          ? user.email
                          : "",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7D9B67),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              ),

            // Container(
            //   padding: const EdgeInsets.only(top: 80, bottom: 30),
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       // Foto profil
            //       Container(
            //         width: 90,
            //         height: 90,
            //         decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(50),
            //           border: Border.all(color: Colors.white, width: 3),
            //           image: const DecorationImage(
            //             image: AssetImage('assets/images/profile1.png'),
            //             fit: BoxFit.cover,
            //           ),
            //         ),
            //       ),
            //       const SizedBox(height: 10),
            //       // Nama
            //       const Text(
            //         "Alffa",
            //         style: TextStyle(
            //           fontSize: 20,
            //           fontWeight: FontWeight.bold,
            //           color: Color(0xFF275902),
            //         ),
            //       ),
            //       const SizedBox(height: 4),
            //       // Email
            //       const Text(
            //         "alfahidroponik@gmail.com",
            //         style: TextStyle(
            //           fontSize: 14,
            //           color: Color(0xFF7D9B67),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

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
                        ProfileMenu(
                            icon: Icons.sensors_outlined,
                            title: "Perangkat IoT",
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, '/device');
                            }),
                        ProfileMenu(
                          icon: Icons.logout_outlined,
                          title: "Keluar Akun",
                          color: AppColor.danger,
                          onTap: () {
                            _handleSignOut();
                          },
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
                          leading: const Icon(
                            Icons.notifications_none_rounded,
                            color: Color(0xFF527A34),
                          ),
                          title: const Text(
                            "Notifikasi",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF527A34),
                            ),
                          ),
                          trailing: SwitcherButton(
                            value: true,
                            onChange: (value) {
                              setState(() {
                                // isNotifikasiOn = value;
                              });
                            },
                            onColor: AppColor.primary_5,
                            offColor: AppColor.primary_0,
                          ),
                          // trailing: Switch(
                          //   value: isNotifikasiOn,
                          //   activeColor: const Color(0xFF275902),
                          //   onChanged: (value) {
                          //     setState(() {
                          //       isNotifikasiOn = value;
                          //     });
                          //   },
                          // ),
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
