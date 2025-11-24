import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:io';

/// Represents a single distance measurement
class DistanceMeasurement {
  final double distanceCm;
  final double accuracy;
  final DateTime timestamp;
  final String method;

  DistanceMeasurement({
    required this.distanceCm,
    required this.accuracy,
    required this.timestamp,
    required this.method,
  });

  @override
  String toString() {
    return 'DistanceMeasurement(distance: ${distanceCm.toStringAsFixed(1)}cm, accuracy: ±${accuracy.toStringAsFixed(1)}cm, method: $method)';
  }
}

/// Abstract base class for distance measurement services
abstract class DistanceMeasurementService {
  /// Initialize the service
  Future<void> initialize();

  /// Start measuring distance
  Stream<DistanceMeasurement> startMeasuring();

  /// Stop measuring distance
  void stopMeasuring();

  /// Dispose resources
  void dispose();

  /// Check if service is available
  Future<bool> isAvailable();
}

/// Face detection-based distance measurement service
/// Uses interpupillary distance (IPD) to calculate distance from camera
class FaceDetectionDistanceService extends DistanceMeasurementService {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isDisposed = false;
  bool _isProcessing = false;
  bool _isMeasuring = false;
  StreamController<DistanceMeasurement>? _streamController;
  Timer? _processingTimer;

  // Smoothing parameters
  double _smoothedDistance = 0.0;
  static const double _smoothingAlpha =
      0.3; // Exponential moving average factor

  // Face detection parameters
  static const double _averageIPDCm =
      6.3; // Average adult interpupillary distance in cm
  static const int _processingIntervalMs = 200; // Process frame every 200ms

  // Error tracking
  int _consecutiveErrors = 0;
  static const int _maxConsecutiveErrors = 10;

  @override
  Future<bool> isAvailable() async {
    try {
      final cameras = await availableCameras();
      return cameras.any(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    } catch (e) {
      debugPrint('Error checking camera availability: $e');
      return false;
    }
  }

  @override
  Future<void> initialize() async {
    if (_isDisposed) {
      throw StateError('Service has been disposed');
    }

    try {
      debugPrint('Initializing FaceDetectionDistanceService...');

      // Initialize face detector first
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableLandmarks: true,
          enableContours: false,
          enableClassification: false,
          minFaceSize: 0.15,
          performanceMode: FaceDetectorMode.fast,
        ),
      );
      debugPrint('Face detector initialized');

      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      // Find front camera
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      debugPrint('Using camera: ${frontCamera.name}');

      // Create camera controller
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium, // 640x480 for performance
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      // Initialize camera
      await _cameraController!.initialize();

      // Check if disposed during initialization
      if (_isDisposed) {
        await _cleanupCamera();
        throw StateError('Disposed during initialization');
      }

      debugPrint('Camera initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('Error initializing camera: $e');
      debugPrint('Stack trace: $stackTrace');
      await _cleanupAll();
      rethrow;
    }
  }

