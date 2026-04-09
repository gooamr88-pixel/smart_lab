import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/lab_item.dart';

// ═════════════════════════════════════════════════════════════════
//  BUBBLE PARTICLE
// ═════════════════════════════════════════════════════════════════

/// A single bubble in the reaction particle system.
class Bubble {
  double x;        // 0.0–1.0 horizontal position
  double y;        // 0.0–1.0 vertical position (0 = top, 1 = bottom)
  double radius;   // pixel radius
  double speed;    // rise speed per tick
  double wobble;   // horizontal oscillation phase
  double opacity;  // 0.0–1.0

  Bubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.wobble,
    required this.opacity,
  });
}

// ═════════════════════════════════════════════════════════════════
//  REACTION VESSEL — StatefulWidget with Animation
// ═════════════════════════════════════════════════════════════════

/// Interactive beaker vessel that renders liquid, bubbles, and reactions
/// using [CustomPainter].
///
/// Automatically animates liquid level changes, color transitions,
/// and bubble particles when items are added.
class ReactionVessel extends StatefulWidget {
  /// Items currently inside the vessel
  final List<LabItem> contents;

  /// Active chemical reaction (null if no reaction)
  final ChemReaction? reaction;

  /// The liquid fill level: 0.0 = empty, 1.0 = full
  final double fillLevel;

  const ReactionVessel({
    super.key,
    required this.contents,
    this.reaction,
    this.fillLevel = 0.0,
  });

  @override
  State<ReactionVessel> createState() => _ReactionVesselState();
}

