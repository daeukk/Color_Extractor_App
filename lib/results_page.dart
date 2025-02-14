import 'dart:io';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'database_helper.dart';
import 'package:camera/camera.dart';

class ResultsPage extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> extractedColors;
  final List<CameraDescription> cameras;

  const ResultsPage({
    super.key,
    required this.imagePath,
    required this.extractedColors,
    required this.cameras,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  Future<void> _saveToDatabase() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.saveExtractedColors(
        widget.imagePath, widget.extractedColors);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Extracted colors saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> colorKeys = widget.extractedColors.keys.toList();
    List<String> colorValues =
        widget.extractedColors.values.map((value) => value.toString()).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Extracted Colors"),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Enlarged Image Display
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(widget.imagePath),
                      height: 350, // Increased height
                      width: double.infinity, // Full width
                      fit: BoxFit.contain, // Keeps full image visible
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: (colorKeys.length / 3).ceil(),
                      itemBuilder: (context, index) {
                        int start = index * 3;
                        int end = (start + 3 < colorKeys.length)
                            ? start + 3
                            : colorKeys.length;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(
                                end - start,
                                (i) => Text(
                                  "${colorKeys[start + i]}: ${colorValues[start + i]}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text("Home"),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              HomePage(cameras: widget.cameras)),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                  onPressed: _saveToDatabase,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
