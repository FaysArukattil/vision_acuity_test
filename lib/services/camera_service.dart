import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

/// Service to manage camera initialization and permissions
class CameraService {
  CameraController? _controller;
  bool _isInitialized = false;

  /// Check if camera permission is granted
  Future<bool> checkPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Request camera permission
  Future<bool> requestPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Initialize front-facing camera
  Future<bool> initializeCamera() async {
    try {
      // Check permission first
      bool hasPermission = await checkPermission();
      if (!hasPermission) {
        hasPermission = await requestPermission();
        if (!hasPermission) {
          return false;
        }
      }

      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        return false;
      }

      // Find front camera
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // Create camera controller with medium resolution for performance
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium, // 640x480
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      return false;
    }
  }

  /// Get camera controller
  CameraController? get controller => _controller;

  /// Check if camera is initialized
  bool get isInitialized => _isInitialized && _controller != null;

  /// Dispose camera resources
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  /// Pause camera preview
  Future<void> pausePreview() async {
    if (_controller != null && _isInitialized) {
      await _controller!.pausePreview();
    }
  }

  /// Resume camera preview
  Future<void> resumePreview() async {
    if (_controller != null && _isInitialized) {
      await _controller!.resumePreview();
    }
  }
}
