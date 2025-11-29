import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:card_loading/card_loading.dart';

// theme
// import 'package:hydrosee/theme/colors.dart';

// // widget
// import 'package:hydrosee/widgets/button/button_primary.dart';

class IotLoadingCard extends StatefulWidget {


  const IotLoadingCard({
    super.key,
  });

  @override
  State<IotLoadingCard> createState() => _IotLoadingCard();
}

class _IotLoadingCard extends State<IotLoadingCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Row(
    children: [
      CardLoading(
        height: 40,
        width: 40,
        borderRadius: BorderRadius.circular(12),
      ),
      SizedBox(width: 16),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardLoading(
              height: 14,
              width: 120,
              borderRadius: BorderRadius.circular(8),
            ),
            SizedBox(height: 8),
            CardLoading(
              height: 12,
              width: 80,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      ),
    ],
  ),
);

  }
}
