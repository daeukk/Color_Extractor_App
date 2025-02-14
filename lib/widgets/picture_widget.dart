import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:developer' as developer;
import '../home_page.dart';

class PictureWidget extends StatelessWidget {
  final List<CameraDescription> cameras;

  const PictureWidget({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraScreen(cameras: cameras),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  String? _latestImagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    await _controller!.initialize();
    if (!context.mounted) return;
    setState(() {
      _isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) return;
    final image = await _controller!.takePicture();
    final maskedImagePath = await _applyMask(image.path);

    if (!context.mounted) return;

    setState(() {
      _latestImagePath = maskedImagePath;
    });

    _showSaveDialog(maskedImagePath);
  }

  Future<String> _applyMask(String imagePath) async {
    final originalImage = img.decodeImage(File(imagePath).readAsBytesSync());
    if (originalImage == null) {
      developer.log('Failed to load image', name: 'ImageProcessing');
      return imagePath;
    }

    final mask =
        img.Image(width: originalImage.width, height: originalImage.height);
    for (int y = 0; y < originalImage.height; y++) {
      for (int x = 0; x < originalImage.width; x++) {
        if (!_isInsideMask(x, y, originalImage.width, originalImage.height)) {
          mask.setPixel(x, y, img.ColorInt8.rgb(0, 0, 0));
        } else {
          mask.setPixel(x, y, originalImage.getPixel(x, y));
        }
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final maskedImagePath =
        '${directory.path}/masked_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    File maskedImageFile = File(maskedImagePath);
    maskedImageFile.writeAsBytesSync(img.encodeJpg(mask));

    int fileSize = maskedImageFile.lengthSync();
    developer.log('Saved image size: $fileSize bytes', name: 'ImageProcessing');

    return maskedImagePath;
  }

  bool _isInsideMask(int x, int y, int width, int height) {
    int minSide = width < height ? width : height;
    int squareSize = (minSide * 0.1).toInt();
    int startX = (width - squareSize) ~/ 2;
    int startY = (height - squareSize) ~/ 2;
    int endX = startX + squareSize;
    int endY = startY + squareSize;

    return (x >= startX && x <= endX && y >= startY && y <= endY);
  }

  void _showSaveDialog(String imagePath) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Image?'),
          content: _latestImagePath != null
              ? Image.file(File(_latestImagePath!), key: UniqueKey())
              : const SizedBox(),
          actions: [
            TextButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await GallerySaver.saveImage(imagePath,
                    albumName: 'Masked Images');

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image saved successfully!')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Camera'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(cameras: widget.cameras)),
              );
            }
          },
        ),
      ),
      body: _isCameraInitialized
          ? Stack(
              children: [
                Positioned.fill(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: CameraPreview(_controller!),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: MaskOverlayPainter(),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: MediaQuery.of(context).size.width / 2 - 28,
                  child: FloatingActionButton(
                    onPressed: _takePicture,
                    backgroundColor: Colors.black
                        .withAlpha((0.5 * 255).toInt()), // ✅ Updated
                    elevation: 5,
                    child: const Icon(Icons.camera, color: Colors.white),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class MaskOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withAlpha((0.7 * 255).toInt()) // ✅ Updated
      ..style = PaintingStyle.fill;

    Rect outerRect = Offset.zero & size;
    double minSide = size.width < size.height ? size.width : size.height;
    double squareSize = minSide * 0.1;
    double startX = (size.width - squareSize) / 2;
    double startY = (size.height - squareSize) / 2;
    Rect innerRect = Rect.fromLTWH(startX, startY, squareSize, squareSize);

    Path path = Path()
      ..addRect(outerRect)
      ..addRect(innerRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
