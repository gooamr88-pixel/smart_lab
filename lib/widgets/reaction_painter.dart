import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/lab_item.dart';

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  PARTICLE SYSTEM CORE
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

/// General-purpose particle used by ALL effect types.
class EffectParticle {
  double x, y;       // 0-1 normalized position within beaker
  double vx, vy;     // velocity per tick
  double size;        // pixel radius
  double life;        // remaining 0-1
  double maxLife;     // starting life
  double opacity;     // visual opacity
  double rotation;    // for shaped particles
  double rotSpeed;    // rotation velocity
  Color color;

  EffectParticle({
    required this.x, required this.y,
    this.vx = 0, this.vy = 0,
    required this.size,
    this.life = 1.0, this.maxLife = 1.0,
    this.opacity = 1.0, this.rotation = 0, this.rotSpeed = 0,
    required this.color,
  });

  bool get isDead => life <= 0;
  double get lifeRatio => (life / maxLife).clamp(0.0, 1.0);
}

/// Standard rising bubble (kept for backwards compatibility).
class Bubble {
  double x, y, radius, speed, wobble, opacity;
  Bubble({ required this.x, required this.y, required this.radius,
    required this.speed, required this.wobble, required this.opacity });
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  REACTION VESSEL â€” StatefulWidget with Multi-Effect Animation
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class ReactionVessel extends StatefulWidget {
  final List<LabItem> contents;
  final ChemReaction? reaction;
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
  // â”€â”€â”€ Animation Controllers â”€â”€â”€
  late AnimationController _waveController;
  late AnimationController _tickController;
  late AnimationController _colorController;
  late AnimationController _heatController;

  // â”€â”€â”€ Animated Values â”€â”€â”€
  late Animation<double> _fillAnim;
  late Animation<Color?> _colorAnim;

  // â”€â”€â”€ Particle Systems â”€â”€â”€
  final List<Bubble> _bubbles = [];
  final Map<ReactionEffect, List<EffectParticle>> _effectParticles = {};
  double _colorWaveProgress = 0.0;
  double _frostProgress = 0.0;
  final Random _rng = Random();

  Color _currentColor = Colors.transparent;
  Color _targetColor = Colors.transparent;
  double _currentFill = 0.0;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this, duration: const Duration(seconds: 3),
    )..repeat();

