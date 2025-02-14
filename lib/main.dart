import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  final cameras = await availableCameras(); // ✅ Get available cameras

  runApp(ColorExtractionApp(cameras: cameras)); // ✅ Pass cameras to HomePage
}

class ColorExtractionApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const ColorExtractionApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Extractor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(cameras: cameras), // ✅ Pass cameras to HomePage
    );
  }
}
