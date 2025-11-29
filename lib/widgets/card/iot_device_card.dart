import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// theme
import 'package:hydrosee/theme/colors.dart';

// widget
import 'package:hydrosee/widgets/button/button_primary.dart';

class IotDeviceCard extends StatefulWidget {
  final String deviceName;
  final VoidCallback onPressed;

  const IotDeviceCard({
    super.key,
    required this.deviceName,
    required this.onPressed,
  });

  @override
  State<IotDeviceCard> createState() => _IotDeviceCard();
}

class _IotDeviceCard extends State<IotDeviceCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColor.primary_05,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1000),
              color: AppColor.primary_15
            ),
            child: Icon( 
                Icons.bluetooth,
                color: AppColor.primary_5,
              ),
          ),
          Text(
            'Nama Perangkat',
            style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColor.primary_5),
          ),
          SizedBox(
            height: 10,
          ),

          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColor.primary_1,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.deviceName,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColor.primary_5,
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 18),
            child: ButtonPrimary(
              text: 'Koneksikan Perangkat', 
              onPressed: widget.onPressed,
            ),
          )
        ],
      ),
    );
  }
}
