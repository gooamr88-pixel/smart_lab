import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═════════════════════════════════════════════════════════════════
//  XP OVERLAY — Global Imperative API
// ═════════════════════════════════════════════════════════════════

/// Global overlay manager that can show XP gain animations from any screen.
///
/// Usage:
/// ```dart
/// XpOverlay.show(context, amount: 50);
/// XpOverlay.show(context, amount: 100, label: 'Reaction!');
/// XpOverlay.showLevelUp(context, newLevel: 5);
/// ```
///
/// The overlay uses [OverlayEntry] so it floats on top of everything
/// without blocking user interaction.
class XpOverlay {
  XpOverlay._();

  static bool _isShowing = false;

  /// Shows a floating "+[amount] XP" badge that rises, bounces, and fades out.
  ///
  /// [context] — any BuildContext with an active Overlay ancestor.
  /// [amount] — XP earned (displayed in the badge).
  /// [label] — optional contextual label (e.g., "Correct!", "Reaction!").
  /// [emoji] — optional emoji override (default: ⚡).
  static void show(
    BuildContext context, {
    required int amount,
    String? label,
    String emoji = '⚡',
  }) {
    // Don't stack too many — debounce rapid calls
    if (_isShowing) {
      // Queue it with a small delay
      Future.delayed(const Duration(milliseconds: 400), () {
        if (context.mounted) {
          _insertOverlay(context, amount: amount, label: label, emoji: emoji);
        }
      });
      return;
    }
    _insertOverlay(context, amount: amount, label: label, emoji: emoji);
  }

  static void _insertOverlay(
    BuildContext context, {
    required int amount,
    String? label,
    String emoji = '⚡',
  }) {
    final overlay = Overlay.of(context);
    _isShowing = true;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _XpFloatingBadge(
        amount: amount,
        label: label,
        emoji: emoji,
        onComplete: () {
          entry.remove();
          _isShowing = false;
        },
      ),
    );

