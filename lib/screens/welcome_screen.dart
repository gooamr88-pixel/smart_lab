import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../providers/locale_provider.dart';
import '../providers/image_gen_provider.dart';
import '../services/huggingface_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/ai_image_widget.dart';
import 'dashboard_screen.dart';

/// Welcome screen with animated logo, AI-generated background, and language selection
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
    );

    // Start animations staggered
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _slideController.forward();
    });

    // Preload images for welcome and subject screens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ImageGenProvider>().preloadImages({
        'welcome': ImagePrompts.welcome,
        'chemistry': ImagePrompts.chemistry,
        'physics': ImagePrompts.physics,
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _selectLanguage(BuildContext context, bool isArabic) {
    final localeProvider = context.read<LocaleProvider>();
    if (isArabic) {
      localeProvider.setArabic();
    } else {
      localeProvider.setEnglish();
    }
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
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
          // Layer 1: AI-generated background image
          AiImageWidget(
            imageKey: 'welcome',
            prompt: ImagePrompts.welcome,
            showOverlay: false,
            fallback: const GradientBackground(
              showParticles: true,
              child: SizedBox.expand(),
            ),
          ),

          // Layer 2: Dark gradient overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(120),
                  AppColors.primaryDark.withAlpha(200),
                  AppColors.primaryDark.withAlpha(240),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // Layer 3: Floating particles
          const GradientBackground(
            colors: [Colors.transparent, Colors.transparent],
            showParticles: true,
            child: SizedBox.expand(),
          ),

          // Layer 4: Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Animated logo
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(20),
                            border: Border.all(
                              color: Colors.white.withAlpha(40),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryLight.withAlpha(60),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Center(
                            child:
                                Text('🔬', style: TextStyle(fontSize: 56)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // App name
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Smart Lab',
                        style: GoogleFonts.inter(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Arabic subtitle
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'المعمل الذكي التفاعلي',
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withAlpha(200),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description badge
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withAlpha(20),
                          ),
                        ),
                        child: Text(
                          '🧪 Chemistry  •  Physics 🧲',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withAlpha(180),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Language selection buttons
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // Arabic button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primaryDark,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () =>
                                    _selectLanguage(context, true),
                                child: Text(
                                  'ابدأ بالعربية',
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // English button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(
                                    color: Colors.white.withAlpha(60),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () =>
                                    _selectLanguage(context, false),
                                child: Text(
                                  'Start in English',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