class _ReactionVesselState extends State<ReactionVessel>
    with TickerProviderStateMixin {
  // ─── Animation Controllers ───
  late AnimationController _waveController;
  late AnimationController _bubbleController;
  late AnimationController _colorController;
  late AnimationController _heatController;

  // ─── Animated Values ───
  late Animation<double> _fillAnim;
  late Animation<Color?> _colorAnim;

  // ─── Particle System ───
  final List<Bubble> _bubbles = [];
  final Random _rng = Random();

  Color _currentColor = Colors.transparent;
  Color _targetColor = Colors.transparent;
  double _currentFill = 0.0;

  @override
  void initState() {
    super.initState();

    // Wave animation — continuous sine wave on liquid surface
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Bubble tick — drives particle system updates
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(_updateBubbles);

    // Liquid color transition
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Heat glow pulse
    _heatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fillAnim = AlwaysStoppedAnimation(widget.fillLevel);
    _colorAnim = AlwaysStoppedAnimation(_currentColor);

    _syncState();
  }

  @override
  void didUpdateWidget(covariant ReactionVessel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect changes that need animation
    if (widget.fillLevel != oldWidget.fillLevel ||
        widget.contents.length != oldWidget.contents.length ||
        widget.reaction != oldWidget.reaction) {
      _syncState();
    }
  }

  /// Synchronizes the animation state with current widget properties.
  void _syncState() {
    // ─── Fill Level Animation ───
    final oldFill = _currentFill;
    _currentFill = widget.fillLevel;

    _fillAnim = Tween<double>(begin: oldFill, end: _currentFill).animate(
      CurvedAnimation(
        parent: _colorController,
        curve: Curves.easeOutCubic,
      ),
    );

    // ─── Color Animation ───
    _targetColor = _computeLiquidColor();
    _colorAnim = ColorTween(begin: _currentColor, end: _targetColor).animate(
      CurvedAnimation(
        parent: _colorController,
        curve: Curves.easeInOut,
      ),
    );
    _colorController.forward(from: 0).then((_) {
      _currentColor = _targetColor;
    });

    // ─── Bubble System ───
    if (widget.reaction != null) {
      _startBubbles(widget.reaction!.bubbleIntensity);
      if (widget.reaction!.heatIntensity > 0) {
        _heatController.repeat(reverse: true);
      }
    } else if (widget.contents.isNotEmpty) {
      _startBubbles(0.15); // Gentle bubbles when items added
    } else {
      _stopBubbles();
      _heatController.stop();
    }
  }

  /// Computes the liquid color by blending all contents.
  Color _computeLiquidColor() {
    if (widget.reaction != null) return widget.reaction!.resultColor;

    final liquids = widget.contents.where((i) => i.isLiquid).toList();
    if (liquids.isEmpty) {
      // Non-liquids added: faint gray
      return widget.contents.isNotEmpty
          ? const Color(0x33B0BEC5)
          : Colors.transparent;
    }

    // Blend all liquid colors
    Color result = liquids.first.color;
    for (int i = 1; i < liquids.length; i++) {
      result = Color.lerp(result, liquids[i].color, 0.5)!;
    }
    return result;
  }

  // ─── Bubble Particle System ───

  void _startBubbles(double intensity) {
    _bubbles.clear();
    final count = (intensity * 25).toInt().clamp(3, 30);
    for (int i = 0; i < count; i++) {
      _bubbles.add(_createBubble());
    }
    if (!_bubbleController.isAnimating) {
      _bubbleController.repeat();
    }
  }

  void _stopBubbles() {
    _bubbles.clear();
    _bubbleController.stop();
  }

  Bubble _createBubble() {
    return Bubble(
      x: 0.2 + _rng.nextDouble() * 0.6, // Stay within vessel walls
      y: 0.8 + _rng.nextDouble() * 0.2,  // Start near bottom
      radius: 1.5 + _rng.nextDouble() * 3.5,
      speed: 0.005 + _rng.nextDouble() * 0.015,
      wobble: _rng.nextDouble() * pi * 2,
      opacity: 0.3 + _rng.nextDouble() * 0.5,
    );
  }

  void _updateBubbles() {
    if (_bubbles.isEmpty) return;

    setState(() {
      for (int i = _bubbles.length - 1; i >= 0; i--) {
        final b = _bubbles[i];
        b.y -= b.speed;
        b.x += sin(b.wobble) * 0.002;
        b.wobble += 0.15;
        b.opacity *= 0.998;

        // Recycle bubble when it reaches the surface or fades out
        final surfaceY = 1.0 - _currentFill;
        if (b.y <= surfaceY || b.opacity < 0.05) {
          _bubbles[i] = _createBubble();
        }
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _bubbleController.dispose();
    _colorController.dispose();
    _heatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _waveController,
        _colorController,
        _heatController,
      ]),
      builder: (context, child) {
        return CustomPaint(
          painter: ReactionPainter(
            fillLevel: _fillAnim.value,
            liquidColor: _colorAnim.value ?? Colors.transparent,
            wavePhase: _waveController.value * pi * 2,
            bubbles: _bubbles,
            heatGlow: widget.reaction != null
                ? widget.reaction!.heatIntensity *
                    (0.5 + 0.5 * sin(_heatController.value * pi * 2))
                : 0.0,
            isEmpty: widget.contents.isEmpty,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  REACTION PAINTER — CustomPainter
// ═════════════════════════════════════════════════════════════════

/// Custom painter that renders the beaker vessel with:
/// - Glass beaker outline with graduation marks
/// - Animated liquid fill with wave surface
/// - Rising bubble particles
/// - Exothermic heat glow effect
class ReactionPainter extends CustomPainter {
  final double fillLevel;
  final Color liquidColor;
  final double wavePhase;
  final List<Bubble> bubbles;
  final double heatGlow;
  final bool isEmpty;

  ReactionPainter({
    required this.fillLevel,
    required this.liquidColor,
    required this.wavePhase,
    required this.bubbles,
    required this.heatGlow,
    required this.isEmpty,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Beaker dimensions — slightly tapered
    final beakerLeft = w * 0.15;
    final beakerRight = w * 0.85;
    final beakerTop = h * 0.08;
    final beakerBottom = h * 0.88;
    final beakerWidth = beakerRight - beakerLeft;
    final beakerHeight = beakerBottom - beakerTop;

    // Lip (wider top)
    final lipLeft = beakerLeft - w * 0.03;
    final lipRight = beakerRight + w * 0.03;
    final lipTop = beakerTop - h * 0.02;

    // ─── 1. Heat Glow (behind everything) ───
    if (heatGlow > 0.05) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFF6F00).withAlpha((heatGlow * 50).toInt()),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCenter(
          center: Offset(w * 0.5, beakerBottom),
          width: beakerWidth * 1.5,
          height: beakerHeight * 0.8,
        ));
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), glowPaint);
    }

    // ─── 2. Beaker Glass Body ───
    final glassPaint = Paint()
      ..color = const Color(0x15FFFFFF)
      ..style = PaintingStyle.fill;

    final glassPath = Path()
      ..moveTo(lipLeft, lipTop)
      ..lineTo(beakerLeft, beakerTop)
      ..lineTo(beakerLeft, beakerBottom)
      ..quadraticBezierTo(
          beakerLeft, beakerBottom + h * 0.04,
          beakerLeft + beakerWidth * 0.15, beakerBottom + h * 0.04)
      ..lineTo(beakerRight - beakerWidth * 0.15, beakerBottom + h * 0.04)
      ..quadraticBezierTo(
          beakerRight, beakerBottom + h * 0.04,
          beakerRight, beakerBottom)
      ..lineTo(beakerRight, beakerTop)
      ..lineTo(lipRight, lipTop)
      ..close();

    canvas.drawPath(glassPath, glassPaint);

    // ─── 3. Liquid Fill ───
    if (fillLevel > 0.01 && (liquidColor.a * 255).round() > 0) {
      final liquidTop = beakerBottom - (fillLevel * beakerHeight);

      // Wave path at liquid surface
      final liquidPath = Path();
      liquidPath.moveTo(beakerLeft, beakerBottom);

      // Bottom curve
      liquidPath.lineTo(beakerLeft,
          beakerBottom + (beakerBottom + h * 0.04 - beakerBottom) * 0.5);
      liquidPath.quadraticBezierTo(
          beakerLeft, beakerBottom + h * 0.04,
          beakerLeft + beakerWidth * 0.15, beakerBottom + h * 0.04);
      liquidPath.lineTo(
          beakerRight - beakerWidth * 0.15, beakerBottom + h * 0.04);
      liquidPath.quadraticBezierTo(
          beakerRight, beakerBottom + h * 0.04,
          beakerRight, beakerBottom);

      // Right wall up to liquid level
      liquidPath.lineTo(beakerRight, liquidTop);

      // Wavy surface
      final waveAmplitude = fillLevel > 0.1 ? h * 0.008 : 0.0;
      final segments = 20;
      for (int i = segments; i >= 0; i--) {
        final t = i / segments;
        final px = beakerLeft + t * beakerWidth;
        final py = liquidTop +
            sin(wavePhase + t * pi * 4) * waveAmplitude +
            cos(wavePhase * 1.3 + t * pi * 2) * waveAmplitude * 0.5;
        liquidPath.lineTo(px, py);
      }

      liquidPath.close();

      // Gradient fill
      final liquidPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            liquidColor.withAlpha(((liquidColor.a * 255).round() * 0.7).toInt()),
            liquidColor,
            liquidColor.withAlpha(((liquidColor.a * 255).round() * 0.9).toInt()),
          ],
        ).createShader(Rect.fromLTRB(
            beakerLeft, liquidTop, beakerRight, beakerBottom + h * 0.04));

      canvas.drawPath(liquidPath, liquidPaint);

      // ─── 4. Bubbles ───
      for (final b in bubbles) {
        if (b.y < (1.0 - fillLevel)) continue; // Only draw inside liquid

        final bx = beakerLeft + b.x * beakerWidth;
        final by = beakerTop + b.y * beakerHeight;

        // Bubble body
        final bubblePaint = Paint()
          ..color = Colors.white.withAlpha((b.opacity * 180).toInt())
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(bx, by), b.radius, bubblePaint);

        // Bubble highlight
        final highlightPaint = Paint()
          ..color = Colors.white.withAlpha((b.opacity * 80).toInt())
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(bx - b.radius * 0.3, by - b.radius * 0.3),
          b.radius * 0.35,
          highlightPaint,
        );
      }
    }

    // ─── 5. Beaker Outline ───
    final outlinePaint = Paint()
      ..color = const Color(0x40FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Left wall
    canvas.drawLine(
      Offset(beakerLeft, beakerTop),
      Offset(beakerLeft, beakerBottom),
      outlinePaint,
    );
    // Right wall
    canvas.drawLine(
      Offset(beakerRight, beakerTop),
      Offset(beakerRight, beakerBottom),
      outlinePaint,
    );

    // Bottom curve
    final bottomPath = Path()
      ..moveTo(beakerLeft, beakerBottom)
      ..quadraticBezierTo(
          beakerLeft, beakerBottom + h * 0.04,
          beakerLeft + beakerWidth * 0.15, beakerBottom + h * 0.04)
      ..lineTo(beakerRight - beakerWidth * 0.15, beakerBottom + h * 0.04)
      ..quadraticBezierTo(
          beakerRight, beakerBottom + h * 0.04,
          beakerRight, beakerBottom);
    canvas.drawPath(bottomPath, outlinePaint);

    // Lip flare
    final lipPaint = Paint()
      ..color = const Color(0x50FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(lipLeft, lipTop), Offset(beakerLeft, beakerTop), lipPaint);
    canvas.drawLine(Offset(lipRight, lipTop), Offset(beakerRight, beakerTop), lipPaint);

    // ─── 6. Graduation Marks ───
    final markPaint = Paint()
      ..color = const Color(0x20FFFFFF)
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 4; i++) {
      final markY = beakerBottom - (i / 5) * beakerHeight;
      canvas.drawLine(
        Offset(beakerLeft, markY),
        Offset(beakerLeft + beakerWidth * 0.12, markY),
        markPaint,
      );
    }

    // ─── 7. Empty State Label ───
    if (isEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '🧪',
          style: TextStyle(
            fontSize: w * 0.15,
            color: AppColors.textMuted.withAlpha(60),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          (w - textPainter.width) / 2,
          beakerTop + beakerHeight * 0.35,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ReactionPainter old) =>
      old.fillLevel != fillLevel ||
      old.liquidColor != liquidColor ||
      old.wavePhase != wavePhase ||
      old.heatGlow != heatGlow ||
      old.isEmpty != isEmpty ||
      old.bubbles.length != bubbles.length;
}
