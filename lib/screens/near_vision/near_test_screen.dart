import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/test_provider.dart';
import '../../providers/calibration_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/tumbling_e.dart';
import '../../widgets/distance_feedback_widget.dart';
import '../../widgets/distance_badge_widget.dart';
import '../../services/distance_measurement_service.dart';
import 'near_results_screen.dart';
import 'dart:async';

class NearTestScreen extends StatefulWidget {
  const NearTestScreen({super.key});

  @override
  State<NearTestScreen> createState() => _NearTestScreenState();
}

class _NearTestScreenState extends State<NearTestScreen> {
  bool _hasInitialized = false;
  bool _showDistanceSetup = true; // Phase 1: Distance measurement
  bool _isTestPaused = false; // Pause test if distance incorrect
  Offset? _startPosition;
  bool _swipeHandled = false;

  // Distance monitoring during test
  FaceDetectionDistanceService? _distanceService;
  StreamSubscription<DistanceMeasurement>? _distanceSubscription;
  double _currentDistance = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final calibration = context.read<CalibrationProvider>();
      context.read<TestProvider>().initializeTest(
            testType: 'near',
            distanceMm: VisionConstants.nearDistanceMm,
            pixelsPerMm: calibration.pixelsPerMm ?? 1.0,
            eye: 'both',
          );
      setState(() {
        _hasInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    _distanceSubscription?.cancel();
    _distanceService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Phase 1: Distance setup with camera feedback
    if (_showDistanceSetup) {
      return _buildDistanceSetupScreen();
    }

    // Phase 2: Actual test with distance monitoring
    return _buildTestScreen();
  }

  /// Phase 1: Distance setup screen with camera feedback
  Widget _buildDistanceSetupScreen() {
    return Scaffold(
      body: DistanceFeedbackWidget(
        targetDistanceCm: 40, // 40cm (arm's length)
        toleranceCm: 5,
        themeColor: Colors.green,
        onDistanceConfirmed: () {
          setState(() {
            _showDistanceSetup = false;
          });
          // Start distance monitoring for the test
          _startDistanceMonitoring();
        },
      ),
    );
  }

  /// Phase 2: Test screen with distance monitoring
  Widget _buildTestScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<TestProvider>(
        builder: (context, testProvider, child) {
          // If test is complete, navigate to results
          if (testProvider.isTestComplete) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const NearResultsScreen(),
                ),
              );
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
                        // Progress indicator
                        LinearProgressIndicator(
                          value: testProvider.currentLevelIndex /
                              (testProvider.currentLevelIndex + 3),
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Level info
                        Text(
                          'Level ${testProvider.currentLevelIndex + 1}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
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
                        // Swipe instruction
                        const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            'Swipe in the direction the E is facing',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
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
                  targetDistanceCm: 40,
                  toleranceCm: 5,
                  themeColor: Colors.green,
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
                            'MAINTAIN 40CM DISTANCE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Test paused. Please adjust your distance.',
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
    if (_showDistanceSetup) return;

    final minDistance = 40 - 5; // 35cm
    final maxDistance = 40 + 5; // 45cm
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
