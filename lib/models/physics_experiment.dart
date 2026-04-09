import 'dart:math';
import 'package:flutter/material.dart';

/// A recorded point along the projectile trajectory.
class TrajectoryPoint {
  final double time;
  final double x;    // meters
  final double y;    // meters
  final double vx;   // m/s
  final double vy;   // m/s

  const TrajectoryPoint({
    required this.time,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
  });

  double get speed => sqrt(vx * vx + vy * vy);
  double get velocityAngle => atan2(vy, vx);
}

/// Physics simulation model for projectile motion.
///
/// Uses standard kinematic equations:
///   x(t) = v₀·cos(θ)·t
///   y(t) = v₀·sin(θ)·t - ½·g·t²
///
/// All units are SI: meters, seconds, m/s, kg.
class PhysicsExperiment {
  final double initialVelocity;  // m/s (5–50)
  final double angle;            // degrees (0–90)
  final double gravity;          // m/s² (default 9.8)
  final double mass;             // kg (for display/energy calcs)

  const PhysicsExperiment({
    this.initialVelocity = 20.0,
    this.angle = 45.0,
    this.gravity = 9.8,
    this.mass = 1.0,
  });

  // ─── Derived Constants ──────────────────────────────────────

  double get angleRad => angle * pi / 180.0;
  double get v0x => initialVelocity * cos(angleRad);
  double get v0y => initialVelocity * sin(angleRad);

  /// Total time of flight (seconds)
  double get timeOfFlight {
    if (gravity <= 0 || angle <= 0) return 0;
    return 2.0 * v0y / gravity;
  }

  /// Maximum height reached (meters)
  double get maxHeight {
    if (gravity <= 0) return 0;
    return (v0y * v0y) / (2.0 * gravity);
  }

  /// Horizontal range (meters)
  double get range {
    if (gravity <= 0) return 0;
    return initialVelocity * initialVelocity * sin(2.0 * angleRad) / gravity;
  }

  /// Time at which max height is reached
  double get timeAtMaxHeight => v0y / gravity;

  /// Kinetic energy at launch (Joules)
  double get kineticEnergy => 0.5 * mass * initialVelocity * initialVelocity;

  /// Potential energy at max height (Joules)
  double get potentialEnergyMax => mass * gravity * maxHeight;

  // ─── Position & Velocity at Time t ──────────────────────────

  /// Horizontal position at time t (meters)
  double xAt(double t) => v0x * t;

  /// Vertical position at time t (meters), clamped to ground
  double yAt(double t) {
    final y = v0y * t - 0.5 * gravity * t * t;
    return y < 0 ? 0 : y;
  }

  /// Raw y (can go negative — used for ground detection)
  double yRawAt(double t) => v0y * t - 0.5 * gravity * t * t;

  /// Horizontal velocity at time t (constant)
  double vxAt(double t) => v0x;

  /// Vertical velocity at time t
  double vyAt(double t) => v0y - gravity * t;

  /// Speed magnitude at time t
  double speedAt(double t) {
    final vx = vxAt(t);
    final vy = vyAt(t);
    return sqrt(vx * vx + vy * vy);
  }

  /// Position as an Offset at time t
  Offset positionAt(double t) => Offset(xAt(t), yAt(t));

  /// Full trajectory point at time t
  TrajectoryPoint pointAt(double t) => TrajectoryPoint(
        time: t,
        x: xAt(t),
        y: yAt(t),
        vx: vxAt(t),
        vy: vyAt(t),
      );

  // ─── Trajectory Generation ──────────────────────────────────

  /// Generates the full predicted trajectory as a list of points.
  /// Used for the preview dotted line before launch.
  List<TrajectoryPoint> generateTrajectory({int steps = 100}) {
    if (timeOfFlight <= 0) return [];

    final dt = timeOfFlight / steps;
    final points = <TrajectoryPoint>[];

    for (int i = 0; i <= steps; i++) {
      final t = i * dt;
      points.add(pointAt(t));
    }

    return points;
  }

  // ─── Copyable ───────────────────────────────────────────────

  PhysicsExperiment copyWith({
    double? initialVelocity,
    double? angle,
    double? gravity,
    double? mass,
  }) {
    return PhysicsExperiment(
      initialVelocity: initialVelocity ?? this.initialVelocity,
      angle: angle ?? this.angle,
      gravity: gravity ?? this.gravity,
      mass: mass ?? this.mass,
    );
  }
}
