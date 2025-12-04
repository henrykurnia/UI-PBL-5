import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// theme
import 'package:hydrosee/theme/colors.dart';
import 'package:hydrosee/widgets/button/button_primary.dart';

class IotStatusCard extends StatefulWidget {
  final String deviceName;
  final bool isOnline;
  final VoidCallback? onTap;

  const IotStatusCard({
    super.key,
    required this.deviceName,
    required this.isOnline,
    this.onTap,
  });

  @override
  State<IotStatusCard> createState() => _IotStatusCard();
}

class _IotStatusCard extends State<IotStatusCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onTap: widget.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
          // margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: AppColor.primary_0,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColor.primary_100.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ]
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  Text(
                    widget.deviceName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16, // Sedikit lebih kecil
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary_5,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: widget.isOnline ? AppColor.primary_5.withOpacity(0.2) : AppColor.danger.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.isOnline ? 'Online' : 'Offline',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14, // Sedikit lebih kecil
                        fontWeight: FontWeight.w600,
                        color: widget.isOnline ? AppColor.primary_5 : AppColor.danger,
                      ),
                    ),
                  )
                ] 
              ),
              
              const SizedBox(height: 20),

              // Hapus Text('Status') karena sudah jelas dari label di bawah.
              // SizedBox(height: 10),

              // Status Indicator
              Container(
                width: double.infinity, // ✅ Batasi lebar agar tidak terlalu dominan
                padding: const EdgeInsets.all(0),
                
                child: ButtonPrimary(
                  text: 'Konfigurasi Wifi',
                  onPressed: widget.onTap,
                ),
              )
          ],
        ),
      ),
    );
    // return Container(
    //   margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    //   decoration: BoxDecoration(
    //     color: AppColor.primary_05,
    //     borderRadius: BorderRadius.circular(20),
    //   ),
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       Text(
    //         'Nama Perangkat',
    //         style: GoogleFonts.inter(
    //             fontSize: 22,
    //             fontWeight: FontWeight.w600,
    //             color: AppColor.primary_5),
    //       ),
    //       SizedBox(
    //         height: 10,
    //       ),
    //       Container(
    //         width: double.infinity,
    //         padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    //         decoration: BoxDecoration(
    //           color: AppColor.primary_1,
    //           borderRadius: BorderRadius.circular(12),
    //         ),
    //         child: Text(
    //           widget.deviceName,
    //           textAlign: TextAlign.center,
    //           style: GoogleFonts.inter(
    //             fontSize: 14,
    //             fontWeight: FontWeight.w600,
    //             color: AppColor.primary_5,
    //           ),
    //         ),
    //       ),
    //       SizedBox(
    //         height: 40,
    //       ),
    //       Text(
    //         'Status',
    //         style: GoogleFonts.inter(
    //           fontSize: 18,
    //           fontWeight: FontWeight.w500,
    //           color: AppColor.primary_4
    //         ),
    //       ),
    //       SizedBox(height: 10,),

    //       Container(
    //         width: double.infinity,
    //         padding: EdgeInsets.symmetric(vertical: 18),
    //         decoration: BoxDecoration(
    //           color: widget.isOnline ? AppColor.primary_5 : AppColor.danger,
    //           borderRadius: BorderRadius.circular(1000),
    //         ),
    //         child: Text(
    //           widget.isOnline ? 'Online' : 'offline',
    //           textAlign: TextAlign.center,
    //           style: GoogleFonts.inter(
    //             fontSize: 18,
    //             fontWeight: FontWeight.w600,
    //             color: AppColor.primary_0,
    //           ),
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }
}
