import 'dart:io';
import 'package:flutter/material.dart';
import 'widgets/extract_widget.dart';
import 'home_page.dart';
import 'results_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart'; // ✅ Import Camera package

class ReviewPage extends StatefulWidget {
  final String? imagePath;
  final List<CameraDescription> cameras; // ✅ Add cameras parameter

  const ReviewPage(
      {super.key, this.imagePath, required this.cameras}); // ✅ Require cameras

  @override
  ReviewPageState createState() => ReviewPageState();
}

class ReviewPageState extends State<ReviewPage> {
  String? imagePath;
  bool isExtracting = false;

  @override
  void initState() {
    super.initState();
    if (widget.imagePath == null) {
      _takePicture();
    } else {
      imagePath = widget.imagePath;
    }
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null && mounted) {
      setState(() {
        imagePath = pickedFile.path;
      });
    } else if (mounted) {
      Navigator.pop(context);
    }
  }

  void _navigateToResults(Map<String, dynamic> extractedColors) {
    if (!mounted) return;
    setState(() {
      isExtracting = false;
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsPage(
            imagePath: imagePath!,
            extractedColors: extractedColors,
            cameras: widget.cameras, // ✅ Pass cameras to ResultsPage
          ),
        ),
      );
    }
  }

  void _startExtraction() {
    if (!mounted) return;
    setState(() {
      isExtracting = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExtractWidget(
          imagePath: imagePath!,
          onExtracted: _navigateToResults,
        ),
      ),
    );
  }

  Future<void> _selectAgain() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && mounted) {
      setState(() {
        imagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Image"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: imagePath != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.file(File(imagePath!)),
                  ),
                  const SizedBox(height: 20),
                  if (isExtracting)
                    const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("Extracting... Please wait"),
                      ],
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.home),
                            label: const Text("Home"),
                            onPressed: () {
                              if (mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(
                                        cameras:
                                            widget.cameras), // ✅ Pass cameras
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.image),
                            label: const Text("Select Again"),
                            onPressed: _selectAgain,
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.colorize),
                            label: const Text("Extract"),
                            onPressed: isExtracting ? null : _startExtraction,
                          ),
                        ],
                      ),
                    ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
