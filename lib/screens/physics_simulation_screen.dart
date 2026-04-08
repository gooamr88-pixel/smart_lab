import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../providers/locale_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/simulation_widgets.dart';
import '../widgets/model_viewer_widget.dart';
import '../services/model_assets.dart';

/// Physics simulation screen with multiple interactive simulations:
/// 1. Inclined Plane (block on ramp with pulley)
/// 2. Free Fall
/// 3. Pendulum
class PhysicsSimulationScreen extends StatefulWidget {
  const PhysicsSimulationScreen({super.key});

  @override
  State<PhysicsSimulationScreen> createState() => _PhysicsSimulationScreenState();
}

class _PhysicsSimulationScreenState extends State<PhysicsSimulationScreen>
    with TickerProviderStateMixin {
  int _selectedSimIndex = 0;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isArabic = locale.isArabic;

    final simTabs = [
      isArabic ? 'السطح المائل' : 'Inclined Plane',
      isArabic ? 'السقوط الحر' : 'Free Fall',
      isArabic ? 'البندول' : 'Pendulum',
      isArabic ? 'المقذوفات' : 'Projectile',
      isArabic ? 'الموجات' : 'Waves',
    ];

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.read<ProgressProvider>().completeSimulation();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isArabic ? '⚡ +40 XP — أحسنت!' : '⚡ +40 XP — Great job!',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: const Color(0xFFFFD700),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          backgroundColor: AppColors.success,
          icon: const Icon(Icons.check_rounded, color: Colors.white),
          label: Text(
            isArabic ? 'إنتهيت ✓' : 'Done ✓',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: AppColors.surfaceCard,
          title: Text(
            isArabic ? 'محاكاة الفيزياء' : 'Physics Simulation',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.three_p_rounded, color: AppColors.physics),
              tooltip: isArabic ? 'عرض الأبعاد الثلاثية' : '3D View',
              onPressed: () => _show3DViewer(context, isArabic),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Tab selector
            Container(
              height: 50,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: List.generate(simTabs.length, (i) {
                  final selected = i == _selectedSimIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedSimIndex = i),
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryLight.withAlpha(25)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? AppColors.primaryLight.withAlpha(60)
                                : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            simTabs[i],
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected
                                  ? AppColors.primaryLight
                                  : AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Simulation body
            Expanded(
              child: IndexedStack(
                index: _selectedSimIndex,
                children: const [
                  _InclinedPlaneSim(),
                  _FreeFallSim(),
                  _PendulumSim(),
                  _ProjectileMotionSim(),
                  _WavesSim(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _show3DViewer(BuildContext context, bool isArabic) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: Colors.white.withAlpha(20)),
          ),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isArabic ? 'عرض 3D' : '3D View',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 3D Viewer
              Expanded(
                child: ModelViewerWidget(
                  modelUrl: ModelAssets.physicsModel,
                  backgroundColor: AppColors.surfaceCard,
                  alt: isArabic ? 'نموذج فيزياء 3D' : '3D Physics Model',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════
// ═══  INCLINED PLANE SIMULATION  ═══
// ════════════════════════════════════════════════════════

class _InclinedPlaneSim extends StatefulWidget {
  const _InclinedPlaneSim();

  @override
  State<_InclinedPlaneSim> createState() => _InclinedPlaneSimState();
}

class _InclinedPlaneSimState extends State<_InclinedPlaneSim>
    with SingleTickerProviderStateMixin {
  double _mass1 = 2.0;    // block on ramp (kg)
  double _mass2 = 1.0;    // hanging mass (kg)
  double _angle = 30.0;   // ramp angle (degrees)
  double _friction = 0.2; // friction coefficient

  late AnimationController _animController;
  double _blockPosition = 0.0; // 0.0 = top, 1.0 = bottom
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animController.addListener(() {
      setState(() {
        _blockPosition = _animController.value;
      });
    });
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Physics calculations
  double get _angleRad => _angle * pi / 180;
  double get _gravity => 9.81;
  double get _normalForce => _mass1 * _gravity * cos(_angleRad);
  double get _frictionForce => _friction * _normalForce;
  double get _gravityAlongRamp => _mass1 * _gravity * sin(_angleRad);
  double get _hangingWeight => _mass2 * _gravity;
  double get _netForce => _gravityAlongRamp - _frictionForce - _hangingWeight;
  double get _acceleration =>
      _netForce / (_mass1 + _mass2);

  void _play() {
    if (_blockPosition >= 1.0) _reset();
    _isPlaying = true;
    final speed = _acceleration.abs().clamp(0.5, 5.0);
    _animController.duration = Duration(milliseconds: (3000 / speed).toInt());
    _animController.forward(from: _blockPosition);
    setState(() {});
  }

  void _pause() {
    _animController.stop();
    _isPlaying = false;
    setState(() {});
  }

  void _reset() {
    _animController.reset();
    _blockPosition = 0.0;
    _isPlaying = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isArabic = locale.isArabic;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Canvas
          Container(
            height: 280,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(8)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(
                painter: _InclinedPlanePainter(
                  angle: _angle,
                  blockPosition: _blockPosition,
                  mass1: _mass1,
                  mass2: _mass2,
                  normalForce: _normalForce,
                  frictionForce: _frictionForce,
                  gravityForce: _gravityAlongRamp,
                  slidingDown: _netForce > 0,
                ),
              ),
            ),
          ),

          // Readouts
          Row(
            children: [
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'التسارع' : 'Accel',
                  value: _acceleration.toStringAsFixed(2),
                  unit: 'm/s²',
                  color: _acceleration > 0
                      ? AppColors.danger
                      : AppColors.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'القوة المحصلة' : 'Net Force',
                  value: _netForce.toStringAsFixed(1),
                  unit: 'N',
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'قوة الاحتكاك' : 'Friction',
                  value: _frictionForce.toStringAsFixed(1),
                  unit: 'N',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Controls
          SimulationControls(
            isPlaying: _isPlaying,
            onPlay: _play,
            onPause: _pause,
            onReset: _reset,
          ),

          const SizedBox(height: 12),

          // Sliders
          SimulationSlider(
            label: isArabic ? 'الكتلة ١ (الجسم)' : 'Mass 1 (Block)',
            unit: 'kg',
            value: _mass1,
            min: 0.5,
            max: 10,
            activeColor: AppColors.roadmapAi,
            onChanged: (v) => setState(() {
              _mass1 = v;
              if (!_isPlaying) _reset();
            }),
          ),
          SimulationSlider(
            label: isArabic ? 'الكتلة ٢ (المعلقة)' : 'Mass 2 (Hanging)',
            unit: 'kg',
            value: _mass2,
            min: 0.1,
            max: 10,
            activeColor: AppColors.roadmapLab,
            onChanged: (v) => setState(() {
              _mass2 = v;
              if (!_isPlaying) _reset();
            }),
          ),
          SimulationSlider(
            label: isArabic ? 'زاوية الميل' : 'Angle',
            unit: '°',
            value: _angle,
            min: 5,
            max: 80,
            divisions: 75,
            activeColor: AppColors.roadmapQuiz,
            onChanged: (v) => setState(() {
              _angle = v;
              if (!_isPlaying) _reset();
            }),
          ),
          SimulationSlider(
            label: isArabic ? 'معامل الاحتكاك (μ)' : 'Friction (μ)',
            unit: '',
            value: _friction,
            min: 0,
            max: 1,
            divisions: 100,
            activeColor: AppColors.warning,
            onChanged: (v) => setState(() {
              _friction = v;
              if (!_isPlaying) _reset();
            }),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// CustomPainter for the inclined plane visualization
class _InclinedPlanePainter extends CustomPainter {
  final double angle;
  final double blockPosition;
  final double mass1;
  final double mass2;
  final double normalForce;
  final double frictionForce;
  final double gravityForce;
  final bool slidingDown;

  _InclinedPlanePainter({
    required this.angle,
    required this.blockPosition,
    required this.mass1,
    required this.mass2,
    required this.normalForce,
    required this.frictionForce,
    required this.gravityForce,
    required this.slidingDown,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rad = angle * pi / 180;

    // Ground line
    final groundY = h * 0.85;
    final groundPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, groundY), Offset(w, groundY), groundPaint);

    // Ramp
    final rampBaseX = w * 0.15;
    final rampTopX = w * 0.75;
    final rampLength = rampTopX - rampBaseX;
    final rampHeight = rampLength * tan(rad);
    final rampTopY = groundY - rampHeight;

    final rampPath = Path()
      ..moveTo(rampBaseX, groundY)
      ..lineTo(rampTopX, groundY)
      ..lineTo(rampTopX, rampTopY)
      ..close();

    // Ramp fill with hatching
    final rampFillPaint = Paint()
      ..color = const Color(0xFF1E3A5F)
      ..style = PaintingStyle.fill;
    canvas.drawPath(rampPath, rampFillPaint);

    final rampBorderPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(rampPath, rampBorderPaint);

    // Hatching lines on ramp
    final hatchPaint = Paint()
      ..color = const Color(0xFF2A5580)
      ..strokeWidth = 1;
    for (double x = rampBaseX + 10; x < rampTopX; x += 12) {
      final t = (x - rampBaseX) / (rampTopX - rampBaseX);
      final yOnRamp = groundY - rampHeight * t;
      canvas.drawLine(Offset(x, groundY), Offset(x, yOnRamp), hatchPaint);
    }

    // Block on ramp
    final blockSize = 30.0 + mass1 * 2;
    final t = slidingDown ? blockPosition : (1 - blockPosition);
    final blockCenterX = rampTopX - t * (rampTopX - rampBaseX) * 0.7 - blockSize;
    final blockCenterY =
        rampTopY + t * (groundY - rampTopY) * 0.7 - blockSize / 2;

    canvas.save();
    canvas.translate(blockCenterX, blockCenterY);
    canvas.rotate(-rad);

    final blockRect = Rect.fromCenter(
      center: Offset.zero,
      width: blockSize,
      height: blockSize,
    );
    final blockPaint = Paint()..color = const Color(0xFFEAB308);
    final blockBorder = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRect(blockRect, blockPaint);
    canvas.drawRect(blockRect, blockBorder);

    // Force vectors on block
    final arrowScale = 2.0;
    // Normal force (perpendicular to surface, pointing up-left)
    _drawArrow(canvas, Offset.zero, Offset(0, -normalForce * arrowScale),
        const Color(0xFFEF4444), 'FN');

    // Gravity along ramp
    _drawArrow(canvas, Offset.zero,
        Offset(gravityForce * arrowScale, 0),
        const Color(0xFFEF4444), 'Fg');

    // Friction (opposite to motion)
    if (frictionForce > 0.1) {
      _drawArrow(canvas, Offset.zero,
          Offset(-frictionForce * arrowScale, 0),
          const Color(0xFF22C55E), 'f');
    }

    canvas.restore();

    // Pulley at top of ramp
    final pulleyX = rampTopX;
    final pulleyY = rampTopY - 20;
    final pulleyPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(pulleyX, pulleyY), 10, pulleyPaint);
    canvas.drawCircle(
      Offset(pulleyX, pulleyY),
      10,
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Rope from block to pulley to hanging mass
    final ropePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 2;
    // Block to pulley
    canvas.drawLine(
      Offset(blockCenterX, blockCenterY - blockSize / 2),
      Offset(pulleyX, pulleyY),
      ropePaint,
    );
    // Pulley to hanging mass
    final hangY = pulleyY + 40 + blockPosition * 60;
    canvas.drawLine(
      Offset(pulleyX, pulleyY + 10),
      Offset(pulleyX, hangY),
      ropePaint,
    );

    // Hanging mass
    final hangSize = 20.0 + mass2 * 3;
    final hangRect = Rect.fromCenter(
      center: Offset(pulleyX, hangY + hangSize / 2),
      width: hangSize,
      height: hangSize,
    );
    canvas.drawRect(hangRect, Paint()..color = const Color(0xFFFF6B6B));
    canvas.drawRect(
      hangRect,
      Paint()
        ..color = const Color(0xFFEF4444)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Labels
    _drawLabel(canvas, Offset(pulleyX, hangY + hangSize + 16),
        'm₂=${mass2.toStringAsFixed(1)}kg', const Color(0xFFFF6B6B));
    _drawLabel(canvas, Offset(blockCenterX, blockCenterY + blockSize + 8),
        'm₁=${mass1.toStringAsFixed(1)}kg', const Color(0xFFEAB308));

    // Angle arc
    final arcPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withAlpha(120)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(rampTopX, groundY), radius: 40),
      pi,
      -rad,
      false,
      arcPaint,
    );
    _drawLabel(canvas, Offset(rampTopX - 50, groundY - 14),
        '${angle.toStringAsFixed(0)}°', Colors.white);
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Color color, String label) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(from, from + to, paint);

    // Arrowhead
    final dir = to / to.distance;
    final perp = Offset(-dir.dy, dir.dx);
    final tip = from + to;
    final arrowPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - dir.dx * 8 + perp.dx * 4, tip.dy - dir.dy * 8 + perp.dy * 4)
      ..lineTo(tip.dx - dir.dx * 8 - perp.dx * 4, tip.dy - dir.dy * 8 - perp.dy * 4)
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = color..style = PaintingStyle.fill);

    // Label
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, from + to / 2 + Offset(4, -14));
  }

  void _drawLabel(Canvas canvas, Offset pos, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy));
  }

  @override
  bool shouldRepaint(covariant _InclinedPlanePainter old) =>
      old.blockPosition != blockPosition || old.angle != angle ||
      old.mass1 != mass1 || old.mass2 != mass2;
}

// ════════════════════════════════════════════════════════
// ═══  FREE FALL SIMULATION  ═══
// ════════════════════════════════════════════════════════

class _FreeFallSim extends StatefulWidget {
  const _FreeFallSim();

  @override
  State<_FreeFallSim> createState() => _FreeFallSimState();
}

class _FreeFallSimState extends State<_FreeFallSim>
    with SingleTickerProviderStateMixin {
  double _mass = 2.0;
  double _height = 20.0;
  int _gravityIndex = 0; // 0=Earth, 1=Moon, 2=Jupiter
  static const _gravities = [9.81, 1.62, 24.79];
  static const _gravityNames = ['🌍 Earth', '🌙 Moon', '🪐 Jupiter'];

  late AnimationController _animController;
  double _fallPos = 0.0;
  bool _isPlaying = false;

  double get _g => _gravities[_gravityIndex];
  double get _fallTime => sqrt(2 * _height / _g);
  double get _impactVelocity => _g * _fallTime;
  double get _kineticEnergy => 0.5 * _mass * _impactVelocity * _impactVelocity;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {
          // Quadratic easing for realistic acceleration
          _fallPos = _animController.value * _animController.value;
        });
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) setState(() => _isPlaying = false);
      });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _play() {
    if (_fallPos >= 1.0) _reset();
    _isPlaying = true;
    final dur = (_fallTime * 500).clamp(300, 5000).toInt();
    _animController.duration = Duration(milliseconds: dur);
    _animController.forward();
    setState(() {});
  }

  void _pause() {
    _animController.stop();
    _isPlaying = false;
    setState(() {});
  }

  void _reset() {
    _animController.reset();
    _fallPos = 0;
    _isPlaying = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isArabic = locale.isArabic;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Canvas
          Container(
            height: 280,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(8)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(
                painter: _FreeFallPainter(
                  fallPos: _fallPos,
                  mass: _mass,
                  height: _height,
                ),
              ),
            ),
          ),

          // Readouts
          Row(
            children: [
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'زمن السقوط' : 'Fall Time',
                  value: _fallTime.toStringAsFixed(2),
                  unit: 's',
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'سرعة الارتطام' : 'Impact V',
                  value: _impactVelocity.toStringAsFixed(1),
                  unit: 'm/s',
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'طاقة حركية' : 'KE',
                  value: _kineticEnergy.toStringAsFixed(0),
                  unit: 'J',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          SimulationControls(
            isPlaying: _isPlaying,
            onPlay: _play,
            onPause: _pause,
            onReset: _reset,
          ),
          const SizedBox(height: 12),

          // Gravity selector
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: List.generate(3, (i) {
                final sel = i == _gravityIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _gravityIndex = i;
                      _reset();
                    }),
                    child: AnimatedContainer(
                      duration: AppDurations.fast,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.primaryLight.withAlpha(25)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel
                              ? AppColors.primaryLight.withAlpha(60)
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _gravityNames[i],
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: sel
                                  ? AppColors.primaryLight
                                  : AppColors.textMuted,
                            ),
                          ),
                          Text(
                            'g = ${_gravities[i]} m/s²',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          SimulationSlider(
            label: isArabic ? 'الكتلة' : 'Mass',
            unit: 'kg',
            value: _mass,
            min: 0.5,
            max: 20,
            activeColor: AppColors.roadmapAi,
            onChanged: (v) => setState(() {
              _mass = v;
              _reset();
            }),
          ),
          SimulationSlider(
            label: isArabic ? 'الارتفاع' : 'Height',
            unit: 'm',
            value: _height,
            min: 1,
            max: 100,
            activeColor: AppColors.roadmapLab,
            onChanged: (v) => setState(() {
              _height = v;
              _reset();
            }),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FreeFallPainter extends CustomPainter {
  final double fallPos;
  final double mass;
  final double height;

  _FreeFallPainter({
    required this.fallPos,
    required this.mass,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Height ruler on left
    final rulerPaint = Paint()
      ..color = Colors.white.withAlpha(40)
      ..strokeWidth = 1;
    final startY = 30.0;
    final endY = h - 40;
    canvas.drawLine(Offset(40, startY), Offset(40, endY), rulerPaint);

    // Tick marks
    for (int i = 0; i <= 5; i++) {
      final y = startY + (endY - startY) * i / 5;
      canvas.drawLine(Offset(35, y), Offset(45, y), rulerPaint);
      final tp = TextPainter(
        text: TextSpan(
          text: '${(height * (1 - i / 5)).toStringAsFixed(0)}m',
          style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(10, y - 5));
    }

    // Ground
    canvas.drawLine(
      Offset(30, endY),
      Offset(w - 30, endY),
      Paint()
        ..color = const Color(0xFF22C55E)
        ..strokeWidth = 3,
    );

    // Falling ball
    final ballR = 12.0 + mass * 0.5;
    final ballY = startY + fallPos * (endY - startY - ballR);
    final ballX = w / 2;

    // Motion trail
    for (int i = 0; i < 5; i++) {
      final trailPos = (fallPos - i * 0.03).clamp(0.0, 1.0);
      final ty = startY + trailPos * (endY - startY - ballR);
      canvas.drawCircle(
        Offset(ballX, ty),
        ballR * 0.6,
        Paint()..color = const Color(0xFF38BDF8).withAlpha(20 - i * 4),
      );
    }

    // Ball
    canvas.drawCircle(
      Offset(ballX, ballY),
      ballR,
      Paint()..color = const Color(0xFF38BDF8),
    );
    canvas.drawCircle(
      Offset(ballX, ballY),
      ballR,
      Paint()
        ..color = const Color(0xFF0EA5E9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Gravity arrow
    if (fallPos < 0.9) {
      final arrowEnd = Offset(ballX, ballY + 40);
      canvas.drawLine(
        Offset(ballX, ballY + ballR),
        arrowEnd,
        Paint()
          ..color = const Color(0xFFEF4444)
          ..strokeWidth = 2,
      );
      // Arrowhead
      final path = Path()
        ..moveTo(arrowEnd.dx, arrowEnd.dy)
        ..lineTo(arrowEnd.dx - 5, arrowEnd.dy - 8)
        ..lineTo(arrowEnd.dx + 5, arrowEnd.dy - 8)
        ..close();
      canvas.drawPath(path, Paint()..color = const Color(0xFFEF4444));
    }

    // Impact flash
    if (fallPos >= 0.98) {
      canvas.drawCircle(
        Offset(ballX, endY),
        30,
        Paint()..color = const Color(0xFFEAB308).withAlpha(40),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FreeFallPainter old) =>
      old.fallPos != fallPos || old.mass != mass || old.height != height;
}

// ════════════════════════════════════════════════════════
// ═══  PENDULUM SIMULATION  ═══
// ════════════════════════════════════════════════════════

class _PendulumSim extends StatefulWidget {
  const _PendulumSim();

  @override
  State<_PendulumSim> createState() => _PendulumSimState();
}

class _PendulumSimState extends State<_PendulumSim>
    with SingleTickerProviderStateMixin {
  double _length = 2.0;   // meters
  double _mass = 1.0;     // kg
  double _initAngle = 30; // degrees

  late AnimationController _animController;
  bool _isPlaying = false;

  double get _g => 9.81;
  double get _period => 2 * pi * sqrt(_length / _g);

  double get _currentAngle {
    if (!_isPlaying && _animController.value == 0) {
      return _initAngle * pi / 180;
    }
    final t = _animController.value * _period * 3; // 3 full swings
    return (_initAngle * pi / 180) * cos(2 * pi * t / _period);
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..addListener(() => setState(() {}));
    _animController.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _animController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _play() {
    _isPlaying = true;
    _animController.repeat();
    setState(() {});
  }

  void _pause() {
    _animController.stop();
    _isPlaying = false;
    setState(() {});
  }

  void _reset() {
    _animController.reset();
    _isPlaying = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isArabic = locale.isArabic;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            height: 280,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(8)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(
                painter: _PendulumPainter(
                  angle: _currentAngle,
                  length: _length,
                  mass: _mass,
                ),
              ),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'الزمن الدوري' : 'Period',
                  value: _period.toStringAsFixed(2),
                  unit: 's',
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'التردد' : 'Frequency',
                  value: (1 / _period).toStringAsFixed(2),
                  unit: 'Hz',
                  color: AppColors.roadmapAi,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'الزاوية' : 'Angle',
                  value: (_currentAngle * 180 / pi).toStringAsFixed(1),
                  unit: '°',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          SimulationControls(
            isPlaying: _isPlaying,
            onPlay: _play,
            onPause: _pause,
            onReset: _reset,
          ),
          const SizedBox(height: 12),

          SimulationSlider(
            label: isArabic ? 'طول الخيط' : 'Length',
            unit: 'm',
            value: _length,
            min: 0.5,
            max: 5,
            activeColor: AppColors.roadmapAi,
            onChanged: (v) => setState(() {
              _length = v;
              _reset();
            }),
          ),
          SimulationSlider(
            label: isArabic ? 'الزاوية الابتدائية' : 'Initial Angle',
            unit: '°',
            value: _initAngle,
            min: 5,
            max: 60,
            activeColor: AppColors.roadmapQuiz,
            onChanged: (v) => setState(() {
              _initAngle = v;
              _reset();
            }),
          ),
          SimulationSlider(
            label: isArabic ? 'الكتلة' : 'Mass',
            unit: 'kg',
            value: _mass,
            min: 0.1,
            max: 10,
            activeColor: AppColors.warning,
            onChanged: (v) => setState(() {
              _mass = v;
              _reset();
            }),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PendulumPainter extends CustomPainter {
  final double angle;
  final double length;
  final double mass;

  _PendulumPainter({
    required this.angle,
    required this.length,
    required this.mass,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final pivotX = w / 2;
    final pivotY = 30.0;
    final ropeLen = (h - 80) * (length / 5).clamp(0.3, 1.0);

    // Pivot
    canvas.drawCircle(
      Offset(pivotX, pivotY),
      6,
      Paint()..color = const Color(0xFF94A3B8),
    );

    // Rope end position
    final bobX = pivotX + ropeLen * sin(angle);
    final bobY = pivotY + ropeLen * cos(angle);

    // Trail arc
    final arcPaint = Paint()
      ..color = Colors.white.withAlpha(15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(pivotX, pivotY), radius: ropeLen),
      pi / 2 - 0.6,
      1.2,
      false,
      arcPaint,
    );

    // Rope
    canvas.drawLine(
      Offset(pivotX, pivotY),
      Offset(bobX, bobY),
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..strokeWidth = 2,
    );

    // Bob
    final bobR = 14.0 + mass * 1.5;
    canvas.drawCircle(
      Offset(bobX, bobY),
      bobR,
      Paint()..color = const Color(0xFF6C63FF),
    );
    canvas.drawCircle(
      Offset(bobX, bobY),
      bobR,
      Paint()
        ..color = const Color(0xFF8B83FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Highlight
    canvas.drawCircle(
      Offset(bobX - bobR * 0.3, bobY - bobR * 0.3),
      bobR * 0.25,
      Paint()..color = Colors.white.withAlpha(50),
    );

    // Dashed vertical reference
    final dashPaint = Paint()
      ..color = Colors.white.withAlpha(25)
      ..strokeWidth = 1;
    for (double y = pivotY; y < pivotY + ropeLen; y += 8) {
      canvas.drawLine(Offset(pivotX, y), Offset(pivotX, y + 4), dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PendulumPainter old) =>
      old.angle != angle || old.length != length || old.mass != mass;
}

// ════════════════════════════════════════════════════════
// ═══  PROJECTILE MOTION SIMULATION  ═══
// ════════════════════════════════════════════════════════

class _ProjectileMotionSim extends StatefulWidget {
  const _ProjectileMotionSim();

  @override
  State<_ProjectileMotionSim> createState() => _ProjectileMotionSimState();
}

class _ProjectileMotionSimState extends State<_ProjectileMotionSim>
    with SingleTickerProviderStateMixin {
  double _velocity = 20; // m/s
  double _angle = 45; // degrees
  late AnimationController _animController;
  bool _isPlaying = false;

  double get _angleRad => _angle * pi / 180;
  double get _maxHeight => (_velocity * _velocity * sin(_angleRad) * sin(_angleRad)) / (2 * 9.8);
  double get _range => (_velocity * _velocity * sin(2 * _angleRad)) / 9.8;
  double get _flightTime => (2 * _velocity * sin(_angleRad)) / 9.8;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _isPlaying = false);
        }
      });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _launch() {
    _animController.forward(from: 0);
    setState(() => _isPlaying = true);
  }

  void _reset() {
    _animController.reset();
    setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isArabic = locale.isArabic;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Canvas
          Container(
            height: 260,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(8)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ProjectilePainter(
                      velocity: _velocity,
                      angleDeg: _angle,
                      progress: _animController.value,
                      maxRange: _range,
                      maxH: _maxHeight,
                    ),
                  );
                },
              ),
            ),
          ),

          // Launch button
          GestureDetector(
            onTap: _isPlaying ? null : _launch,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                gradient: _isPlaying ? null : AppGradients.physics,
                color: _isPlaying ? AppColors.surfaceLight : null,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  _isPlaying
                      ? (isArabic ? '⏳ جاري الإطلاق...' : '⏳ Launching...')
                      : (isArabic ? '🚀 أطلق المقذوف' : '🚀 Launch Projectile'),
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Reset
          if (_isPlaying || _animController.value > 0)
            GestureDetector(
              onTap: _reset,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  isArabic ? 'إعادة ↺' : 'Reset ↺',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),

          // Sliders
          SimulationSlider(
            label: isArabic ? 'السرعة' : 'Velocity',
            value: _velocity,
            min: 5,
            max: 50,
            divisions: 45,
            unit: 'm/s',
            activeColor: AppColors.physics,
            onChanged: (v) => setState(() {
              _velocity = v;
              _reset();
            }),
          ),
          SimulationSlider(
            label: isArabic ? 'زاوية الإطلاق' : 'Launch Angle',
            value: _angle,
            min: 10,
            max: 80,
            divisions: 70,
            unit: '°',
            activeColor: AppColors.accent,
            onChanged: (v) => setState(() {
              _angle = v;
              _reset();
            }),
          ),

          const SizedBox(height: 8),

          // Readouts
          Row(
            children: [
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'أقصى ارتفاع' : 'Max Height',
                  value: _maxHeight.toStringAsFixed(1),
                  unit: 'm',
                  color: AppColors.physics,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'المدى' : 'Range',
                  value: _range.toStringAsFixed(1),
                  unit: 'm',
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'زمن الطيران' : 'Flight Time',
                  value: _flightTime.toStringAsFixed(2),
                  unit: 's',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Projectile Painter ───
class _ProjectilePainter extends CustomPainter {
  final double velocity;
  final double angleDeg;
  final double progress;
  final double maxRange;
  final double maxH;

  _ProjectilePainter({
    required this.velocity,
    required this.angleDeg,
    required this.progress,
    required this.maxRange,
    required this.maxH,
  });

  double _sin(double x) => sin(x);
  double _cos(double x) => cos(x);

  @override
  void paint(Canvas canvas, Size size) {
    final pad = 30.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;

    // Background
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0D1B2A), Color(0xFF1A0533)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Ground line
    canvas.drawLine(
      Offset(pad, size.height - pad),
      Offset(size.width - pad, size.height - pad),
      Paint()
        ..color = Colors.white.withAlpha(40)
        ..strokeWidth = 1.5,
    );

    if (maxRange <= 0 || maxH <= 0) return;

    final angleRad = angleDeg * pi / 180;
    final scaleX = w / maxRange.clamp(1, double.infinity);
    final scaleY = h / (maxH * 1.3).clamp(1, double.infinity);

    // Draw trajectory path
    final pathPaint = Paint()
      ..color = AppColors.physics.withAlpha(60)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final flightTime = (2 * velocity * _sin(angleRad)) / 9.8;
    final path = Path();
    bool first = true;

    for (double t = 0; t <= flightTime; t += flightTime / 100) {
      final x = velocity * _cos(angleRad) * t;
      final y = velocity * _sin(angleRad) * t - 0.5 * 9.8 * t * t;
      if (y < 0) break;

      final px = pad + x * scaleX;
      final py = size.height - pad - y * scaleY;

      if (first) {
        path.moveTo(px, py);
        first = false;
      } else {
        path.lineTo(px, py);
      }
    }
    canvas.drawPath(path, pathPaint);

    // Animated ball position
    final currentT = progress * flightTime;
    final bx = velocity * _cos(angleRad) * currentT;
    final by = velocity * _sin(angleRad) * currentT - 0.5 * 9.8 * currentT * currentT;

    if (by >= 0) {
      final ballX = pad + bx * scaleX;
      final ballY = size.height - pad - by * scaleY;

      // Glow
      canvas.drawCircle(
        Offset(ballX, ballY),
        14,
        Paint()
          ..color = AppColors.physics.withAlpha(40)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );

      // Ball
      canvas.drawCircle(
        Offset(ballX, ballY),
        8,
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0xFF7B2FF7), Color(0xFF5A189A)],
          ).createShader(Rect.fromCircle(center: Offset(ballX, ballY), radius: 8)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProjectilePainter old) =>
      old.progress != progress || old.velocity != velocity || old.angleDeg != angleDeg;
}

// ════════════════════════════════════════════════════════
// ═══  WAVES SIMULATION  ═══
// ════════════════════════════════════════════════════════

class _WavesSim extends StatefulWidget {
  const _WavesSim();

  @override
  State<_WavesSim> createState() => _WavesSimState();
}

class _WavesSimState extends State<_WavesSim>
    with SingleTickerProviderStateMixin {
  double _frequency = 2.0; // Hz
  double _amplitude = 40; // pixels
  double _speed = 100; // px/s
  late AnimationController _animController;

  // Wavelength λ = v / f
  double get _wavelength => _speed / _frequency;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isArabic = locale.isArabic;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Wave canvas
          Container(
            height: 220,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(8)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _WavePainter(
                      frequency: _frequency,
                      amplitude: _amplitude,
                      speed: _speed,
                      time: _animController.value * 4,
                    ),
                  );
                },
              ),
            ),
          ),

          // Formula
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withAlpha(15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryLight.withAlpha(30)),
            ),
            child: Center(
              child: Text(
                'v = f × λ  →  λ = ${_wavelength.toStringAsFixed(1)} px',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
          ),

          // Sliders
          SimulationSlider(
            label: isArabic ? 'التردد' : 'Frequency',
            value: _frequency,
            min: 0.5,
            max: 8.0,
            divisions: 15,
            unit: 'Hz',
            activeColor: AppColors.primaryLight,
            onChanged: (v) => setState(() => _frequency = v),
          ),
          SimulationSlider(
            label: isArabic ? 'السعة' : 'Amplitude',
            value: _amplitude,
            min: 10,
            max: 80,
            divisions: 14,
            unit: 'px',
            activeColor: AppColors.accent,
            onChanged: (v) => setState(() => _amplitude = v),
          ),
          SimulationSlider(
            label: isArabic ? 'السرعة' : 'Speed',
            value: _speed,
            min: 30,
            max: 300,
            divisions: 27,
            unit: 'px/s',
            activeColor: AppColors.warning,
            onChanged: (v) => setState(() => _speed = v),
          ),

          const SizedBox(height: 8),

          // Readouts
          Row(
            children: [
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'الطول الموجي' : 'Wavelength',
                  value: _wavelength.toStringAsFixed(1),
                  unit: 'λ',
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'التردد' : 'Frequency',
                  value: _frequency.toStringAsFixed(1),
                  unit: 'Hz',
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'السرعة' : 'Speed',
                  value: _speed.toStringAsFixed(0),
                  unit: 'px/s',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Wave Painter ───
class _WavePainter extends CustomPainter {
  final double frequency;
  final double amplitude;
  final double speed;
  final double time;

  _WavePainter({
    required this.frequency,
    required this.amplitude,
    required this.speed,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0D1B2A), Color(0xFF0F2027)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final centerY = size.height / 2;

    // Axis line
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      Paint()
        ..color = Colors.white.withAlpha(25)
        ..strokeWidth = 1,
    );

    // Wave
    final wavelength = speed / frequency;
    final pi2 = pi * 2;

    final wavePath = Path();
    final glowPath = Path();
    bool first = true;

    for (double x = 0; x <= size.width; x += 1.5) {
      final y = centerY -
          amplitude *
              _sin(pi2 * (x / wavelength - frequency * time));

      if (first) {
        wavePath.moveTo(x, y);
        glowPath.moveTo(x, y);
        first = false;
      } else {
        wavePath.lineTo(x, y);
        glowPath.lineTo(x, y);
      }
    }

    // Glow effect
    canvas.drawPath(
      glowPath,
      Paint()
        ..color = AppColors.primaryLight.withAlpha(30)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Main wave line
    canvas.drawPath(
      wavePath,
      Paint()
        ..color = AppColors.primaryLight
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Wavelength arrow
    if (wavelength > 30 && wavelength < size.width) {
      final arrowY = centerY + amplitude + 25;
      final startX = size.width / 4;
      final endX = startX + wavelength;

      if (endX < size.width - 10) {
        final arrowPaint = Paint()
          ..color = AppColors.accent.withAlpha(150)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

        canvas.drawLine(
          Offset(startX, arrowY),
          Offset(endX, arrowY),
          arrowPaint,
        );

        // Arrow heads
        canvas.drawLine(Offset(startX, arrowY - 5), Offset(startX, arrowY + 5), arrowPaint);
        canvas.drawLine(Offset(endX, arrowY - 5), Offset(endX, arrowY + 5), arrowPaint);

        // Lambda label
        final tp = TextPainter(
          text: TextSpan(
            text: 'λ',
            style: TextStyle(
              color: AppColors.accent.withAlpha(200),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset((startX + endX) / 2 - tp.width / 2, arrowY + 4));
      }
    }
  }

  double _sin(double x) => sin(x);

  @override
  bool shouldRepaint(covariant _WavePainter old) =>
      old.time != time || old.frequency != frequency ||
      old.amplitude != amplitude || old.speed != speed;
}