    _tickController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 50),
    )..addListener(_tick);

    _colorController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    );

    _heatController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    );

    _fillAnim = AlwaysStoppedAnimation(widget.fillLevel);
    _colorAnim = AlwaysStoppedAnimation(_currentColor);

    _syncState();
  }

  @override
  void didUpdateWidget(covariant ReactionVessel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fillLevel != oldWidget.fillLevel ||
        widget.contents.length != oldWidget.contents.length ||
        widget.reaction != oldWidget.reaction) {
      _syncState();
    }
  }

  void _syncState() {
    final oldFill = _currentFill;
    _currentFill = widget.fillLevel;
    _fillAnim = Tween<double>(begin: oldFill, end: _currentFill).animate(
      CurvedAnimation(parent: _colorController, curve: Curves.easeOutCubic),
    );

    _targetColor = _computeLiquidColor();
    _colorAnim = ColorTween(begin: _currentColor, end: _targetColor).animate(
      CurvedAnimation(parent: _colorController, curve: Curves.easeInOut),
    );
    _colorController.forward(from: 0).then((_) {
      _currentColor = _targetColor;
    });

    // â”€â”€ Start effect systems â”€â”€
    _effectParticles.clear();
    _colorWaveProgress = 0.0;
    _frostProgress = 0.0;

    if (widget.reaction != null) {
      final r = widget.reaction!;

      // Legacy bubbles
      _startBubbles(r.bubbleIntensity);

      // Heat glow
      if (r.heatIntensity > 0) {
        _heatController.repeat(reverse: true);
      } else {
        _heatController.stop();
      }

      // Spawn particles for each effect layer
      for (final layer in r.effects) {
        _effectParticles[layer.type] = [];
        _spawnEffect(layer);
      }

      // Start the main tick loop
      if (!_tickController.isAnimating) {
        _tickController.repeat();
      }
    } else if (widget.contents.isNotEmpty) {
      _startBubbles(0.15);
      if (!_tickController.isAnimating) {
        _tickController.repeat();
      }
    } else {
      _stopAll();
    }
  }

  Color _computeLiquidColor() {
    if (widget.reaction != null) return widget.reaction!.resultColor;
    final liquids = widget.contents.where((i) => i.isLiquid).toList();
    if (liquids.isEmpty) {
      return widget.contents.isNotEmpty
          ? const Color(0x33B0BEC5) : Colors.transparent;
    }
    Color result = liquids.first.color;
    for (int i = 1; i < liquids.length; i++) {
      result = Color.lerp(result, liquids[i].color, 0.5)!;
    }
    return result;
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  //  EFFECT SPAWNERS
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _spawnEffect(EffectLayer layer) {
    final list = _effectParticles[layer.type]!;
    final count = (layer.intensity * 20).toInt().clamp(5, 25);

    switch (layer.type) {
      case ReactionEffect.precipitate:
        for (int i = 0; i < count; i++) {
          list.add(EffectParticle(
            x: 0.25 + _rng.nextDouble() * 0.5,
            y: 0.3 + _rng.nextDouble() * 0.2,
            vx: (_rng.nextDouble() - 0.5) * 0.002,
            vy: 0.003 + _rng.nextDouble() * 0.005 * layer.intensity,
            size: (2.0 + _rng.nextDouble() * 3.0) * layer.size,
            life: 1.0, maxLife: 1.0,
            opacity: 0.6 + _rng.nextDouble() * 0.4,
            color: layer.color,
          ));
        }

      case ReactionEffect.smoke:
        for (int i = 0; i < count; i++) {
          list.add(EffectParticle(
            x: 0.35 + _rng.nextDouble() * 0.3,
            y: 0.2 + _rng.nextDouble() * 0.1,
            vx: (_rng.nextDouble() - 0.5) * 0.003,
            vy: -(0.004 + _rng.nextDouble() * 0.008 * layer.intensity),
            size: (4.0 + _rng.nextDouble() * 6.0) * layer.size,
            life: 1.0, maxLife: 1.0,
            opacity: 0.2 + _rng.nextDouble() * 0.3,
            color: layer.color,
          ));
        }

      case ReactionEffect.sparks:
        for (int i = 0; i < count; i++) {
          final angle = _rng.nextDouble() * pi * 2;
          final speed = 0.008 + _rng.nextDouble() * 0.015 * layer.intensity;
          list.add(EffectParticle(
            x: 0.45 + _rng.nextDouble() * 0.1,
            y: 0.4 + _rng.nextDouble() * 0.1,
            vx: cos(angle) * speed,
            vy: sin(angle) * speed - 0.005,
            size: (1.0 + _rng.nextDouble() * 2.5) * layer.size,
            life: 0.6 + _rng.nextDouble() * 0.4,
            maxLife: 0.6 + _rng.nextDouble() * 0.4,
            opacity: 0.8 + _rng.nextDouble() * 0.2,
            color: layer.color,
          ));
        }

      case ReactionEffect.flame:
        for (int i = 0; i < count; i++) {
          list.add(EffectParticle(
            x: 0.3 + _rng.nextDouble() * 0.4,
            y: 0.15 + _rng.nextDouble() * 0.1,
            vx: (_rng.nextDouble() - 0.5) * 0.004,
            vy: -(0.005 + _rng.nextDouble() * 0.008 * layer.intensity),
            size: (3.0 + _rng.nextDouble() * 5.0) * layer.size,
            life: 1.0, maxLife: 1.0,
            opacity: 0.6 + _rng.nextDouble() * 0.4,
            rotation: _rng.nextDouble() * pi * 2,
            rotSpeed: (_rng.nextDouble() - 0.5) * 0.2,
            color: layer.color,
          ));
        }

      case ReactionEffect.foam:
        for (int i = 0; i < (count * 1.5).toInt(); i++) {
          list.add(EffectParticle(
            x: 0.2 + _rng.nextDouble() * 0.6,
            y: 0.15 + _rng.nextDouble() * 0.15,
            vx: (_rng.nextDouble() - 0.5) * 0.001,
            vy: -(0.001 + _rng.nextDouble() * 0.003 * layer.intensity),
            size: (2.5 + _rng.nextDouble() * 4.0) * layer.size,
            life: 1.0, maxLife: 1.0,
            opacity: 0.3 + _rng.nextDouble() * 0.4,
            color: layer.color,
          ));
        }

      case ReactionEffect.colorWave:
        // ColorWave uses _colorWaveProgress, no particles needed
        break;

      case ReactionEffect.gasRelease:
        for (int i = 0; i < count; i++) {
          list.add(EffectParticle(
            x: 0.3 + _rng.nextDouble() * 0.4,
            y: 0.5 + _rng.nextDouble() * 0.3,
            vx: (_rng.nextDouble() - 0.5) * 0.002,
            vy: -(0.006 + _rng.nextDouble() * 0.01 * layer.intensity),
            size: (3.0 + _rng.nextDouble() * 5.0) * layer.size,
            life: 1.0, maxLife: 1.0,
            opacity: 0.3 + _rng.nextDouble() * 0.5,
            color: layer.color,
          ));
        }

      case ReactionEffect.glow:
        // Glow is rendered as a background effect, no particles
        break;

      case ReactionEffect.crystallize:
        for (int i = 0; i < (count * 0.6).toInt().clamp(3, 12); i++) {
          final side = _rng.nextBool();
          list.add(EffectParticle(
            x: side ? (0.2 + _rng.nextDouble() * 0.15) : (0.65 + _rng.nextDouble() * 0.15),
            y: 0.7 + _rng.nextDouble() * 0.2,
            vx: 0, vy: 0,
            size: (1.0 + _rng.nextDouble() * 1.5) * layer.size,
            life: 0.0, maxLife: 1.0,  // Grows over time
            opacity: 0.0,
            rotation: _rng.nextDouble() * pi,
            rotSpeed: 0,
            color: layer.color,
          ));
        }

      case ReactionEffect.frost:
        // Frost uses _frostProgress, rendered as wall patterns
        break;
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  //  TICK â€” Update all particles
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _tick() {
    if (_bubbles.isEmpty && _effectParticles.isEmpty) return;

    setState(() {
      _updateBubbles();
      _updateEffectParticles();
    });
  }

  void _updateEffectParticles() {
    if (widget.reaction == null) return;

    for (final layer in widget.reaction!.effects) {
      final list = _effectParticles[layer.type];
      if (list == null) continue;

      switch (layer.type) {
        case ReactionEffect.precipitate:
          for (final p in list) {
            p.y += p.vy;
            p.x += p.vx;
            p.vx += (_rng.nextDouble() - 0.5) * 0.001;
            // Settle at bottom
            if (p.y > 0.88) {
              p.vy = 0;
              p.y = 0.85 + _rng.nextDouble() * 0.05;
              p.vx *= 0.5;
              p.opacity = (p.opacity * 0.998).clamp(0.3, 1.0);
            }
            // Recycle if fell too far
            if (p.y > 0.95) {
              p.y = 0.3 + _rng.nextDouble() * 0.15;
              p.x = 0.25 + _rng.nextDouble() * 0.5;
              p.vy = 0.003 + _rng.nextDouble() * 0.005 * layer.intensity;
            }
          }

        case ReactionEffect.smoke:
          for (int i = list.length - 1; i >= 0; i--) {
            final p = list[i];
            p.y += p.vy;
            p.x += p.vx + sin(p.rotation) * 0.001;
            p.rotation += 0.05;
            p.size *= 1.005;  // Expand
            p.life -= 0.008;
            p.opacity = p.lifeRatio * 0.35;
            if (p.isDead) {
              // Respawn at surface
              p.x = 0.35 + _rng.nextDouble() * 0.3;
              p.y = 0.2 + _rng.nextDouble() * 0.05;
              p.life = 1.0;
              p.size = (4.0 + _rng.nextDouble() * 6.0) * layer.size;
              p.opacity = 0.25;
            }
          }

        case ReactionEffect.sparks:
          for (int i = list.length - 1; i >= 0; i--) {
            final p = list[i];
            p.x += p.vx;
            p.y += p.vy;
            p.vy += 0.0003;  // Gravity
            p.life -= 0.015;
            p.opacity = p.lifeRatio * 0.9;
            p.size *= 0.995;
            if (p.isDead) {
              // Respawn at center
              final angle = _rng.nextDouble() * pi * 2;
              final speed = 0.008 + _rng.nextDouble() * 0.015 * layer.intensity;
              p.x = 0.45 + _rng.nextDouble() * 0.1;
              p.y = 0.4 + _rng.nextDouble() * 0.1;
              p.vx = cos(angle) * speed;
              p.vy = sin(angle) * speed - 0.005;
              p.life = 0.6 + _rng.nextDouble() * 0.4;
              p.maxLife = p.life;
              p.size = (1.0 + _rng.nextDouble() * 2.5) * layer.size;
              p.opacity = 0.9;
            }
          }

        case ReactionEffect.flame:
          for (final p in list) {
            p.y += p.vy;
            p.x += p.vx + sin(p.rotation) * 0.003;
            p.rotation += p.rotSpeed;
            p.life -= 0.012;
            p.opacity = p.lifeRatio * 0.7;
            p.size *= 0.997;
            if (p.isDead) {
              p.x = 0.3 + _rng.nextDouble() * 0.4;
              p.y = 0.15 + _rng.nextDouble() * 0.05;
              p.life = 1.0;
              p.size = (3.0 + _rng.nextDouble() * 5.0) * layer.size;
              p.opacity = 0.7;
              p.vy = -(0.005 + _rng.nextDouble() * 0.008 * layer.intensity);
            }
          }

        case ReactionEffect.foam:
          for (final p in list) {
            p.y += p.vy;
            p.x += p.vx + sin(p.rotation) * 0.0005;
            p.rotation += 0.03;
            // Foam piles up at surface
            if (p.y < 0.05) {
              p.vy = 0;
              p.y = 0.05 + _rng.nextDouble() * 0.12;
            }
            p.size += 0.02 * layer.intensity;
            if (p.size > 7.0 * layer.size) p.size = 7.0 * layer.size;
            p.opacity = (0.25 + sin(p.rotation) * 0.1).clamp(0.15, 0.45);
          }

        case ReactionEffect.colorWave:
          _colorWaveProgress += 0.008 * layer.intensity;
          if (_colorWaveProgress > 1.5) _colorWaveProgress = 0.0;

        case ReactionEffect.gasRelease:
          for (int i = list.length - 1; i >= 0; i--) {
            final p = list[i];
            p.y += p.vy;
            p.x += p.vx + sin(p.rotation) * 0.002;
            p.rotation += 0.08;
            p.size *= 1.002;
            p.life -= 0.006;
            // Above surface: expand and fade
            if (p.y < 0.2) {
              p.size *= 1.01;
              p.opacity *= 0.98;
            }
            if (p.isDead || p.y < -0.1) {
              p.x = 0.3 + _rng.nextDouble() * 0.4;
              p.y = 0.5 + _rng.nextDouble() * 0.3;
              p.life = 1.0;
              p.size = (3.0 + _rng.nextDouble() * 5.0) * layer.size;
              p.opacity = 0.4;
              p.vy = -(0.006 + _rng.nextDouble() * 0.01 * layer.intensity);
            }
          }

        case ReactionEffect.glow:
          // No particle update needed â€” static glow
          break;

        case ReactionEffect.crystallize:
          for (final p in list) {
            p.life = (p.life + 0.005 * layer.intensity).clamp(0.0, 1.0);
            p.size = (1.0 + p.life * 4.0) * layer.size;
            p.opacity = p.life * 0.7;
            p.rotation += 0.002;
          }

        case ReactionEffect.frost:
          _frostProgress = (_frostProgress + 0.006 * layer.intensity).clamp(0.0, 1.0);
      }
    }
  }

  // â”€â”€â”€ Legacy Bubble System â”€â”€â”€

  void _startBubbles(double intensity) {
    _bubbles.clear();
    final count = (intensity * 25).toInt().clamp(3, 30);
    for (int i = 0; i < count; i++) {
      _bubbles.add(_createBubble());
    }
    if (!_tickController.isAnimating) _tickController.repeat();
  }

  void _stopAll() {
    _bubbles.clear();
    _effectParticles.clear();
    _tickController.stop();
    _heatController.stop();
  }

  Bubble _createBubble() {
    return Bubble(
      x: 0.2 + _rng.nextDouble() * 0.6,
      y: 0.8 + _rng.nextDouble() * 0.2,
      radius: 1.5 + _rng.nextDouble() * 3.5,
      speed: 0.005 + _rng.nextDouble() * 0.015,
      wobble: _rng.nextDouble() * pi * 2,
      opacity: 0.3 + _rng.nextDouble() * 0.5,
    );
  }

  void _updateBubbles() {
    for (int i = _bubbles.length - 1; i >= 0; i--) {
      final b = _bubbles[i];
      b.y -= b.speed;
      b.x += sin(b.wobble) * 0.002;
      b.wobble += 0.15;
      b.opacity *= 0.998;
      final surfaceY = 1.0 - _currentFill;
      if (b.y <= surfaceY || b.opacity < 0.05) {
        _bubbles[i] = _createBubble();
      }
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _tickController.dispose();
    _colorController.dispose();
    _heatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveController, _colorController, _heatController]),
      builder: (context, child) {
        // Collect active effect layers for the painter
        final activeEffects = <ReactionEffect, PainterEffectData>{};
        if (widget.reaction != null) {
          for (final layer in widget.reaction!.effects) {
            activeEffects[layer.type] = PainterEffectData(
              particles: _effectParticles[layer.type] ?? [],
              color: layer.color,
              intensity: layer.intensity,
              colorWaveProgress: _colorWaveProgress,
              frostProgress: _frostProgress,
            );
          }
        }

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
            effects: activeEffects,
            heatColor: _getHeatColor(),
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Color _getHeatColor() {
    if (widget.reaction == null) return const Color(0xFFFF6F00);
    // Check if there's a glow effect with custom color
    for (final layer in widget.reaction!.effects) {
      if (layer.type == ReactionEffect.glow) return layer.color;
    }
    return const Color(0xFFFF6F00);
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  PAINTER EFFECT DATA â€” Passed from Widget to Painter
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class PainterEffectData {
  final List<EffectParticle> particles;
  final Color color;
  final double intensity;
  final double colorWaveProgress;
  final double frostProgress;

  const PainterEffectData({
    required this.particles,
    required this.color,
    required this.intensity,
    this.colorWaveProgress = 0,
    this.frostProgress = 0,
  });
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  REACTION PAINTER â€” Multi-Effect CustomPainter
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class ReactionPainter extends CustomPainter {
  final double fillLevel;
  final Color liquidColor;
  final double wavePhase;
  final List<Bubble> bubbles;
  final double heatGlow;
  final bool isEmpty;
  final Map<ReactionEffect, PainterEffectData> effects;
  final Color heatColor;

  ReactionPainter({
    required this.fillLevel,
    required this.liquidColor,
    required this.wavePhase,
    required this.bubbles,
    required this.heatGlow,
    required this.isEmpty,
    required this.effects,
    this.heatColor = const Color(0xFFFF6F00),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final beakerLeft = w * 0.15;
    final beakerRight = w * 0.85;
    final beakerTop = h * 0.08;
    final beakerBottom = h * 0.88;
    final beakerWidth = beakerRight - beakerLeft;
    final beakerHeight = beakerBottom - beakerTop;

    final lipLeft = beakerLeft - w * 0.03;
    final lipRight = beakerRight + w * 0.03;
    final lipTop = beakerTop - h * 0.02;

    // â”€â”€â”€ 1. Glow Effect (behind everything) â”€â”€â”€
    _paintGlow(canvas, w, h, beakerLeft, beakerRight, beakerBottom, beakerWidth, beakerHeight);

    // â”€â”€â”€ 2. Frost Effect (on glass, behind liquid) â”€â”€â”€
    _paintFrost(canvas, beakerLeft, beakerRight, beakerTop, beakerBottom, beakerWidth, beakerHeight);

    // â”€â”€â”€ 3. Glass Body â”€â”€â”€
    final glassPaint = Paint()
      ..color = const Color(0x15FFFFFF)
      ..style = PaintingStyle.fill;

    final glassPath = Path()
      ..moveTo(lipLeft, lipTop)
      ..lineTo(beakerLeft, beakerTop)
      ..lineTo(beakerLeft, beakerBottom)
      ..quadraticBezierTo(beakerLeft, beakerBottom + h * 0.04,
          beakerLeft + beakerWidth * 0.15, beakerBottom + h * 0.04)
      ..lineTo(beakerRight - beakerWidth * 0.15, beakerBottom + h * 0.04)
      ..quadraticBezierTo(beakerRight, beakerBottom + h * 0.04,
          beakerRight, beakerBottom)
      ..lineTo(beakerRight, beakerTop)
      ..lineTo(lipRight, lipTop)
      ..close();

    canvas.drawPath(glassPath, glassPaint);

    // â”€â”€â”€ 4. Color Wave (inside liquid, before liquid) â”€â”€â”€
    _paintColorWave(canvas, beakerLeft, beakerTop, beakerWidth, beakerHeight, beakerBottom);

    // â”€â”€â”€ 5. Liquid Fill â”€â”€â”€
    _paintLiquid(canvas, beakerLeft, beakerRight, beakerTop, beakerBottom,
        beakerWidth, beakerHeight, h);

    // â”€â”€â”€ 6. Precipitate (inside liquid, falling) â”€â”€â”€
    _paintPrecipitate(canvas, beakerLeft, beakerTop, beakerWidth, beakerHeight);

    // â”€â”€â”€ 7. Crystallize (inside liquid, growing) â”€â”€â”€
    _paintCrystallize(canvas, beakerLeft, beakerTop, beakerWidth, beakerHeight);

    // â”€â”€â”€ 8. Beaker Outline â”€â”€â”€
    _paintOutline(canvas, beakerLeft, beakerRight, beakerTop, beakerBottom,
        beakerWidth, beakerHeight, lipLeft, lipRight, lipTop, w, h);

    // â”€â”€â”€ 9. Above-Surface Effects â”€â”€â”€
    _paintSmoke(canvas, beakerLeft, beakerTop, beakerWidth, beakerHeight);
    _paintFlame(canvas, beakerLeft, beakerTop, beakerWidth, beakerHeight);
    _paintFoam(canvas, beakerLeft, beakerTop, beakerWidth, beakerHeight);
    _paintGasRelease(canvas, beakerLeft, beakerTop, beakerWidth, beakerHeight);
    _paintSparks(canvas, beakerLeft, beakerTop, beakerWidth, beakerHeight);

    // â”€â”€â”€ 10. Empty State â”€â”€â”€
    if (isEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'ðŸ§ª',
          style: TextStyle(fontSize: w * 0.15, color: AppColors.textMuted.withAlpha(60)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset((w - textPainter.width) / 2, beakerTop + beakerHeight * 0.35));
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  //  EFFECT RENDERERS
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _paintGlow(Canvas canvas, double w, double h,
      double bL, double bR, double bB, double bW, double bH) {
    // Custom glow from glow effect layers
    final glowData = effects[ReactionEffect.glow];
    if (glowData != null) {
      final glowPaint = Paint()
        ..shader = RadialGradient(colors: [
          glowData.color.withAlpha((glowData.intensity * 60).toInt()),
          Colors.transparent,
        ]).createShader(Rect.fromCenter(
          center: Offset(w * 0.5, bB),
          width: bW * 1.8, height: bH * 1.0,
        ));
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), glowPaint);
    }
    // Legacy heat glow
    if (heatGlow > 0.05) {
      final glowPaint = Paint()
        ..shader = RadialGradient(colors: [
          heatColor.withAlpha((heatGlow * 50).toInt()),
          Colors.transparent,
        ]).createShader(Rect.fromCenter(
          center: Offset(w * 0.5, bB),
          width: bW * 1.5, height: bH * 0.8,
        ));
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), glowPaint);
    }
  }

  void _paintFrost(Canvas canvas, double bL, double bR, double bT,
      double bB, double bW, double bH) {
    final frostData = effects[ReactionEffect.frost];
    if (frostData == null) return;

    final progress = frostData.frostProgress;
    if (progress < 0.01) return;

    final frostPaint = Paint()
      ..color = frostData.color.withAlpha((progress * 80).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw frost crystal patterns on vessel walls
    final segments = (progress * 12).toInt();
    final rng = Random(42); // Deterministic for consistent pattern
    for (int i = 0; i < segments; i++) {
      final startY = bT + rng.nextDouble() * bH * 0.8;
      final side = i % 2 == 0 ? bL : bR;
      final dir = i % 2 == 0 ? 1.0 : -1.0;
      final len = 5.0 + rng.nextDouble() * 15.0 * progress;

      // Main branch
      canvas.drawLine(
        Offset(side, startY),
        Offset(side + dir * len, startY - len * 0.5),
        frostPaint,
      );
      // Side branches
      if (progress > 0.3) {
        final midX = side + dir * len * 0.5;
        final midY = startY - len * 0.25;
        canvas.drawLine(
          Offset(midX, midY),
          Offset(midX + dir * len * 0.3, midY - len * 0.3),
          frostPaint,
        );
        canvas.drawLine(
          Offset(midX, midY),
          Offset(midX + dir * len * 0.3, midY + len * 0.2),
          frostPaint,
        );
      }
    }
  }

  void _paintColorWave(Canvas canvas, double bL, double bT,
      double bW, double bH, double bB) {
    final cwData = effects[ReactionEffect.colorWave];
    if (cwData == null) return;

    final progress = cwData.colorWaveProgress.clamp(0.0, 1.0);
    if (progress < 0.01) return;

    final liquidTop = bB - (fillLevel * bH);
    final centerX = bL + bW * 0.5;
    final centerY = (liquidTop + bB) * 0.5;
    final maxRadius = bW * 0.6;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          cwData.color.withAlpha((progress * 120).toInt()),
          cwData.color.withAlpha((progress * 60).toInt()),
          Colors.transparent,
        ],
        stops: [0, progress * 0.7, progress],
      ).createShader(Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: maxRadius * progress,
      ));

    // Clip to beaker interior
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(bL + 2, liquidTop, bL + bW - 2, bB));
    canvas.drawCircle(Offset(centerX, centerY), maxRadius * progress, paint);
    canvas.restore();
  }

  void _paintLiquid(Canvas canvas, double bL, double bR, double bT,
      double bB, double bW, double bH, double h) {
    if (fillLevel < 0.01 || (liquidColor.a * 255).round() < 1) return;

    final liquidTop = bB - (fillLevel * bH);
    final liquidPath = Path();
    liquidPath.moveTo(bL, bB);
    liquidPath.lineTo(bL, bB + (bB + h * 0.04 - bB) * 0.5);
    liquidPath.quadraticBezierTo(bL, bB + h * 0.04,
        bL + bW * 0.15, bB + h * 0.04);
    liquidPath.lineTo(bR - bW * 0.15, bB + h * 0.04);
    liquidPath.quadraticBezierTo(bR, bB + h * 0.04, bR, bB);
    liquidPath.lineTo(bR, liquidTop);

    final waveAmp = fillLevel > 0.1 ? h * 0.008 : 0.0;
    const segments = 20;
    for (int i = segments; i >= 0; i--) {
      final t = i / segments;
      final px = bL + t * bW;
      final py = liquidTop +
          sin(wavePhase + t * pi * 4) * waveAmp +
          cos(wavePhase * 1.3 + t * pi * 2) * waveAmp * 0.5;
      liquidPath.lineTo(px, py);
    }
    liquidPath.close();

    final liquidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          liquidColor.withAlpha(((liquidColor.a * 255).round() * 0.7).toInt()),
          liquidColor,
          liquidColor.withAlpha(((liquidColor.a * 255).round() * 0.9).toInt()),
        ],
      ).createShader(Rect.fromLTRB(bL, liquidTop, bR, bB + h * 0.04));

    canvas.drawPath(liquidPath, liquidPaint);

    // â”€â”€â”€ Bubbles inside liquid â”€â”€â”€
    for (final b in bubbles) {
      if (b.y < (1.0 - fillLevel)) continue;
      final bx = bL + b.x * bW;
      final by = bT + b.y * bH;
      final bubblePaint = Paint()
        ..color = Colors.white.withAlpha((b.opacity * 180).toInt())
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(bx, by), b.radius, bubblePaint);
      final hlPaint = Paint()
        ..color = Colors.white.withAlpha((b.opacity * 80).toInt())
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(bx - b.radius * 0.3, by - b.radius * 0.3),
        b.radius * 0.35, hlPaint,
      );
    }
  }

  void _paintPrecipitate(Canvas canvas, double bL, double bT,
      double bW, double bH) {
    final data = effects[ReactionEffect.precipitate];
    if (data == null) return;

    for (final p in data.particles) {
      final px = bL + p.x * bW;
      final py = bT + p.y * bH;
      final paint = Paint()
        ..color = p.color.withAlpha((p.opacity * 200).toInt())
        ..style = PaintingStyle.fill;
      // Draw as small irregular shapes
      canvas.drawOval(
        Rect.fromCenter(center: Offset(px, py),
            width: p.size * 1.3, height: p.size * 0.9),
        paint,
      );
      // Highlight
      final hl = Paint()
        ..color = Colors.white.withAlpha((p.opacity * 40).toInt());
      canvas.drawCircle(
        Offset(px - p.size * 0.2, py - p.size * 0.2),
        p.size * 0.25, hl,
      );
    }
  }

  void _paintCrystallize(Canvas canvas, double bL, double bT,
      double bW, double bH) {
    final data = effects[ReactionEffect.crystallize];
    if (data == null) return;

    for (final p in data.particles) {
      if (p.opacity < 0.05) continue;
      final px = bL + p.x * bW;
      final py = bT + p.y * bH;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation);

      // Draw hexagonal crystal
      final paint = Paint()
        ..color = p.color.withAlpha((p.opacity * 180).toInt())
        ..style = PaintingStyle.fill;
      final outline = Paint()
        ..color = p.color.withAlpha((p.opacity * 100).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;

      final path = Path();
      for (int i = 0; i < 6; i++) {
        final angle = i * pi / 3;
        final x = cos(angle) * p.size;
        final y = sin(angle) * p.size;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
      canvas.drawPath(path, outline);

      canvas.restore();
    }
  }

  void _paintSmoke(Canvas canvas, double bL, double bT,
      double bW, double bH) {
    final data = effects[ReactionEffect.smoke];
    if (data == null) return;

    for (final p in data.particles) {
      if (p.opacity < 0.02) continue;
      final px = bL + p.x * bW;
      final py = bT + p.y * bH;

      final paint = Paint()
        ..shader = RadialGradient(colors: [
          p.color.withAlpha((p.opacity * 120).toInt()),
          p.color.withAlpha((p.opacity * 30).toInt()),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(center: Offset(px, py), radius: p.size));
      canvas.drawCircle(Offset(px, py), p.size, paint);
    }
  }

  void _paintFlame(Canvas canvas, double bL, double bT,
      double bW, double bH) {
    final data = effects[ReactionEffect.flame];
    if (data == null) return;

    for (final p in data.particles) {
      if (p.opacity < 0.05) continue;
      final px = bL + p.x * bW;
      final py = bT + p.y * bH;

      // Draw teardrop/flame shape
      final path = Path();
      path.moveTo(px, py - p.size * 1.5);  // Tip
      path.quadraticBezierTo(
        px + p.size * 0.8, py - p.size * 0.3,
        px, py + p.size * 0.5,  // Bottom
      );
      path.quadraticBezierTo(
        px - p.size * 0.8, py - p.size * 0.3,
        px, py - p.size * 1.5,  // Back to tip
      );

      // Inner bright core
      final innerPaint = Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withAlpha((p.opacity * 150).toInt()),
          p.color.withAlpha((p.opacity * 200).toInt()),
          p.color.withAlpha((p.opacity * 50).toInt()),
        ], stops: const [0, 0.3, 1.0]).createShader(
          Rect.fromCircle(center: Offset(px, py - p.size * 0.3), radius: p.size),
        );

      canvas.drawPath(path, innerPaint);

      // Outer glow
      final glowPaint = Paint()
        ..color = p.color.withAlpha((p.opacity * 30).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(px, py - p.size * 0.5), p.size * 1.2, glowPaint);
    }
  }

  void _paintFoam(Canvas canvas, double bL, double bT,
      double bW, double bH) {
    final data = effects[ReactionEffect.foam];
    if (data == null) return;

    for (final p in data.particles) {
      if (p.opacity < 0.05) continue;
      final px = bL + p.x * bW;
      final py = bT + p.y * bH;

      // Bubble with surface tension effect
      final paint = Paint()
        ..color = p.color.withAlpha((p.opacity * 100).toInt())
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(px, py), p.size, paint);

      // Shiny rim
      final rimPaint = Paint()
        ..color = Colors.white.withAlpha((p.opacity * 60).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7;
      canvas.drawCircle(Offset(px, py), p.size, rimPaint);

      // Highlight
      final hlPaint = Paint()
        ..color = Colors.white.withAlpha((p.opacity * 50).toInt());
      canvas.drawCircle(
        Offset(px - p.size * 0.3, py - p.size * 0.3),
        p.size * 0.3, hlPaint,
      );
    }
  }

  void _paintGasRelease(Canvas canvas, double bL, double bT,
      double bW, double bH) {
    final data = effects[ReactionEffect.gasRelease];
    if (data == null) return;

    for (final p in data.particles) {
      if (p.opacity < 0.03) continue;
      final px = bL + p.x * bW;
      final py = bT + p.y * bH;

      if (p.y > 0.25) {
        // Inside liquid: large defined bubbles
        final paint = Paint()
          ..color = p.color.withAlpha((p.opacity * 80).toInt())
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(px, py), p.size * 0.7, paint);
        final rimPaint = Paint()
          ..color = Colors.white.withAlpha((p.opacity * 100).toInt())
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(Offset(px, py), p.size * 0.7, rimPaint);
      } else {
        // Above surface: diffuse gas cloud
        final paint = Paint()
          ..shader = RadialGradient(colors: [
            p.color.withAlpha((p.opacity * 60).toInt()),
            Colors.transparent,
          ]).createShader(
            Rect.fromCircle(center: Offset(px, py), radius: p.size * 1.5),
          );
        canvas.drawCircle(Offset(px, py), p.size * 1.5, paint);
      }
    }
  }

  void _paintSparks(Canvas canvas, double bL, double bT,
      double bW, double bH) {
    final data = effects[ReactionEffect.sparks];
    if (data == null) return;

    for (final p in data.particles) {
      if (p.opacity < 0.05) continue;
      final px = bL + p.x * bW;
      final py = bT + p.y * bH;

      // Bright core
      final corePaint = Paint()
        ..color = Colors.white.withAlpha((p.opacity * 230).toInt())
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(px, py), p.size * 0.5, corePaint);

      // Colored glow around core
      final glowPaint = Paint()
        ..color = p.color.withAlpha((p.opacity * 150).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(px, py), p.size, glowPaint);

      // Tiny trail behind spark
      final trailPaint = Paint()
        ..color = p.color.withAlpha((p.opacity * 80).toInt())
        ..strokeWidth = 0.8
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(px, py),
        Offset(px - p.vx * 40, py - p.vy * 40),
        trailPaint,
      );
    }
  }

  void _paintOutline(Canvas canvas, double bL, double bR, double bT,
      double bB, double bW, double bH, double lipL, double lipR,
      double lipT, double w, double h) {
    final outlinePaint = Paint()
      ..color = const Color(0x40FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(bL, bT), Offset(bL, bB), outlinePaint);
    canvas.drawLine(Offset(bR, bT), Offset(bR, bB), outlinePaint);

    final bottomPath = Path()
      ..moveTo(bL, bB)
      ..quadraticBezierTo(bL, bB + h * 0.04,
          bL + bW * 0.15, bB + h * 0.04)
      ..lineTo(bR - bW * 0.15, bB + h * 0.04)
      ..quadraticBezierTo(bR, bB + h * 0.04, bR, bB);
    canvas.drawPath(bottomPath, outlinePaint);

    final lipPaint = Paint()
      ..color = const Color(0x50FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(lipL, lipT), Offset(bL, bT), lipPaint);
    canvas.drawLine(Offset(lipR, lipT), Offset(bR, bT), lipPaint);

    // Graduation marks
    final markPaint = Paint()
      ..color = const Color(0x20FFFFFF)
      ..strokeWidth = 1.0;
    for (int i = 1; i <= 4; i++) {
      final markY = bB - (i / 5) * bH;
      canvas.drawLine(Offset(bL, markY), Offset(bL + bW * 0.12, markY), markPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ReactionPainter old) => true;
}

