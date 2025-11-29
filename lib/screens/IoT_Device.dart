import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// theme
import 'package:hydrosee/theme/colors.dart';

// widget
import 'package:hydrosee/widgets/card/ioT_status_card.dart';
import 'package:hydrosee/widgets/button/action_button.dart';

class IotDevice extends StatelessWidget {
  const IotDevice({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary_0,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // button back
                  ActionButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  ),
                  Text(
                    'Daftar Perangkat IoT',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary_5
                    ),
                  ),
                  // button tambah
                  ActionButton(
                    icon: Icons.add,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/device_add');
                    }
                  ),
                ],
              ),
            ),
            IotStatusCard(deviceName: 'ESP32', isOnline: true),
            SizedBox(height: 20),
            IotStatusCard(deviceName: 'ESP32-CAM', isOnline: true),
            SizedBox(height: 20),
            IotStatusCard(deviceName: 'ESP32-CAM', isOnline: true),
            SizedBox(height: 20),
            IotStatusCard(deviceName: 'ESP32-CAM', isOnline: true),
            SizedBox(height: 20),
            IotStatusCard(deviceName: 'ESP32-CAM', isOnline: true),
          ],
        )
      ),
    );
  }
}
