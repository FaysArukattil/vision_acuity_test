import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import '../services/distance_measurement_service.dart';
import 'dart:async';

/// Widget that displays camera preview with real-time distance feedback
/// Shows visual indicators (red/green overlays) and countdown timer
/// Updated with more flexible distance tolerance
class DistanceFeedbackWidget extends StatefulWidget {
  final double targetDistanceCm;
  final double toleranceCm;
  final VoidCallback onDistanceConfirmed;
  final Color themeColor;

  const DistanceFeedbackWidget({
    super.key,
    required this.targetDistanceCm,
    required this.toleranceCm,
    required this.onDistanceConfirmed,
    this.themeColor = Colors.blue,
  });

  @override
  State<DistanceFeedbackWidget> createState() => _DistanceFeedbackWidgetState();
}

class _DistanceFeedbackWidgetState extends State<DistanceFeedbackWidget> {
  FaceDetectionDistanceService? _distanceService;
  StreamSubscription<DistanceMeasurement>? _distanceSubscription;
  
  double _currentDistance = 0.0;
  bool _isCorrectDistance = false;
  int _countdownSeconds = 0;
  Timer? _countdownTimer;
  bool _isInitializing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeDistanceService();
  }

  Future<void> _initializeDistanceService() async {
    try {
      _distanceService = FaceDetectionDistanceService();
      
      final isAvailable = await _distanceService!.isAvailable();
      if (!isAvailable) {
        setState(() {
          _errorMessage = 'Front camera not available';
          _isInitializing = false;
        });
        return;
      }

      await _distanceService!.initialize();
      
      // Start measuring distance
      _distanceSubscription = _distanceService!.startMeasuring().listen(
        (measurement) {
          setState(() {
            _currentDistance = measurement.distanceCm;
            _checkDistance();
          });
        },
        onError: (error) {
          setState(() {
            _errorMessage = 'Error measuring distance';
          });
        },
      );

      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
        _isInitializing = false;
      });
    }
  }

  void _checkDistance() {
    // More flexible tolerance based on target distance
    double actualTolerance;
    double minDistance;
    double maxDistance;
    
    if (widget.targetDistanceCm <= 50) {
      // Near distance (40cm): Allow 30-60cm range (more flexible)
      actualTolerance = 20.0; // ±20cm from 40cm = 20-60cm acceptable
      minDistance = widget.targetDistanceCm - actualTolerance;
      maxDistance = widget.targetDistanceCm + actualTolerance;
    } else {
      // Far distance (200cm): Allow 180-250cm range (more flexible)
      actualTolerance = 50.0; // +50cm from 200cm = 150-250cm acceptable
      minDistance = widget.targetDistanceCm - actualTolerance;
      maxDistance = widget.targetDistanceCm + actualTolerance;
    }
    
    final wasCorrect = _isCorrectDistance;
    
    _isCorrectDistance = _currentDistance >= minDistance && 
                        _currentDistance <= maxDistance;

    if (_isCorrectDistance && !wasCorrect) {
      // Just entered correct range - start countdown
      _startCountdown();
      HapticFeedback.mediumImpact(); // Haptic feedback
    } else if (!_isCorrectDistance && wasCorrect) {
      // Left correct range - cancel countdown
      _cancelCountdown();
    }
  }

  void _startCountdown() {
    _countdownSeconds = 3;
    _countdownTimer?.cancel();
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdownSeconds--;
      });
      
      HapticFeedback.selectionClick();
      
      if (_countdownSeconds <= 0) {
        timer.cancel();
        HapticFeedback.heavyImpact();
        widget.onDistanceConfirmed();
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _countdownSeconds = 0;
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _distanceSubscription?.cancel();
    _distanceService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return _buildLoadingScreen();
    }

    if (_errorMessage != null) {
      return _buildErrorScreen();
    }

    return Stack(
      children: [
        // Camera preview
        _buildCameraPreview(),
        
        // Colored overlay with opacity
        _buildColoredOverlay(),
        
        // Distance information
        _buildDistanceInfo(),
        
        // Countdown timer
        if (_countdownSeconds > 0) _buildCountdownTimer(),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isInitializing = true;
                  });
                  _initializeDistanceService();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final cameraController = _distanceService?.cameraController;
    
    if (cameraController == null || !cameraController.value.isInitialized) {
      return Container(color: Colors.black);
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: cameraController.value.previewSize!.height,
          height: cameraController.value.previewSize!.width,
          child: CameraPreview(cameraController),
        ),
      ),
    );
  }

  Widget _buildColoredOverlay() {
    final color = _isCorrectDistance ? Colors.green : Colors.red;
    final opacity = _isCorrectDistance ? 0.2 : 0.3;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: color.withValues(alpha: opacity),
    );
  }

  Widget _buildDistanceInfo() {
    final distanceText = _currentDistance > 0
        ? _currentDistance >= 100
            ? '${(_currentDistance / 100).toStringAsFixed(2)}m'
            : '${_currentDistance.toStringAsFixed(0)}cm'
        : 'Detecting...';

    final targetText = widget.targetDistanceCm >= 100
        ? '${(widget.targetDistanceCm / 100).toStringAsFixed(1)}m'
        : '${widget.targetDistanceCm.toStringAsFixed(0)}cm';

    String feedbackText;
    String rangeText;
    
    if (_currentDistance == 0) {
      feedbackText = 'Position your face in frame';
      rangeText = '';
    } else if (_isCorrectDistance) {
      feedbackText = 'PERFECT DISTANCE ✓';
      if (widget.targetDistanceCm <= 50) {
        rangeText = 'Acceptable: 30-60cm';
      } else {
        rangeText = 'Acceptable: 1.5-2.5m';
      }
    } else if (_currentDistance < widget.targetDistanceCm - (widget.targetDistanceCm <= 50 ? 20 : 50)) {
      feedbackText = 'MOVE BACK';
      if (widget.targetDistanceCm <= 50) {
        rangeText = 'Too close (need 30cm+)';
      } else {
        rangeText = 'Too close (need 1.5m+)';
      }
    } else {
      feedbackText = 'MOVE CLOSER';
      if (widget.targetDistanceCm <= 50) {
        rangeText = 'Too far (max 60cm)';
      } else {
        rangeText = 'Too far (max 2.5m)';
      }
    }

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Feedback text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              feedbackText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Range text
          if (rangeText.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                rangeText,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Current distance
          Text(
            distanceText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Target distance
          Text(
            'Target: $targetText',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const Spacer(),
          // Distance progress indicator
          _buildDistanceProgressBar(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDistanceProgressBar() {
    double minDistance;
    double maxDistance;
    
    if (widget.targetDistanceCm <= 50) {
      // Near: 30-60cm
      minDistance = 30;
      maxDistance = 60;
    } else {
      // Far: 150-250cm
      minDistance = 150;
      maxDistance = 250;
    }
    
    // Calculate progress (0.0 to 1.0)
    double progress = 0.5;
    if (_currentDistance > 0) {
      progress = (_currentDistance - minDistance) / (maxDistance - minDistance);
      progress = progress.clamp(0.0, 1.0);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.arrow_back, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isCorrectDistance ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Too Close ← → Too Far',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownTimer() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$_countdownSeconds',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}