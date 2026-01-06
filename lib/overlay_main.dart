import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'gratitude_popup.dart';


// overlayMain has been moved to main.dart

class OverlaySettings extends ChangeNotifier {
  // Defaults tuned to "The Color Science Configuration"
  // Base: 10% (0.10)
  // Grain: 3% variance (approx 0.05-0.10 range for visual texture)
  double _baseOpacity = 0.08;
  double _grainOpacity = 0.19;
  double _tintOpacity = 0.0;

  double get baseOpacity => _baseOpacity;
  double get grainOpacity => _grainOpacity;
  double get tintOpacity => _tintOpacity;

  void update({double? base, double? grain, double? tint}) {
    bool changed = false;
    if (base != null && _baseOpacity != base) {
      _baseOpacity = base;
      changed = true;
    }
    if (grain != null && _grainOpacity != grain) {
      _grainOpacity = grain;
      changed = true;
    }
    if (tint != null && _tintOpacity != tint) {
      _tintOpacity = tint;
      changed = true;
    }
    
    if (changed) {
      notifyListeners();
    }
  }
}

class OverlayApp extends StatefulWidget {
  const OverlayApp({super.key});

  @override
  State<OverlayApp> createState() => _OverlayAppState();
}

class _OverlayAppState extends State<OverlayApp> with SingleTickerProviderStateMixin {
  final OverlaySettings _settings = OverlaySettings();
  static const MethodChannel platform = MethodChannel('paper_vibes/overlay_control');
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _gratitudeTimer;
  bool _showGratitudePopup = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    platform.setMethodCallHandler(_handleMethodCall);
    
    // Add a direct listener that forces setState
    _settings.addListener(() {
      if (mounted) {
        setState(() {});
        // Force a frame
        WidgetsBinding.instance.scheduleFrame();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialSettings();
      _startGratitudeTimer();
    });
  }

  void _startGratitudeTimer() {
    // Schedule the first popup in 1 hour
    _gratitudeTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _triggerGratitudePopup();
    });
  }

  void _triggerGratitudePopup() {
    if (!_showGratitudePopup) {
      _toggleInteraction(true);
      setState(() {
        _showGratitudePopup = true;
      });
    }
  }

  void _closeGratitudePopup() {
    setState(() {
      _showGratitudePopup = false;
    });
    _toggleInteraction(false);
  }

  Future<void> _toggleInteraction(bool enable) async {
    try {
      await platform.invokeMethod('updateInteraction', {'enable': enable});
    } catch (e) {
      debugPrint('Error updating interaction: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _gratitudeTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchInitialSettings() async {
    try {
      final Map<dynamic, dynamic>? initialSettings = await platform.invokeMapMethod('getInitialSettings');
      if (initialSettings != null && mounted) {
        _settings.update(
          base: initialSettings.containsKey('baseOpacity') ? (initialSettings['baseOpacity'] as num).toDouble() : null,
          grain: initialSettings.containsKey('grainOpacity') ? (initialSettings['grainOpacity'] as num).toDouble() : null,
          tint: initialSettings.containsKey('tintOpacity') ? (initialSettings['tintOpacity'] as num).toDouble() : null,
        );
      }
    } catch (e) {
      // Fail silently or log to a proper logging service
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'updateSettings') {
      final Map<dynamic, dynamic> args = call.arguments;
      if (mounted) {
        _settings.update(
          base: args.containsKey('baseOpacity') ? (args['baseOpacity'] as num).toDouble() : null,
          grain: args.containsKey('grainOpacity') ? (args['grainOpacity'] as num).toDouble() : null,
          tint: args.containsKey('tintOpacity') ? (args['tintOpacity'] as num).toDouble() : null,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paper Vibes Overlay',
      debugShowCheckedModeBanner: false,
      home: Material(
        type: MaterialType.transparency,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Original overlay content
              FadeTransition(
                opacity: _animation,
                child: IgnorePointer(
                  ignoring: true,
                  child: AnimatedBuilder(
                    animation: _settings,
                    builder: (context, child) {
                      final baseOpacity = _settings.baseOpacity;
                      final grainOpacity = _settings.grainOpacity;
                      final tintOpacity = _settings.tintOpacity;

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          // 1. Paper Base Tint (The Illuminant)
                          Container(
                            color: const Color(0xFFF8F2E6).withValues(alpha: baseOpacity),
                          ),

                          // 2. Paper Texture / Grain (Tooth + Pulp)
                          Opacity(
                            opacity: grainOpacity,
                            child: Image.asset(
                              'assets/paper_texture.png', 
                              fit: BoxFit.cover,
                              color: const Color(0xFFF8F2E6), // Tint the texture to match the paper
                              // Default blend mode is srcIn, which effectively tints the alpha mask
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox();
                              },
                            ),
                          ),
                          
                          // 3. Warm Tint Overlay (Optional extra warmth)
                          Container(
                            color: const Color(0xFFF8F2E6).withValues(alpha: tintOpacity),
                          )
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Gratitude Popup (Not ignored)
              if (_showGratitudePopup)
                GratitudeJournalPopup(
                  onClose: _closeGratitudePopup,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
