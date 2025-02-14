import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../review_page.dart';
import 'package:camera/camera.dart'; // ✅ Import Camera package

class SelectWidget extends StatefulWidget {
  final List<CameraDescription> cameras; // ✅ Add cameras parameter

  const SelectWidget({super.key, required this.cameras}); // ✅ Require cameras

  @override
  State<SelectWidget> createState() => _SelectWidgetState();
}

class _SelectWidgetState extends State<SelectWidget> {
  @override
  void initState() {
    super.initState();
    pickImage();
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewPage(
              imagePath: image.path,
              cameras: widget.cameras, // ✅ Pass cameras to ReviewPage
            ),
          ),
        );
      } else if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No image selected")),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error selecting image: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
