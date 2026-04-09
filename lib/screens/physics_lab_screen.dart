import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../models/physics_experiment.dart';
import '../providers/locale_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/physics_painter.dart';

/// Interactive 2D Physics Lab for projectile motion simulation.
///
/// Features:
/// - Adjustable parameters (velocity, angle, gravity, mass)
/// - Real-time kinematic animation driven by equations of motion
/// - Telemetry overlay showing live data
/// - Trajectory trace with velocity vector
class PhysicsLabScreen extends StatefulWidget {
  /// Optional initial parameters from the AI
  final Map<String, double>? initialParams;

  const PhysicsLabScreen({super.key, this.initialParams});

  @override
  State<PhysicsLabScreen> createState() => _PhysicsLabScreenState();
}

class _PhysicsLabScreenState extends State<PhysicsLabScreen>
    with SingleTickerProviderStateMixin {
  // ─── State ───
  late PhysicsExperiment _experiment;
  late AnimationController _animController;
  final List<Offset> _tracePoints = [];
  bool _isLaunched = false;
  bool _isComplete = false;
  bool _showControls = true;

  // ─── Current telemetry ───
  double _currentTime = 0;
  double _currentX = 0;
  double _currentY = 0;
  double _currentSpeed = 0;

  @override
  void initState() {
    super.initState();

    // Initialize experiment with AI params or defaults
    _experiment = PhysicsExperiment(
      initialVelocity: widget.initialParams?['velocity'] ?? 25.0,
      angle: widget.initialParams?['angle'] ?? 45.0,
      gravity: widget.initialParams?['gravity'] ?? 9.8,
      mass: widget.initialParams?['mass'] ?? 1.0,
    );

    _animController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (_experiment.timeOfFlight * 1000).toInt().clamp(500, 10000),
      ),
    )..addListener(_onAnimationTick);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onAnimationTick() {
    if (!_isLaunched) return;

    setState(() {
      _currentTime = _animController.value * _experiment.timeOfFlight;
      _currentX = _experiment.xAt(_currentTime);
      _currentY = _experiment.yAt(_currentTime);
      _currentSpeed = _experiment.speedAt(_currentTime);

      // Record trace point (screen-space coords will be computed by painter)
      // We store physics coords and let build() do conversion
      _tracePoints.add(Offset(_currentX, _currentY));

      // Check completion
      if (_animController.isCompleted) {
        _isComplete = true;
        // Award XP for completing the simulation
        context.read<ProgressProvider>().completeSimulation(context: context);
      }
    });
  }

  void _launch() {
    if (_isLaunched) return;
    if (_experiment.timeOfFlight <= 0) return;

    setState(() {
      _isLaunched = true;
      _isComplete = false;
      _tracePoints.clear();
      _showControls = false;
    });

    // Update duration based on current experiment params
    _animController.duration = Duration(
      milliseconds: (_experiment.timeOfFlight * 1000).toInt().clamp(500, 10000),
    );

    _animController.forward(from: 0);
  }

  void _reset() {
    _animController.stop();
    setState(() {
      _isLaunched = false;
      _isComplete = false;
      _currentTime = 0;
      _currentX = 0;
      _currentY = 0;
      _currentSpeed = 0;
      _tracePoints.clear();
      _showControls = true;
    });
  }

  void _updateExperiment(PhysicsExperiment updated) {
    if (_isLaunched) return; // Don't update during animation
    setState(() => _experiment = updated);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isArabic = locale.isArabic;

    // ─── Convert trace points to screen coords for painter ───
    // We need the canvas size to do this, so we use LayoutBuilder
    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(isArabic),
        body: Stack(
          children: [
            // ─── Simulation Canvas ───
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenTracePoints =
                      _convertTraceToScreen(constraints.maxWidth, constraints.maxHeight);

                  return CustomPaint(
                    painter: PhysicsPainter(
                      experiment: _experiment,
                      currentTime: _currentTime,
                      isLaunched: _isLaunched,
                      isComplete: _isComplete,
                      tracePoints: screenTracePoints,
                    ),
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  );
                },
              ),
            ),

            // ─── Telemetry Overlay ───
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              right: 12,
              child: _TelemetryPanel(
                time: _currentTime,
                x: _currentX,
                y: _currentY,
                speed: _currentSpeed,
                maxHeight: _experiment.maxHeight,
                range: _experiment.range,
                isLaunched: _isLaunched,
                isArabic: isArabic,
              ),
            ),

            // ─── Control Panel ───
            if (_showControls)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _ControlPanel(
                  experiment: _experiment,
                  onChanged: _updateExperiment,
                  onLaunch: _launch,
                  isArabic: isArabic,
                ),
              ),

            // ─── Action Buttons (during/after animation) ───
            if (_isLaunched)
              Positioned(
                right: 16,
                bottom: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Reset button
                    FloatingActionButton.small(
                      heroTag: 'reset',
                      backgroundColor: AppColors.danger.withAlpha(200),
                      onPressed: _reset,
                      child: const Icon(Icons.refresh_rounded,
                          color: Colors.white, size: 20),
                    ),
                    if (_isComplete) ...[
                      const SizedBox(height: 10),
                      // Show controls again
                      FloatingActionButton.small(
                        heroTag: 'controls',
                        backgroundColor: AppColors.accent.withAlpha(200),
                        onPressed: () {
                          _reset();
                          setState(() => _showControls = true);
                        },
                        child: const Icon(Icons.tune_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Converts physics-space trace points to screen-space points
  /// matching the painter's coordinate system.
  List<Offset> _convertTraceToScreen(double canvasW, double canvasH) {
    if (_tracePoints.isEmpty) return [];

    const padL = 50.0;
    const padR = 20.0;
    const padBot = 40.0;
    const padTop = 30.0;
    final plotW = canvasW - padL - padR;
    final plotH = canvasH - padTop - padBot;
    final originX = padL;
    final originY = canvasH - padBot;

    final maxX = _experiment.range > 0 ? _experiment.range * 1.15 : 100.0;
    final maxY =
        _experiment.maxHeight > 0 ? _experiment.maxHeight * 1.3 : 50.0;
    final scaleX = plotW / maxX;
    final scaleY = plotH / maxY;

    return _tracePoints
        .map((p) => Offset(originX + p.dx * scaleX, originY - p.dy * scaleY))
        .toList();
  }

  PreferredSizeWidget _buildAppBar(bool isArabic) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: Colors.white70),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🧲', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(
            isArabic ? 'معمل الفيزياء' : 'Physics Lab',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  TELEMETRY PANEL — Real-time Data Overlay
// ═════════════════════════════════════════════════════════════════

class _TelemetryPanel extends StatelessWidget {
  final double time;
  final double x;
  final double y;
  final double speed;
  final double maxHeight;
  final double range;
  final bool isLaunched;
  final bool isArabic;

  const _TelemetryPanel({
    required this.time,
    required this.x,
    required this.y,
    required this.speed,
    required this.maxHeight,
    required this.range,
    required this.isLaunched,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xCC0D1117),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.speed_rounded,
                size: 12,
                color: isLaunched
                    ? AppColors.accent
                    : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                isArabic ? 'بيانات حية' : 'TELEMETRY',
                style: GoogleFonts.sourceCodePro(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isLaunched
                      ? AppColors.accent
                      : AppColors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          _TelemetryRow(
            icon: '⏱️',
            label: isArabic ? 'الزمن' : 'Time',
            value: '${time.toStringAsFixed(2)} s',
            color: const Color(0xFFB0BEC5),
          ),
          _TelemetryRow(
            icon: '📍',
            label: 'X',
            value: '${x.toStringAsFixed(1)} m',
            color: const Color(0xFF4FC3F7),
          ),
          _TelemetryRow(
            icon: '📍',
            label: 'Y',
            value: '${y.toStringAsFixed(1)} m',
            color: const Color(0xFFFF9800),
          ),
          _TelemetryRow(
            icon: '💨',
            label: isArabic ? 'السرعة' : 'Speed',
            value: '${speed.toStringAsFixed(1)} m/s',
            color: const Color(0xFFFF5722),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Container(
              height: 1,
              width: 100,
              color: Colors.white.withAlpha(8),
            ),
          ),

          _TelemetryRow(
            icon: '📏',
            label: isArabic ? 'المدى' : 'Range',
            value: '${range.toStringAsFixed(1)} m',
            color: const Color(0xFF00BCD4),
          ),
          _TelemetryRow(
            icon: '⬆️',
            label: isArabic ? 'أقصى ارت' : 'Max H',
            value: '${maxHeight.toStringAsFixed(1)} m',
            color: const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }
}

class _TelemetryRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _TelemetryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          SizedBox(
            width: 44,
            child: Text(
              label,
              style: GoogleFonts.sourceCodePro(
                fontSize: 9,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.sourceCodePro(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  CONTROL PANEL — Parameter Sliders + Launch Button
// ═════════════════════════════════════════════════════════════════

class _ControlPanel extends StatelessWidget {
  final PhysicsExperiment experiment;
  final ValueChanged<PhysicsExperiment> onChanged;
  final VoidCallback onLaunch;
  final bool isArabic;

  const _ControlPanel({
    required this.experiment,
    required this.onChanged,
    required this.onLaunch,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xF00D1117),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.white.withAlpha(8)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Title ───
              Row(
                children: [
                  const Icon(Icons.tune_rounded,
                      size: 16, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text(
                    isArabic ? 'التحكم بالتجربة' : 'Experiment Controls',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ─── Sliders ───
              _ParamSlider(
                label: isArabic ? 'السرعة الابتدائية' : 'Initial Velocity',
                unit: 'm/s',
                value: experiment.initialVelocity,
                min: 5,
                max: 60,
                color: const Color(0xFFFF5722),
                onChanged: (v) =>
                    onChanged(experiment.copyWith(initialVelocity: v)),
              ),
              const SizedBox(height: 8),

              _ParamSlider(
                label: isArabic ? 'زاوية الإطلاق' : 'Launch Angle',
                unit: '°',
                value: experiment.angle,
                min: 5,
                max: 85,
                color: const Color(0xFFFF9800),
                onChanged: (v) => onChanged(experiment.copyWith(angle: v)),
              ),
              const SizedBox(height: 8),

              _ParamSlider(
                label: isArabic ? 'الجاذبية' : 'Gravity',
                unit: 'm/s²',
                value: experiment.gravity,
                min: 1,
                max: 25,
                color: const Color(0xFF4FC3F7),
                onChanged: (v) => onChanged(experiment.copyWith(gravity: v)),
              ),
              const SizedBox(height: 8),

              _ParamSlider(
                label: isArabic ? 'الكتلة' : 'Mass',
                unit: 'kg',
                value: experiment.mass,
                min: 0.1,
                max: 10,
                color: const Color(0xFFB0BEC5),
                onChanged: (v) => onChanged(experiment.copyWith(mass: v)),
              ),
              const SizedBox(height: 16),

              // ─── Preview Stats ───
              Row(
                children: [
                  _StatChip(
                    label: isArabic ? 'المدى' : 'Range',
                    value: '${experiment.range.toStringAsFixed(1)} m',
                    color: const Color(0xFF00BCD4),
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: isArabic ? 'أقصى ارتفاع' : 'Max Height',
                    value: '${experiment.maxHeight.toStringAsFixed(1)} m',
                    color: const Color(0xFFFF9800),
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: isArabic ? 'الزمن' : 'Flight',
                    value: '${experiment.timeOfFlight.toStringAsFixed(2)} s',
                    color: const Color(0xFFB0BEC5),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── Launch Button ───
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: experiment.timeOfFlight > 0 ? onLaunch : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5722),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0x60FF5722),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rocket_launch_rounded, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        isArabic ? '🚀 إطلاق!' : '🚀 Launch!',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  PARAMETER SLIDER
// ═════════════════════════════════════════════════════════════════

class _ParamSlider extends StatelessWidget {
  final String label;
  final String unit;
  final double value;
  final double min;
  final double max;
  final Color color;
  final ValueChanged<double> onChanged;

  const _ParamSlider({
    required this.label,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withAlpha(30),
              thumbColor: color,
              overlayColor: color.withAlpha(20),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 58,
          child: Text(
            '${value.toStringAsFixed(1)} $unit',
            style: GoogleFonts.sourceCodePro(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  STAT CHIP — Preview Statistics
// ═════════════════════════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(25)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 9,
                color: AppColors.textMuted,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.sourceCodePro(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
