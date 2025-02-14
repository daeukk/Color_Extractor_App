import 'dart:io';
import 'dart:typed_data';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:color_models/color_models.dart';

class ExtractWidget extends StatefulWidget {
  final String imagePath;
  final Function(Map<String, dynamic>) onExtracted;

  const ExtractWidget({
    super.key,
    required this.imagePath,
    required this.onExtracted,
  });

  @override
  ExtractWidgetState createState() => ExtractWidgetState();
}

class ExtractWidgetState extends State<ExtractWidget> {
  Map<String, dynamic>? _features; // Store extracted features
  bool _isExtracting = true; // Show loading while extracting

  @override
  void initState() {
    super.initState();
    _extractAverageFeatures(File(widget.imagePath));
  }

  // Function to compute the average RGB, LAB, and HSB values, skipping black pixels
  Future<void> _extractAverageFeatures(File imageFile) async {
    log("🔍 Extracting features from: ${imageFile.path}");

    Uint8List imageBytes = await imageFile.readAsBytes();

    // Decode the image
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      log("❌ Failed to decode image");
      _setExtractionError();
      return;
    }

    int width = image.width;
    int height = image.height;
    int totalPixels = width * height;
    int validPixelCount = 0; // Track non-black pixels

    log("✅ Image Loaded: ${width}x$height");

    double sumR = 0, sumG = 0, sumB = 0;
    double sumL = 0, sumA = 0, sumBLab = 0;
    double sumH = 0, sumS = 0, sumV = 0;

    int logStep =
        totalPixels ~/ 10; // Log roughly 10 sample pixels for debugging

    // Iterate through all pixels
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        img.Pixel pixel = image.getPixelSafe(x, y);

        // Extract RGB components and clamp values to [0, 255]
        int r = pixel.r.toInt().clamp(0, 255);
        int g = pixel.g.toInt().clamp(0, 255);
        int b = pixel.b.toInt().clamp(0, 255);

        // Skip black pixels (0,0,0)
        if (r == 0 && g == 0 && b == 0) {
          continue;
        }

        validPixelCount++; // Count only valid (non-black) pixels

        // Log multiple pixel values at random intervals to check color variation
        if ((y * width + x) % logStep == 0) {
          log("🎨 Pixel ($x, $y) - R: $r, G: $g, B: $b");
        }

        // Convert to LAB & HSB
        RgbColor rgbColor = RgbColor(r, g, b);
        LabColor labColor = rgbColor.toLabColor();
        HsbColor hsbColor = rgbColor.toHsbColor();

        // Sum RGB values
        sumR += r;
        sumG += g;
        sumB += b;

        // Sum LAB values
        sumL += labColor.lightness;
        sumA += labColor.a;
        sumBLab += labColor.b;

        // Sum HSB values
        sumH += hsbColor.hue;
        sumS += hsbColor.saturation;
        sumV += hsbColor.brightness;
      }
    }

    // Ensure we have valid pixels before computing averages
    if (validPixelCount == 0) {
      log("⚠️ No valid pixels found. The image might be entirely black.");
      _setExtractionError();
      return;
    }

    // Compute average values
    double avgR = sumR / validPixelCount;
    double avgG = sumG / validPixelCount;
    double avgB = sumB / validPixelCount;
    double avgL = sumL / validPixelCount;
    double avgA = sumA / validPixelCount;
    double avgBLab = sumBLab / validPixelCount;
    double avgH = sumH / validPixelCount;
    double avgS = sumS / validPixelCount;
    double avgV = sumV / validPixelCount;

    // Store extracted features
    if (mounted) {
      setState(() {
        _features = {
          "R": avgR.toStringAsFixed(2),
          "G": avgG.toStringAsFixed(2),
          "B": avgB.toStringAsFixed(2),
          "L": avgL.toStringAsFixed(2),
          "a": avgA.toStringAsFixed(2),
          "b": avgBLab.toStringAsFixed(2),
          "H": avgH.toStringAsFixed(2),
          "S": avgS.toStringAsFixed(2),
          "V": avgV.toStringAsFixed(2),
        };
        _isExtracting = false;
      });
    }

    // Pass extracted features back
    widget.onExtracted(_features!);
    log("✅ Extracted Features: $_features");
  }

  // Handles cases where extraction fails
  void _setExtractionError() {
    if (mounted) {
      setState(() {
        _isExtracting = false;
        _features = {"Error": "Failed to extract image features"};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Extract Features")),
      body: Column(
        children: [
          // Display the original image to verify it loads correctly
          Image.file(File(widget.imagePath), height: 300, fit: BoxFit.contain),

          const SizedBox(height: 10),

          if (_isExtracting)
            const CircularProgressIndicator()
          else if (_features != null && !_features!.containsKey("Error"))
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3,
                ),
                itemCount: _features!.length,
                itemBuilder: (context, index) {
                  String key = _features!.keys.elementAt(index);
                  String value = _features![key];
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "$key: $value",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            const Center(
                child: Text(
                    "⚠️ Failed to extract features. Try a different image.")),
        ],
      ),
    );
  }
}
