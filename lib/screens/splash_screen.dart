import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../providers/progress_provider.dart';
import 'welcome_screen.dart';
import 'dashboard_screen.dart';

/// Professional splash screen with animated "ابدأ" button sliding into a white pill
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _buttonController;
  late AnimationController _particleController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _spinnerOpacity;
  late Animation<double> _pulseAnim;

  late List<_SplashParticle> _particles;

  @override
  void initState() {
    super.initState();

    // Background particle controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    final rng = Random();
    _particles = List.generate(
      30,
      (_) => _SplashParticle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: rng.nextDouble() * 3 + 1,
        speed: rng.nextDouble() * 0.4 + 0.1,
        opacity: rng.nextDouble() * 0.25 + 0.05,
        drift: (rng.nextDouble() - 0.5) * 0.15,
      ),
    );

    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Title text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _subtitleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1, curve: Curves.easeOut),
      ),
    );

    // Spinner fade-in animation
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _spinnerOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeOut,
      ),
    );

    // Pulse glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Unused var
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Staggered sequence
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _buttonController.forward();
    });

    // Auto-navigate after 3 seconds
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) _onStart();
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onStart() {
    // Check if returning user (has XP)
    final progressProvider = context.read<ProgressProvider>();
    final isReturningUser = progressProvider.progress.totalXp > 0;
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            isReturningUser ? const DashboardScreen() : const WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: AppDurations.slow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Deep gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A0E21),
                  Color(0xFF0D1B2A),
                  Color(0xFF0F2027),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Layer 2: Radial glow in center
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) {
              return Center(
                child: Container(
                  width: 400 * _pulseAnim.value,
                  height: 400 * _pulseAnim.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryLight.withAlpha(15),
                        AppColors.primaryMid.withAlpha(8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Layer 3: Floating particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: _SplashParticlePainter(
                  _particles,
                  _particleController.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Layer 4: Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Animated logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryLight.withAlpha(30),
                            AppColors.primaryMid.withAlpha(15),
                            Colors.transparent,
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.primaryLight.withAlpha(40),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryLight.withAlpha(40),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🔬', style: TextStyle(fontSize: 60)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // App title
                  SlideTransition(
                    position: _titleSlide,
                    child: FadeTransition(
                      opacity: _titleOpacity,
                      child: Text(
                        'Skillify',
                        style: GoogleFonts.inter(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Arabic subtitle
                  FadeTransition(
                    opacity: _subtitleOpacity,
                    child: Text(
                      'طوّر مهاراتك بذكاء',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withAlpha(150),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Spinning loader
                  AnimatedBuilder(
                    animation: _buttonController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _spinnerOpacity.value,
                        child: child,
                      );
                    },
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryLight.withAlpha(
                                  (50 * _pulseAnim.value).toInt(),
                                ),
                                blurRadius: 30,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryLight,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Particle system ----------

class _SplashParticle {
  final double x, y, size, speed, opacity, drift;
  _SplashParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.drift,
  });
}

class _SplashParticlePainter extends CustomPainter {
  final List<_SplashParticle> particles;
  final double time;

  _SplashParticlePainter(this.particles, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = Colors.white.withAlpha((p.opacity * 255).toInt())
        ..style = PaintingStyle.fill;

      final yPos = (p.y - time * p.speed) % 1.0;
      final xPos = (p.x + sin(time * 2 * pi + p.drift * 10) * 0.02) % 1.0;

      canvas.drawCircle(
        Offset(xPos * size.width, yPos * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SplashParticlePainter old) => old.time != time;
}
