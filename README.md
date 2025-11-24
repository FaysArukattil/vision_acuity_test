<div align="center">

# 👁️ Vision Acuity Test App

### Professional-Grade Vision Testing at Your Fingertips

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue)]()

A comprehensive Flutter application for conducting standardized Near and Distance vision acuity tests using the Tumbling E chart. Built with WHO-compliant optotype sizing and featuring an innovative camera-based distance measurement system powered by Google ML Kit's Face Detection.

[Features](#-features) • [Demo](#-demo) • [Installation](#-installation) • [Architecture](#-architecture) • [Contributing](#-contributing)

</div>

---

## 🎯 Overview

Vision Acuity Test transforms your mobile device into a professional vision screening tool. Unlike traditional methods that rely on physical distance markers or expensive AR hardware, our app uses advanced facial recognition technology to automatically calculate and maintain precise testing distances in real-time.

### Why This App?

- **Clinically Accurate**: Adheres to WHO standards for optotype sizing and progression
- **Device Agnostic**: Works on any smartphone with a front-facing camera
- **Real-Time Validation**: Automatic distance monitoring prevents invalid test results
- **User-Friendly**: Intuitive swipe gestures and visual feedback guide users through tests
- **Privacy-Focused**: All processing happens on-device; no data leaves your phone

---

## ✨ Features

### 🔬 Standardized Testing
- **Tumbling E Chart**: WHO-compliant optotype with standardized sizing
- **Dual Test Modes**: 
  - Near Vision (40cm)
  - Distance Vision (2 meters)
- **Individual Eye Testing**: Separate assessments for Left, Right, and Both eyes
- **Progressive Difficulty**: LogMAR-based progression from easy to challenging

### 📏 Intelligent Distance Measurement
Our core innovation leverages Google ML Kit's Face Detection API:

1. **Face Landmark Detection**: Identifies left and right eye positions in real-time
2. **IPD Calculation**: Measures pixel distance between eyes
3. **Physical Distance Formula**: 
   ```
   Distance = (Average Human IPD × Focal Length) / Pixel IPD
   Where: Average Human IPD = 63mm
   ```
4. **Active Monitoring**: Pauses test automatically if user moves out of range

### 🎮 Interactive Experience
- **Visual Feedback**: Red/green indicators show distance validity
- **Haptic Feedback**: Vibration alerts when user is at correct distance
- **Swipe Gestures**: Natural interaction for indicating E orientation
- **Unified Instructions**: Clear, swipeable onboarding for every test

### 📊 Comprehensive Results
- **Visual Acuity Scores**: Detailed breakdown per eye (e.g., 6/6, 6/12)
- **Test History**: Track vision changes over time
- **Visual Analytics**: Charts powered by `fl_chart`

---

## 📱 Demo

### Setup Phase
The app guides users to the precise testing distance using a full-screen camera overlay with real-time feedback.

### Testing Phase
Background distance monitoring ensures accuracy throughout the test. If the user leans forward or backward outside the tolerance zone, testing automatically pauses with a warning overlay.

### Results Phase
Comprehensive visual acuity scores with historical tracking and comparison.

---

## 🚀 Installation

### Prerequisites

Ensure you have the following installed:

- **Flutter SDK**: Latest Stable ([Installation Guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: Included with Flutter
- **IDE**: Android Studio, VS Code, or IntelliJ IDEA
- **Physical Device**: Recommended for camera testing (emulators have limited camera support)

### Quick Start

1. **Clone the Repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/vision_acuity_test.git
   cd vision_acuity_test
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   # Check connected devices
   flutter devices
   
   # Run on specific device
   flutter run
   ```

### Platform-Specific Setup

#### Android
- Minimum SDK: 21 (Android 5.0)
- Camera permission will be requested at runtime

#### iOS
- Minimum iOS Version: 12.0
- Add camera usage description in `ios/Runner/Info.plist`:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>Camera access is required for distance measurement during vision tests</string>
  ```

---

## 🏗️ Architecture

### Project Structure

```
lib/
├── main.dart                          # App entry point & initialization
├── models/                            # Data models
│   ├── test_result.dart              # Test outcome data structure
│   ├── eye_result.dart               # Individual eye results
│   └── ...
├── providers/                         # State management (Provider pattern)
│   ├── test_provider.dart            # Test flow state & logic
│   └── calibration_provider.dart     # Screen calibration state
├── screens/                           # UI Screens
│   ├── home_screen.dart              # Landing page
│   ├── distance_selection_screen.dart # Choose near/distance test
│   ├── distance_vision/              
│   │   ├── distance_eye_test_screen.dart # Main distance test
│   │   └── distance_results_screen.dart  # Results display
│   ├── near_vision/                  
│   │   ├── near_test_screen.dart     # Main near test
│   │   └── ...
│   └── ...
├── services/                          # Business logic & external APIs
│   ├── camera_service.dart           # Camera lifecycle management
│   └── distance_measurement_service.dart  # Face detection & calculations
├── utils/                             # Constants & helpers
│   ├── constants.dart                # App-wide constants (WHO sizes)
│   └── ...
└── widgets/                           # Reusable UI components
    ├── distance_feedback_widget.dart # Camera overlay UI
    ├── distance_badge_widget.dart    # Persistent distance indicator
    ├── unified_instruction_screen.dart # Onboarding flow
    ├── tumbling_e.dart               # E optotype renderer
    └── ...
```

### Key Components

#### Distance Measurement Service
The heart of our innovation uses Google ML Kit's Face Detection:

```dart
class FaceDetectionDistanceService extends DistanceMeasurementService {
  // Average human IPD in mm
  static const double averageIpdMm = 63.0;
  
  @override
  Stream<DistanceMeasurement> startMeasuring() async* {
    // ... captures image stream ...
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isNotEmpty) {
       // ... calculates IPD and Distance ...
       yield DistanceMeasurement(distanceCm: distanceCm, ...);
    }
  }
}
```

#### Test Provider
Manages the flow of the vision test:

```dart
class TestProvider with ChangeNotifier {
  // WHO Standard Snellen levels
  static const List<String> snellenLevels = ['6/60', '6/48', ... '6/6'];
  
  void handleSwipe(int swipedDirection) {
    // ... verifies answer and progresses level ...
  }
}
```

---

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Camera & ML
  camera: ^0.10.5                # Device camera access
  google_mlkit_face_detection: ^0.11.1  # Face detection for distance calc
  
  # State Management
  provider: ^6.1.2               # Reactive state management
  
  # Storage
  shared_preferences: ^2.2.3     # Local settings & history
  
  # UI Components
  fl_chart: ^0.65.0             # Result visualization
  flutter_svg: ^2.0.10           # SVG asset rendering
  
  # Utilities
  permission_handler: ^11.3.1   # Runtime permissions
  intl: ^0.19.0                 # Date formatting
```

---

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/distance_measurement_test.dart
```

### Test Structure

```
test/
├── services/
│   └── distance_measurement_test.dart # Unit tests for distance logic
└── ...
```

---

## 🔒 Privacy & Security

- **On-Device Processing**: All face detection and calculations happen locally using Google ML Kit's on-device APIs.
- **No Data Collection**: We don't collect, store, or transmit personal data or camera images.
- **Camera Usage**: Only active during distance measurement; no images are saved to storage.

---

## 🛣️ Roadmap

- [ ] **Multi-language Support**: Internationalization for global accessibility
- [ ] **Additional Charts**: Snellen, ETDRS, and pediatric symbol charts
- [ ] **Color Vision Tests**: Ishihara plate integration
- [ ] **Export to PDF**: Professional report generation
- [ ] **Healthcare Integration**: HL7/FHIR compatibility for EHR systems

---

## 🤝 Contributing

We welcome contributions from the community! Whether you're fixing bugs, adding features, or improving documentation, your help is appreciated.

1. **Fork the Repository**
2. **Create a Feature Branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit Your Changes** (`git commit -m 'Add some AmazingFeature'`)
4. **Push to Your Fork** (`git push origin feature/AmazingFeature`)
5. **Open a Pull Request**

---




## 🙏 Acknowledgments

- **WHO**: For standardized optotype sizing guidelines
- **Google ML Kit**: For robust on-device face detection
- **Flutter Community**: For excellent packages and documentation

---

<div align="center">

**Built with ❤️ using Flutter and Antigravity**

</div>