  @override
  Stream<DistanceMeasurement> startMeasuring() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      throw StateError('Camera not initialized. Call initialize() first.');
    }

    if (_isMeasuring) {
      throw StateError('Already measuring. Call stopMeasuring() first.');
    }

    debugPrint('Starting distance measurement...');
    _isMeasuring = true;
    _consecutiveErrors = 0;
    _streamController = StreamController<DistanceMeasurement>.broadcast(
      onCancel: () {
        debugPrint('Stream cancelled');
        stopMeasuring();
      },
    );

    _startProcessingLoop();
    return _streamController!.stream;
  }

  void _startProcessingLoop() {
    _processingTimer?.cancel();

    _processingTimer = Timer.periodic(
      Duration(milliseconds: _processingIntervalMs),
      (timer) async {
        if (_isDisposed ||
            !_isMeasuring ||
            _streamController == null ||
            _streamController!.isClosed) {
          timer.cancel();
          return;
        }

        if (_isProcessing) {
          return; // Skip this iteration if still processing
        }

        if (_consecutiveErrors >= _maxConsecutiveErrors) {
          debugPrint('Too many consecutive errors, stopping measurement');
          timer.cancel();
          _streamController?.addError('Too many consecutive errors');
          stopMeasuring();
          return;
        }

        _isProcessing = true;

        try {
          final measurement = await _processFrame();
          if (measurement != null &&
              _streamController != null &&
              !_streamController!.isClosed) {
            _streamController!.add(measurement);
            _consecutiveErrors = 0; // Reset error counter on success
          }
        } catch (e) {
          _consecutiveErrors++;
          debugPrint(
            'Error processing frame ($_consecutiveErrors/$_maxConsecutiveErrors): $e',
          );
        } finally {
          _isProcessing = false;
        }
      },
    );
  }

  Future<DistanceMeasurement?> _processFrame() async {
    if (_cameraController == null ||
        _faceDetector == null ||
        _isDisposed ||
        !_cameraController!.value.isInitialized) {
      return null;
    }

    XFile? imageFile;

    try {
      // Capture image
      imageFile = await _cameraController!.takePicture();

      // Create input image
      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);

      // Process image with face detector
      final List<Face> faces = await _faceDetector!.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;
        final distance = _calculateDistanceFromFace(face);

        if (distance > 0) {
          // Apply exponential moving average for smoothing
          if (_smoothedDistance == 0.0) {
            _smoothedDistance = distance;
          } else {
            _smoothedDistance =
                _smoothingAlpha * distance +
                (1 - _smoothingAlpha) * _smoothedDistance;
          }

          return DistanceMeasurement(
            distanceCm: _smoothedDistance,
            accuracy: 15.0, // ±15cm accuracy for face detection
            timestamp: DateTime.now(),
            method: 'face_detection',
          );
        }
      }

      return null;
    } catch (e) {
      debugPrint('Frame processing error: $e');
      return null;
    } finally {
      // Clean up image file
      if (imageFile != null) {
        try {
          final file = File(imageFile.path);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          debugPrint('Error deleting temporary image: $e');
        }
      }
    }
  }

  /// Calculate distance from face using interpupillary distance (IPD)
  /// Formula: distance = (realIPD × focalLength) / pixelIPD
  double _calculateDistanceFromFace(Face face) {
    try {
      // Get left and right eye landmarks
      final leftEye = face.landmarks[FaceLandmarkType.leftEye];
      final rightEye = face.landmarks[FaceLandmarkType.rightEye];

      if (leftEye == null || rightEye == null) {
        return -1.0;
      }

      // Calculate pixel distance between eyes (IPD in pixels)
      final dx = leftEye.position.x - rightEye.position.x;
      final dy = leftEye.position.y - rightEye.position.y;
      final pixelIPD = math.sqrt(dx * dx + dy * dy);

      if (pixelIPD <= 0) {
        return -1.0;
      }

      // Get camera focal length in pixels
      // For typical smartphone front cameras, focal length ~1.5-2.0mm
      // Sensor width ~3.6mm, image width typically 640px
      // Focal length in pixels = (focal_length_mm / sensor_width_mm) * image_width_px
      // Approximate: focal_length_px ≈ 500-700 for front cameras
      const double focalLengthPixels = 600.0; // Average estimate

      // Calculate distance in cm
      // distance = (realIPD_cm × focalLength_px) / pixelIPD_px
      final distanceCm = (_averageIPDCm * focalLengthPixels) / pixelIPD;

      // Sanity check: distance should be between 10cm and 500cm
      if (distanceCm < 10 || distanceCm > 500) {
        return -1.0;
      }

      return distanceCm;
    } catch (e) {
      debugPrint('Distance calculation error: $e');
      return -1.0;
    }
  }

  @override
  void stopMeasuring() {
    if (!_isMeasuring) return;

    debugPrint('Stopping distance measurement...');
    _isMeasuring = false;
    _processingTimer?.cancel();
    _processingTimer = null;

    try {
      _streamController?.close();
    } catch (e) {
      debugPrint('Error closing stream controller: $e');
    }
    _streamController = null;
  }

  Future<void> _cleanupCamera() async {
    try {
      if (_cameraController != null) {
        if (_cameraController!.value.isInitialized) {
          await _cameraController!.dispose();
        }
        _cameraController = null;
        debugPrint('Camera disposed');
      }
    } catch (e) {
      debugPrint('Error disposing camera: $e');
    }
  }

  Future<void> _cleanupFaceDetector() async {
    try {
      if (_faceDetector != null) {
        await _faceDetector!.close();
        _faceDetector = null;
        debugPrint('Face detector closed');
      }
    } catch (e) {
      debugPrint('Error closing face detector: $e');
    }
  }

  Future<void> _cleanupAll() async {
    await _cleanupFaceDetector();
    await _cleanupCamera();
  }

  @override
  void dispose() {
    if (_isDisposed) return;

    debugPrint('Disposing FaceDetectionDistanceService...');
    _isDisposed = true;

    stopMeasuring();
    _cleanupAll();
  }

  /// Get camera controller for preview
  CameraController? get cameraController => _cameraController;

  /// Check if currently measuring
  bool get isMeasuring => _isMeasuring;

  /// Check if disposed
  bool get isDisposed => _isDisposed;
}
