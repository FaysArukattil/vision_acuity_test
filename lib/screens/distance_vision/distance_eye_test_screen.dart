import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/test_provider.dart';
import '../../providers/calibration_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/tumbling_e.dart';
import '../../widgets/distance_feedback_widget.dart';
import '../../widgets/distance_badge_widget.dart';
import '../../services/distance_measurement_service.dart';
import 'distance_results_screen.dart';
import 'dart:async';

class DistanceEyeTestScreen extends StatefulWidget {
  final String eye; // 'left' or 'right'

  const DistanceEyeTestScreen({
    super.key,
    required this.eye,
  });

  @override
  State<DistanceEyeTestScreen> createState() => _DistanceEyeTestScreenState();
}

class _DistanceEyeTestScreenState extends State<DistanceEyeTestScreen> {
  bool _hasInitialized = false;
  bool _showDistanceSetup = true; // Phase 1: Distance measurement
  bool _showPreTest = false; // Phase 2: Eye cover instructions
  bool _isTestPaused = false; // Pause test if distance incorrect
  Offset? _startPosition;
  bool _swipeHandled = false;

  // Distance monitoring during test
  FaceDetectionDistanceService? _distanceService;
  StreamSubscription<DistanceMeasurement>? _distanceSubscription;
  double _currentDistance = 0.0;

  @override
  void dispose() {
    _distanceSubscription?.cancel();
    _distanceService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasInitialized) {
      // Initialize test for this eye
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final calibration = context.read<CalibrationProvider>();
        context.read<TestProvider>().initializeTest(
              testType: 'distance',
              distanceMm: VisionConstants.farDistanceMm,
              pixelsPerMm: calibration.pixelsPerMm ?? 1.0,
              eye: widget.eye,
            );
        setState(() {
          _hasInitialized = true;
        });
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Phase 1: Distance setup with camera feedback
    if (_showDistanceSetup) {
      return _buildDistanceSetupScreen();
    }

    // Phase 2: Pre-test instructions (cover eye)
    if (_showPreTest) {
      return _buildPreTestScreen();
    }

    // Phase 3: Actual test with distance monitoring
    return _buildTestScreen();
  }

  /// Phase 1: Distance setup screen with camera feedback
  Widget _buildDistanceSetupScreen() {
    return Scaffold(
      body: DistanceFeedbackWidget(
        targetDistanceCm: 200, // 2 meters
        toleranceCm: 50, // ±50cm tolerance (will accept 1.5m - 2.5m)
        themeColor: Colors.blue,
        onDistanceConfirmed: () {
          setState(() {
            _showDistanceSetup = false;
            _showPreTest = true;
          });
          // Start distance monitoring for the test
          _startDistanceMonitoring();
        },
      ),
    );
  }

  /// Phase 2: Pre-test screen (cover eye instructions)
  Widget _buildPreTestScreen() {
    final eyeName = widget.eye == 'left' ? 'LEFT' : 'RIGHT';
    final coverEye = widget.eye == 'left' ? 'RIGHT' : 'LEFT';

    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.remove_red_eye,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 32),
              Text(
                'Testing $eyeName Eye',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Cover your $coverEye eye\nKeep your $eyeName eye open',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showPreTest = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Tap to Begin',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Phase 3: Test screen with distance monitoring
  Widget _buildTestScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<TestProvider>(
        builder: (context, testProvider, child) {
          // If test is complete, check if we need to test the other eye
          if (testProvider.isTestComplete) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (widget.eye == 'left') {
                // Move to right eye
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const DistanceEyeTestScreen(eye: 'right'),
                  ),
                );
              } else {
                // Both eyes tested, show results
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DistanceResultsScreen(),
                  ),
                );
              }
            });
          }

          return SafeArea(
            child: Stack(
              children: [
                // Main test UI
                GestureDetector(
                  onPanStart: (details) {
                    if (_isTestPaused) return; // Don't accept swipes when paused
                    _startPosition = details.globalPosition;
                    _swipeHandled = false;
                  },
                  onPanEnd: (details) {
                    if (_isTestPaused) return; // Don't accept swipes when paused
                    
                    // Only process if we haven't handled this swipe yet
                    if (_swipeHandled || _startPosition == null) return;

                    // Calculate total swipe distance from velocity
                    final velocity = details.velocity.pixelsPerSecond;

                    // Require minimum swipe speed to register (prevents accidental taps)
                    if (velocity.distance < 100) return;

                    // Determine swipe direction from velocity
                    int direction;
                    if (velocity.dx.abs() > velocity.dy.abs()) {
                      // Horizontal swipe
                      direction = velocity.dx > 0 ? 0 : 2; // right or left
                    } else {
                      // Vertical swipe
                      direction = velocity.dy > 0 ? 1 : 3; // down or up
                    }

                    // Mark as handled and process
                    _swipeHandled = true;
                    testProvider.handleSwipe(direction);
                    _startPosition = null;
                  },
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        // Header with eye indicator
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          color: Colors.blue.shade700,
                          child: Text(
                            'Testing ${widget.eye.toUpperCase()} Eye',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // Progress indicator
                        LinearProgressIndicator(
                          value: testProvider.currentLevelIndex /
                              (testProvider.currentLevelIndex + 3),
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Level info
                        Text(
                          'Level ${testProvider.currentLevelIndex + 1}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${testProvider.correctAtLevel}/${testProvider.totalAtLevel} correct',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        // Tumbling E
                        TumblingE(
                          size: testProvider.getCurrentOptotypeSize(),
                          direction: testProvider.currentDirection,
                        ),
                        const Spacer(),
                        // Tester instruction
                        const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            'Tester: Swipe based on pointing direction',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Distance badge (bottom-right corner)
                DistanceBadgeWidget(
                  currentDistanceCm: _currentDistance,
                  targetDistanceCm: 200,
                  toleranceCm: 50, // More flexible tolerance
                  themeColor: Colors.blue,
                ),

                // Pause overlay when distance is incorrect
                if (_isTestPaused)
                  Container(
                    color: Colors.black.withValues(alpha: 0.7),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 64),
                          SizedBox(height: 16),
                          Text(
                            'MAINTAIN PROPER DISTANCE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please stay within 1.5m - 2.5m range',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Start distance monitoring during test
  void _startDistanceMonitoring() async {
    try {
      _distanceService = FaceDetectionDistanceService();
      await _distanceService!.initialize();

      _distanceSubscription = _distanceService!.startMeasuring().listen(
        (measurement) {
          setState(() {
            _currentDistance = measurement.distanceCm;
            _checkDistanceDuringTest();
          });
        },
      );
    } catch (e) {
      // Continue without distance monitoring if initialization fails
      debugPrint('Distance monitoring failed: $e');
    }
  }

  /// Check if distance is correct during test and pause if necessary
  void _checkDistanceDuringTest() {
    if (_showDistanceSetup || _showPreTest) return;

    // More flexible tolerance: 150-250cm acceptable (target 200cm ±50cm)
    const minDistance = 150.0; // 1.5m
    const maxDistance = 250.0; // 2.5m
    final isCorrect = _currentDistance >= minDistance &&
        _currentDistance <= maxDistance;

    if (!isCorrect && !_isTestPaused) {
      setState(() {
        _isTestPaused = true;
      });
    } else if (isCorrect && _isTestPaused) {
      setState(() {
        _isTestPaused = false;
      });
    }
  }
}