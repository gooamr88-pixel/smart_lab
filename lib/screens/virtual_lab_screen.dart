
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/experiment.dart';
import '../providers/locale_provider.dart';
import '../providers/lab_provider.dart';
import '../providers/image_gen_provider.dart';
import '../providers/progress_provider.dart';
import '../services/huggingface_service.dart';
import '../services/model_assets.dart';
import '../widgets/model_viewer_widget.dart';
import '../widgets/ai_image_widget.dart';
import 'quiz_screen.dart';

/// Professional 3D Virtual Lab screen with glassmorphism and interactive tools
class VirtualLabScreen extends StatefulWidget {
  final Experiment experiment;

  const VirtualLabScreen({super.key, required this.experiment});

  @override
  State<VirtualLabScreen> createState() => _VirtualLabScreenState();
}

class _VirtualLabScreenState extends State<VirtualLabScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _pulseController;
  late Animation<double> _headerFade;
  late Animation<double> _viewerFade;
  late Animation<double> _panelSlide;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0, 0.4, curve: Curves.easeOut),
      ),
    );
    _viewerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );
    _panelSlide = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.4, 1, curve: Curves.easeOutCubic),
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Load experiment and start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LabProvider>().loadExperiment(widget.experiment);

      final expKey = 'lab_${widget.experiment.name.hashCode.abs()}';
      context.read<ImageGenProvider>().generateImage(
            expKey,
            ImagePrompts.forExperiment(
              widget.experiment.name,
              widget.experiment.subject,
            ),
          );
    });

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToQuiz() {
    // Award XP for completing experiment
    context.read<ProgressProvider>().completeExperiment();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            QuizScreen(experiment: widget.experiment),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: AppDurations.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final l10n = AppLocalizations(locale.locale);
    final labProvider = context.watch<LabProvider>();
    final expKey = 'lab_${widget.experiment.name.hashCode.abs()}';
    final progress = widget.experiment.tools.isEmpty
        ? 0.0
        : labProvider.placedTools.length / widget.experiment.tools.length;

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Stack(
          children: [
            // AI-generated lab background
            Positioned.fill(
              child: AiImageWidget(
                imageKey: expKey,
                prompt: ImagePrompts.forExperiment(
                  widget.experiment.name,
                  widget.experiment.subject,
                ),
                showOverlay: false,
              ),
            ),
            // Dark overlay
            Positioned.fill(
              child: Container(color: AppColors.surface.withAlpha(230)),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // ─── Header ───
                  FadeTransition(
                    opacity: _headerFade,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          // Back button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(10),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.white.withAlpha(15)),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_rounded,
                                color: AppColors.textPrimary,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Title
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.get('virtual_lab'),
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  widget.experiment.name,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Progress ring
                          _ProgressRing(
                            progress: progress,
                            placed: labProvider.placedTools.length,
                            total: widget.experiment.tools.length,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── 3D Viewer ───
                  Expanded(
                    flex: 5,
                    child: FadeTransition(
                      opacity: _viewerFade,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.primaryLight.withAlpha(
                                (20 * _pulse.value).toInt(),
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryLight.withAlpha(
                                  (15 * _pulse.value).toInt(),
                                ),
                                blurRadius: 30,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: ModelViewerWidget(
                              modelUrl: labProvider.selectedModelUrl,
                              alt: widget.experiment.name,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ─── Tools Panel (glassmorphism) ───
                  AnimatedBuilder(
                    animation: _panelSlide,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 100 * _panelSlide.value),
                        child: Opacity(
                          opacity: (1 - _panelSlide.value).clamp(0, 1),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard.withAlpha(220),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        border: Border.all(
                          color: Colors.white.withAlpha(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 20,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Panel header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primaryLight.withAlpha(20),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.build_circle_outlined,
                                    color: AppColors.primaryLight,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    l10n.get('lab_tools'),
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Spacer(),
                                if (labProvider.allToolsPlaced)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withAlpha(20),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      l10n.get('experiment_ready'),
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Tools grid
                          SizedBox(
                            height: 120,
                            child: widget.experiment.tools.isEmpty
                                ? Center(
                                    child: Text(
                                      l10n.get('no_tools'),
                                      style: GoogleFonts.cairo(
                                        color: AppColors.textMuted,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    itemCount:
                                        widget.experiment.tools.length,
                                    itemBuilder: (context, index) {
                                      final tool =
                                          widget.experiment.tools[index];
                                      final isPlaced =
                                          labProvider.isToolPlaced(tool);
                                      final isSelected =
                                          labProvider.selectedToolIndex ==
                                              index;

                                      return _ToolCard(
                                        tool: tool,
                                        isPlaced: isPlaced,
                                        isSelected: isSelected,
                                        onTap: () {
                                          labProvider.selectTool(index);
                                          if (!isPlaced) {
                                            labProvider.placeTool(tool);
                                          }
                                        },
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  // ─── Complete Button ───
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: AnimatedContainer(
                        duration: AppDurations.normal,
                        child: ElevatedButton(
                          onPressed: labProvider.allToolsPlaced
                              ? _navigateToQuiz
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: labProvider.allToolsPlaced
                                ? AppColors.accent
                                : AppColors.surfaceLight,
                            foregroundColor: labProvider.allToolsPlaced
                                ? AppColors.primaryDark
                                : AppColors.textMuted,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: labProvider.allToolsPlaced ? 8 : 0,
                            shadowColor: labProvider.allToolsPlaced
                                ? AppColors.accent.withAlpha(80)
                                : Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                labProvider.allToolsPlaced
                                    ? Icons.check_circle_outline
                                    : Icons.lock_outline,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  l10n.get('complete_experiment'),
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Progress Ring Widget ───

class _ProgressRing extends StatelessWidget {
  final double progress;
  final int placed;
  final int total;

  const _ProgressRing({
    required this.progress,
    required this.placed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 3,
              color: AppColors.surfaceLight,
            ),
          ),
          // Progress ring
          SizedBox(
            width: 44,
            height: 44,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: AppDurations.slow,
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 3,
                  strokeCap: StrokeCap.round,
                  color: progress >= 1
                      ? AppColors.success
                      : AppColors.primaryLight,
                );
              },
            ),
          ),
          // Counter text
          Text(
            '$placed/$total',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: progress >= 1
                  ? AppColors.success
                  : AppColors.primaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tool Card Widget ───

class _ToolCard extends StatefulWidget {
  final LabTool tool;
  final bool isPlaced;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToolCard({
    required this.tool,
    required this.isPlaced,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void didUpdateWidget(covariant _ToolCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaced && !oldWidget.isPlaced) {
      _glowController.forward(from: 0).then((_) => _glowController.reverse());
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emoji = ModelAssets.getIconForTool(widget.tool.name);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            width: 100,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: widget.isPlaced
                  ? AppColors.success.withAlpha(15)
                  : widget.isSelected
                      ? AppColors.primaryLight.withAlpha(15)
                      : AppColors.surfaceLight.withAlpha(180),
              border: Border.all(
                color: widget.isPlaced
                    ? AppColors.success.withAlpha(60)
                    : widget.isSelected
                        ? AppColors.primaryLight.withAlpha(40)
                        : Colors.white.withAlpha(8),
                width: widget.isSelected || widget.isPlaced ? 1.5 : 1,
              ),
              boxShadow: _glowController.isAnimating
                  ? [
                      BoxShadow(
                        color: AppColors.success
                            .withAlpha((80 * _glowController.value).toInt()),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : widget.isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryLight.withAlpha(30),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Status indicator
                if (widget.isPlaced)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  )
                else
                  Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 8),

                // Tool name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    widget.tool.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.isPlaced
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