    overlay.insert(entry);
  }

  /// Shows a full-screen level-up celebration overlay.
  static void showLevelUp(BuildContext context, {required int newLevel}) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _LevelUpCelebration(
        newLevel: newLevel,
        onComplete: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  /// Shows a badge earned notification.
  static void showBadge(BuildContext context, {
    required String name,
    required String emoji,
  }) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _BadgeNotification(
        name: name,
        emoji: emoji,
        onComplete: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

// ═════════════════════════════════════════════════════════════════
//  FLOATING XP BADGE — The "+50 XP" animation
// ═════════════════════════════════════════════════════════════════

class _XpFloatingBadge extends StatefulWidget {
  final int amount;
  final String? label;
  final String emoji;
  final VoidCallback onComplete;

  const _XpFloatingBadge({
    required this.amount,
    this.label,
    required this.emoji,
    required this.onComplete,
  });

  @override
  State<_XpFloatingBadge> createState() => _XpFloatingBadgeState();
}

class _XpFloatingBadgeState extends State<_XpFloatingBadge>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  late Animation<Offset> _position;
  late Animation<double> _glow;

  // Sparkle particles
  final List<_Sparkle> _sparkles = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();

    // ─── Main badge animation (2s total) ───
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Fade: quick in → hold → fade out
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_mainController);

    // Scale: bounce in → settle → shrink out
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.3, end: 1.25)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 25),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.6)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
    ]).animate(_mainController);

    // Float upward
    _position = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -100),
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    ));

    // Glow pulse (first half only)
    _glow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.0), weight: 50),
    ]).animate(_mainController);

    // ─── Particle system ───
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(_updateSparkles);

    // Generate sparkles
    for (int i = 0; i < 12; i++) {
      _sparkles.add(_Sparkle(
        angle: (i / 12) * pi * 2 + _rng.nextDouble() * 0.5,
        distance: 0,
        maxDistance: 30 + _rng.nextDouble() * 40,
        size: 2 + _rng.nextDouble() * 3,
        opacity: 1.0,
        color: [
          const Color(0xFFFFD700),
          const Color(0xFFFFA500),
          const Color(0xFFFFEB3B),
          const Color(0xFFFF9800),
        ][i % 4],
      ));
    }

    _mainController.forward().then((_) => widget.onComplete());
    _particleController.forward();
  }

  void _updateSparkles() {
    setState(() {
      for (final s in _sparkles) {
        s.distance = s.maxDistance * _particleController.value;
        s.opacity = (1.0 - _particleController.value).clamp(0.0, 1.0);
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 80,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _mainController,
          builder: (context, _) {
            return Transform.translate(
              offset: _position.value,
              child: Opacity(
                opacity: _opacity.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: _scale.value,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // ─── Sparkles ───
                        ...(_sparkles.map((s) => Positioned(
                              left: cos(s.angle) * s.distance,
                              top: sin(s.angle) * s.distance,
                              child: Opacity(
                                opacity: s.opacity,
                                child: Container(
                                  width: s.size,
                                  height: s.size,
                                  decoration: BoxDecoration(
                                    color: s.color,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: s.color.withAlpha(100),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ))),

                        // ─── XP Badge ───
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFFD700),
                                Color(0xFFFFA000),
                                Color(0xFFFF8F00),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700)
                                    .withAlpha((_glow.value * 120).toInt()),
                                blurRadius: 24 + _glow.value * 16,
                                spreadRadius: _glow.value * 8,
                              ),
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(widget.emoji,
                                  style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 8),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '+${widget.amount} XP',
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withAlpha(40),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (widget.label != null)
                                    Text(
                                      widget.label!,
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withAlpha(200),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  SPARKLE PARTICLE
// ═════════════════════════════════════════════════════════════════

class _Sparkle {
  final double angle;
  double distance;
  final double maxDistance;
  final double size;
  double opacity;
  final Color color;

  _Sparkle({
    required this.angle,
    required this.distance,
    required this.maxDistance,
    required this.size,
    required this.opacity,
    required this.color,
  });
}

// ═════════════════════════════════════════════════════════════════
//  LEVEL-UP CELEBRATION OVERLAY
// ═════════════════════════════════════════════════════════════════

class _LevelUpCelebration extends StatefulWidget {
  final int newLevel;
  final VoidCallback onComplete;

  const _LevelUpCelebration({
    required this.newLevel,
    required this.onComplete,
  });

  @override
  State<_LevelUpCelebration> createState() => _LevelUpCelebrationState();
}

class _LevelUpCelebrationState extends State<_LevelUpCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<double> _ringScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 35,
      ),
      TweenSequenceItem(
          tween: Tween(begin: 1.2, end: 1.0), weight: 15),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.0), weight: 35),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
    ]).animate(_controller);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 12),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 73),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 15),
    ]).animate(_controller);

    _ringScale = Tween<double>(begin: 0.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return IgnorePointer(
          ignoring: _controller.value > 0.85,
          child: GestureDetector(
            onTap: widget.onComplete,
            child: Opacity(
              opacity: _opacity.value.clamp(0.0, 1.0),
              child: Container(
                color: Colors.black.withAlpha(150),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Expanding ring
                      Transform.scale(
                        scale: _ringScale.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFD700).withAlpha(
                                (60 * (1.0 - (_ringScale.value / 2.5).clamp(0, 1)))
                                    .toInt(),
                              ),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      // Main content
                      Transform.scale(
                        scale: _scale.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🎉',
                                style: TextStyle(fontSize: 56)),
                            const SizedBox(height: 12),
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  const LinearGradient(
                                colors: [
                                  Color(0xFFFFD700),
                                  Color(0xFFFFA000),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'LEVEL UP!',
                                style: GoogleFonts.inter(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFFD700),
                                    Color(0xFFFF8F00),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700)
                                        .withAlpha(100),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${widget.newLevel}',
                                  style: GoogleFonts.inter(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  BADGE NOTIFICATION
// ═════════════════════════════════════════════════════════════════

class _BadgeNotification extends StatefulWidget {
  final String name;
  final String emoji;
  final VoidCallback onComplete;

  const _BadgeNotification({
    required this.name,
    required this.emoji,
    required this.onComplete,
  });

  @override
  State<_BadgeNotification> createState() => _BadgeNotificationState();
}

class _BadgeNotificationState extends State<_BadgeNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slide;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _slide = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: -80.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 25,
      ),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 55),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -80.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_controller);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Positioned(
          top: topPadding + 16 + _slide.value,
          left: 24,
          right: 24,
          child: IgnorePointer(
            child: Opacity(
              opacity: _opacity.value.clamp(0.0, 1.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C4DFF).withAlpha(60),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.emoji,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🏅 New Badge!',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withAlpha(180),
                            ),
                          ),
                          Text(
                            widget.name,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
