import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/physics_experiment.dart';

// ═════════════════════════════════════════════════════════════════
//  PHYSICS PAINTER — Kinematic Simulation Renderer
// ═════════════════════════════════════════════════════════════════

/// Renders a 2D physics simulation canvas with:
/// - Coordinate grid with labeled axes
/// - Cannon/launcher at the origin
/// - Dotted trajectory preview
/// - Solid trajectory trace up to current time
/// - Animated projectile ball
/// - Velocity vector arrow
/// - Max-height / range annotations
class PhysicsPainter extends CustomPainter {
  final PhysicsExperiment experiment;
  final double currentTime;
  final bool isLaunched;
  final bool isComplete;
  final List<Offset> tracePoints; // Accumulated screen-space trace

  PhysicsPainter({
    required this.experiment,
    required this.currentTime,
    required this.isLaunched,
    required this.isComplete,
    required this.tracePoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ─── Coordinate System ───
    // Origin at bottom-left with padding
    const padL = 50.0;
    const padR = 20.0;
    const padTop = 30.0;
    const padBot = 40.0;
    final plotW = w - padL - padR;
    final plotH = h - padTop - padBot;
    final originX = padL;
    final originY = h - padBot;

    // Determine scale from experiment range/height
    final maxX = experiment.range > 0 ? experiment.range * 1.15 : 100.0;
    final maxY = experiment.maxHeight > 0 ? experiment.maxHeight * 1.3 : 50.0;
    final scaleX = plotW / maxX;
    final scaleY = plotH / maxY;

    // Convert physics coords → screen coords
    Offset toScreen(double x, double y) {
      return Offset(originX + x * scaleX, originY - y * scaleY);
    }

    // ─── 1. Grid ───
    _drawGrid(canvas, size, originX, originY, plotW, plotH, maxX, maxY);

    // ─── 2. Ground Line ───
    final groundPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(originX, originY),
      Offset(originX + plotW, originY),
      groundPaint,
    );

    // Ground fill
    final groundFill = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, originY),
        Offset(0, h),
        [const Color(0x202E7D32), Colors.transparent],
      );
    canvas.drawRect(
        Rect.fromLTRB(originX, originY, originX + plotW, h), groundFill);

    // ─── 3. Trajectory Preview (dotted) ───
    if (experiment.timeOfFlight > 0) {
      final previewPaint = Paint()
        ..color = isLaunched
            ? const Color(0x20FFFFFF)
            : const Color(0x40FFD54F)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      final trajectory = experiment.generateTrajectory(steps: 80);
      final previewPath = Path();
      bool started = false;

      for (final p in trajectory) {
        final sp = toScreen(p.x, p.y);
        if (!started) {
          previewPath.moveTo(sp.dx, sp.dy);
          started = true;
        } else {
          previewPath.lineTo(sp.dx, sp.dy);
        }
      }

      // Dash effect approximation
      canvas.drawPath(
        _dashPath(previewPath, 6.0, 4.0),
        previewPaint,
      );

      // ─── Max Height indicator ───
      if (experiment.maxHeight > 0.5) {
        final maxHPos = toScreen(
            experiment.xAt(experiment.timeAtMaxHeight), experiment.maxHeight);
        final dashPaint = Paint()
          ..color = const Color(0x30FF9800)
          ..strokeWidth = 1.0;
        canvas.drawLine(
          Offset(originX, maxHPos.dy),
          Offset(maxHPos.dx, maxHPos.dy),
          dashPaint,
        );

        // Label
        _drawLabel(
          canvas,
          '${experiment.maxHeight.toStringAsFixed(1)} m',
          Offset(originX + 4, maxHPos.dy - 14),
          const Color(0xCCFF9800),
          fontSize: 9,
        );
      }

      // ─── Range indicator ───
      if (experiment.range > 0.5) {
        final rangePt = toScreen(experiment.range, 0);
        final rangeDash = Paint()
          ..color = const Color(0x3000BCD4)
          ..strokeWidth = 1.0;
        canvas.drawLine(
          Offset(rangePt.dx, originY),
          Offset(rangePt.dx, originY + 8),
          rangeDash,
        );
        _drawLabel(
          canvas,
          '${experiment.range.toStringAsFixed(1)} m',
          Offset(rangePt.dx - 16, originY + 10),
          const Color(0xCC00BCD4),
          fontSize: 9,
        );
      }
    }

    // ─── 4. Cannon / Launcher ───
    _drawCannon(canvas, originX, originY, experiment.angleRad);

    // ─── 5. Trajectory Trace (solid) ───
    if (tracePoints.length > 1) {
      final tracePaint = Paint()
        ..shader = ui.Gradient.linear(
          tracePoints.first,
          tracePoints.last,
          [const Color(0xFFFF9800), const Color(0xFFFF5722)],
        )
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final tracePath = Path()..moveTo(tracePoints.first.dx, tracePoints.first.dy);
      for (int i = 1; i < tracePoints.length; i++) {
        tracePath.lineTo(tracePoints[i].dx, tracePoints[i].dy);
      }
      canvas.drawPath(tracePath, tracePaint);
    }

    // ─── 6. Projectile Ball ───
    if (isLaunched && currentTime > 0) {
      final px = experiment.xAt(currentTime);
      final py = experiment.yAt(currentTime);
      final screenPos = toScreen(px, py);

      // Glow
      final glowPaint = Paint()
        ..color = const Color(0x40FF5722)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(screenPos, 12, glowPaint);

      // Ball
      final ballGrad = Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFFFFAB40), const Color(0xFFFF5722)],
        ).createShader(Rect.fromCircle(center: screenPos, radius: 8));
      canvas.drawCircle(screenPos, 8, ballGrad);

      // Highlight
      final highlightPaint = Paint()
        ..color = const Color(0x60FFFFFF);
      canvas.drawCircle(
        Offset(screenPos.dx - 2, screenPos.dy - 2),
        3,
        highlightPaint,
      );

      // ─── 7. Velocity Vector ───
      if (!isComplete) {
        final vx = experiment.vxAt(currentTime);
        final vy = experiment.vyAt(currentTime);
        final speed = experiment.speedAt(currentTime);
        if (speed > 0.5) {
          final arrowLen = 35.0 * (speed / experiment.initialVelocity).clamp(0.3, 1.0);
          final arrowEnd = Offset(
            screenPos.dx + (vx / speed) * arrowLen,
            screenPos.dy - (vy / speed) * arrowLen,
          );

          final arrowPaint = Paint()
            ..color = const Color(0xCC4FC3F7)
            ..strokeWidth = 2.0
            ..strokeCap = StrokeCap.round;

          canvas.drawLine(screenPos, arrowEnd, arrowPaint);

          // Arrow head
          final headAngle = atan2(
            -(vy / speed) * arrowLen,
            (vx / speed) * arrowLen,
          );
          final headLen = 8.0;
          final head1 = Offset(
            arrowEnd.dx - headLen * cos(headAngle - 0.4),
            arrowEnd.dy - headLen * sin(headAngle - 0.4),
          );
          final head2 = Offset(
            arrowEnd.dx - headLen * cos(headAngle + 0.4),
            arrowEnd.dy - headLen * sin(headAngle + 0.4),
          );
          canvas.drawLine(arrowEnd, head1, arrowPaint);
          canvas.drawLine(arrowEnd, head2, arrowPaint);
        }
      }
    }

    // ─── 8. Completion marker ───
    if (isComplete && experiment.range > 0) {
      final landPos = toScreen(experiment.range, 0);
      final markerPaint = Paint()
        ..color = const Color(0x604CAF50)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(landPos, 6, markerPaint);
      canvas.drawCircle(
        landPos,
        6,
        Paint()
          ..color = const Color(0xFF4CAF50)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  // ─── Grid Drawing ───

  void _drawGrid(Canvas canvas, Size size, double originX, double originY,
      double plotW, double plotH, double maxX, double maxY) {
    final gridPaint = Paint()
      ..color = const Color(0x0AFFFFFF)
      ..strokeWidth = 0.5;

    // Determine nice grid spacing
    final xStep = _niceStep(maxX, 6);
    final yStep = _niceStep(maxY, 5);

    // Vertical grid lines
    for (double x = xStep; x < maxX; x += xStep) {
      final sx = originX + (x / maxX) * plotW;
      canvas.drawLine(Offset(sx, originY), Offset(sx, originY - plotH), gridPaint);
      _drawLabel(canvas, '${x.toInt()}', Offset(sx - 8, originY + 6),
          const Color(0x60FFFFFF),
          fontSize: 8);
    }

    // Horizontal grid lines
    for (double y = yStep; y < maxY; y += yStep) {
      final sy = originY - (y / maxY) * plotH;
      canvas.drawLine(Offset(originX, sy), Offset(originX + plotW, sy), gridPaint);
      _drawLabel(canvas, '${y.toInt()}', Offset(originX - 28, sy - 5),
          const Color(0x60FFFFFF),
          fontSize: 8);
    }

    // Axes
    final axisPaint = Paint()
      ..color = const Color(0x30FFFFFF)
      ..strokeWidth = 1.0;
    canvas.drawLine(
        Offset(originX, originY), Offset(originX, originY - plotH), axisPaint);
    canvas.drawLine(
        Offset(originX, originY), Offset(originX + plotW, originY), axisPaint);

    // Axis labels
    _drawLabel(canvas, 'x (m)', Offset(originX + plotW - 24, originY + 20),
        const Color(0x80FFFFFF),
        fontSize: 9);
    _drawLabel(canvas, 'y (m)', Offset(originX - 30, originY - plotH - 2),
        const Color(0x80FFFFFF),
        fontSize: 9);
  }

  // ─── Cannon ───

  void _drawCannon(
      Canvas canvas, double originX, double originY, double angleRad) {
    canvas.save();
    canvas.translate(originX, originY);

    // Base
    final basePaint = Paint()
      ..color = const Color(0xFF455A64)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(-10, -6, 20, 12), const Radius.circular(3)),
      basePaint,
    );

    // Barrel (rotated)
    canvas.rotate(-angleRad);
    final barrelPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        const Offset(32, 0),
        [const Color(0xFF607D8B), const Color(0xFF37474F)],
      );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, -5, 32, 10), const Radius.circular(2)),
      barrelPaint,
    );

    // Barrel opening
    final muzzlePaint = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(32, 0), 5, muzzlePaint);

    canvas.restore();
  }

  // ─── Helpers ───

  void _drawLabel(Canvas canvas, String text, Offset position, Color color,
      {double fontSize = 10}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontFamily: 'monospace'),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, position);
  }

  double _niceStep(double range, int targetTicks) {
    if (range <= 0) return 10;
    final rough = range / targetTicks;
    final pow10 = pow(10, (log(rough) / ln10).floor()).toDouble();
    final normalized = rough / pow10;

    double niceStep;
    if (normalized < 1.5) {
      niceStep = 1;
    } else if (normalized < 3) {
      niceStep = 2;
    } else if (normalized < 7) {
      niceStep = 5;
    } else {
      niceStep = 10;
    }
    return niceStep * pow10;
  }

  /// Creates a dashed path from a source path.
  Path _dashPath(Path source, double dashLen, double gapLen) {
    final result = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashLen : gapLen;
        final end = (distance + len).clamp(0.0, metric.length);
        if (draw) {
          result.addPath(metric.extractPath(distance, end), Offset.zero);
        }
        distance = end;
        draw = !draw;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant PhysicsPainter old) =>
      old.currentTime != currentTime ||
      old.isLaunched != isLaunched ||
      old.isComplete != isComplete ||
      old.tracePoints.length != tracePoints.length ||
      old.experiment.angle != experiment.angle ||
      old.experiment.initialVelocity != experiment.initialVelocity ||
      old.experiment.gravity != experiment.gravity;
}
