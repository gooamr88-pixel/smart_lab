import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Floating "+50 XP" animation overlay
class XpAnimationWidget extends StatefulWidget {
  final int xpAmount;
  final VoidCallback onComplete;

  const XpAnimationWidget({
    super.key,
    required this.xpAmount,
    required this.onComplete,
  });

  @override
  State<XpAnimationWidget> createState() => _XpAnimationWidgetState();
}

class _XpAnimationWidgetState extends State<XpAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  late Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1, end: 1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 30),
    ]).animate(_controller);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.5, end: 1.3)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 60),
    ]).animate(_controller);

    _position = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -80),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

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
      builder: (context, child) {
        return Transform.translate(
          offset: _position.value,
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withAlpha(80),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Text(
                      '+${widget.xpAmount} XP',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Level-up celebration overlay
class LevelUpOverlay extends StatefulWidget {
  final int newLevel;
  final VoidCallback onDismiss;

  const LevelUpOverlay({
    super.key,
    required this.newLevel,
    required this.onDismiss,
  });

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 10),
    ]).animate(_controller);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1, end: 1), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 15),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onDismiss());
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
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: GestureDetector(
            onTap: widget.onDismiss,
            child: Container(
              color: Colors.black.withAlpha(120),
              child: Center(
                child: Transform.scale(
                  scale: _scale.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Text(
                        'LEVEL UP!',
                        style: GoogleFonts.inter(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFD700),
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withAlpha(80),
                              blurRadius: 30,
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
              ),
            ),
          ),
        );
      },
    );
  }
}
