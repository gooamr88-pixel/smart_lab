import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_constants.dart';

/// Premium glassmorphism slider widget for simulation variables
class SimulationSlider extends StatelessWidget {
  final String label;
  final String unit;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  const SimulationSlider({
    super.key,
    required this.label,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    this.divisions = 100,
    this.activeColor = AppColors.primaryLight,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: activeColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 2)} $unit',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: activeColor,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: activeColor,
              inactiveTrackColor: activeColor.withAlpha(30),
              thumbColor: activeColor,
              overlayColor: activeColor.withAlpha(20),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Play/Pause/Reset control bar for simulations
class SimulationControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onReset;

  const SimulationControls({
    super.key,
    required this.isPlaying,
    required this.onPlay,
    required this.onPause,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset
        _ControlButton(
          icon: Icons.replay_rounded,
          color: AppColors.textMuted,
          onTap: onReset,
        ),
        const SizedBox(width: 16),
        // Play / Pause
        GestureDetector(
          onTap: isPlaying ? onPause : onPlay,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryLight.withAlpha(50),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Step forward (when paused)
        _ControlButton(
          icon: Icons.skip_next_rounded,
          color: AppColors.textMuted,
          onTap: onPlay,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceLight,
          border: Border.all(color: Colors.white.withAlpha(10)),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

/// Data readout chip showing a simulation result value
class SimulationReadout extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const SimulationReadout({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.color = AppColors.primaryLight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(25)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  unit,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: color.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
