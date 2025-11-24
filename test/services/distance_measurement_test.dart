import 'package:flutter_test/flutter_test.dart';


void main() {
  group('Distance Calculation Logic', () {
    // We can't easily mock the FaceDetector and CameraController in a unit test 
    // without extensive mocking, but we can test the logic if we extract it.
    // Since the logic is private in the service, we'll create a testable version or just test the math here.
    
    test('Distance calculation formula verification', () {
      // Formula: distance = (realIPD * focalLength) / pixelIPD
      const double realIPD = 6.3; // cm
      const double focalLength = 600.0; // pixels
      
      // Case 1: Face is close (large pixel IPD)
      double pixelIPD = 300.0;
      double distance = (realIPD * focalLength) / pixelIPD;
      expect(distance, closeTo(12.6, 0.1)); // 12.6 cm
      
      // Case 2: Face is far (small pixel IPD)
      pixelIPD = 30.0;
      distance = (realIPD * focalLength) / pixelIPD;
      expect(distance, closeTo(126.0, 0.1)); // 126 cm
      
      // Case 3: Face is at 40cm (Near test)
      // 40 = (6.3 * 600) / pixelIPD => pixelIPD = (6.3 * 600) / 40 = 94.5
      pixelIPD = 94.5;
      distance = (realIPD * focalLength) / pixelIPD;
      expect(distance, closeTo(40.0, 0.1));
      
      // Case 4: Face is at 200cm (Distance test)
      // 200 = (6.3 * 600) / pixelIPD => pixelIPD = (6.3 * 600) / 200 = 18.9
      pixelIPD = 18.9;
      distance = (realIPD * focalLength) / pixelIPD;
      expect(distance, closeTo(200.0, 0.1));
    });
  });
}
