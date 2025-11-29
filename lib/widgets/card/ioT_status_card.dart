import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// theme
import 'package:hydrosee/theme/colors.dart';

class IotStatusCard extends StatefulWidget {
  final String deviceName;
  final bool isOnline;

  const IotStatusCard({
    super.key,
    required this.deviceName,
    required this.isOnline,
  });

  @override
  State<IotStatusCard> createState() => _IotStatusCard();
}

class _IotStatusCard extends State<IotStatusCard> {
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
          Text(
            'Status',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColor.primary_4
            ),
          ),
          SizedBox(height: 10,),

          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: widget.isOnline ? AppColor.primary_5 : AppColor.danger,
              borderRadius: BorderRadius.circular(1000),
            ),
            child: Text(
              widget.isOnline ? 'Online' : 'offline',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColor.primary_0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
