import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera/camera.dart';
import 'package:color_extractor/main.dart';

void main() {
  late List<CameraDescription> mockCameras;

  setUp(() async {
    // ✅ Create a mock camera list with a single camera
    mockCameras = [
      CameraDescription(
        name: 'Mock Camera',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 0,
      ),
    ];
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // ✅ Build the app with mock cameras
    await tester.pumpWidget(ColorExtractionApp(cameras: mockCameras));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
