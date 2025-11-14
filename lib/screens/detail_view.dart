import 'package:flutter/material.dart';

class PhotoViewPage extends StatelessWidget {
  final String imagePath;

  const PhotoViewPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leadingWidth: 80,
        leading: Container(
          margin: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFFE9EEE5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            iconSize: 18, 
            padding: const EdgeInsets.all(8),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF527A34),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFE9EEE5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              iconSize: 18, 
              padding: const EdgeInsets.all(8),
              icon: const Icon(
                Icons.download,
                color: Color(0xFF527A34),
              ),
              onPressed: () {
                
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 1,
          maxScale: 4,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
