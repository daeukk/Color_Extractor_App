import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'widgets/select_widget.dart';
import 'saved_data_page.dart';
import 'widgets/picture_widget.dart';

class HomePage extends StatelessWidget {
  final List<CameraDescription> cameras; // ✅ Add cameras parameter

  const HomePage({super.key, required this.cameras}); // ✅ Require cameras

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Color Extractor',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 150),

            // Take Picture Button
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Picture'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PictureWidget(cameras: cameras), // ✅ Pass cameras
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Select from Gallery Button
            ElevatedButton.icon(
              icon: const Icon(Icons.photo),
              label: const Text('Select from Gallery'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SelectWidget(cameras: cameras), // ✅ Pass cameras
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Data Button (Navigates to Saved Data)
            ElevatedButton.icon(
              icon: const Icon(Icons.data_usage),
              label: const Text('Data'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedDataPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
