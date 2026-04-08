import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

/// A reusable animated gradient background with floating particles
class GradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  final bool showParticles;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.showParticles = true,
  });

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    final random = Random();
    _particles = List.generate(
      20,
      (_) => _Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 4 + 1,
        speed: random.nextDouble() * 0.3 + 0.1,
        opacity: random.nextDouble() * 0.3 + 0.05,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ??
        [AppColors.primaryDark, AppColors.primaryMid, AppColors.primaryLight];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: widget.showParticles
          ? AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(_particles, _controller.value),
                  child: child,
                );
              },
              child: widget.child,
            )
          : widget.child,
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = Colors.white.withAlpha((p.opacity * 255).toInt())
        ..style = PaintingStyle.fill;

      final yPos = (p.y - progress * p.speed) % 1.0;
      canvas.drawCircle(
        Offset(p.x * size.width, yPos * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => oldDelegate.progress != progress;
}
