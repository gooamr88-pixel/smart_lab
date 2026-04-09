import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../models/lab_item.dart';
import '../providers/locale_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/reaction_painter.dart';

/// Immersive 2D Chemistry Lab with drag-and-drop tools and animated reactions.
///
/// Receives tool names from the AI and resolves them into interactive [LabItem]s.
/// Tools are displayed on a shelf and can be dragged onto the workbench vessel.
class ChemLabScreen extends StatefulWidget {
  /// Tool name strings from the AI's `open_lab` response
  final List<String> toolNames;

  const ChemLabScreen({super.key, required this.toolNames});

  @override
  State<ChemLabScreen> createState() => _ChemLabScreenState();
}

class _ChemLabScreenState extends State<ChemLabScreen>
    with TickerProviderStateMixin {
  // ─── State ───
  late List<LabItem> _shelfItems;
  final List<LabItem> _vesselContents = [];
  ChemReaction? _activeReaction;
  double _fillLevel = 0.0;
  bool _isDragOver = false;

  // ─── Animations ───
  late AnimationController _shelfEntryController;
  late AnimationController _dropFlashController;
  late Animation<double> _dropFlash;

  @override
  void initState() {
    super.initState();

    // Resolve AI tool names to LabItems
    _shelfItems = LabItemRegistry.resolveAll(widget.toolNames);

    // Shelf entrance animation
    _shelfEntryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Flash animation when item is dropped
    _dropFlashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _dropFlash = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _dropFlashController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _shelfEntryController.dispose();
    _dropFlashController.dispose();
    super.dispose();
  }

  void _onItemDropped(LabItem item) {
    final hadReaction = _activeReaction != null;

    setState(() {
      _vesselContents.add(item);

      // Update fill level (each item adds ~20%)
      _fillLevel = (_vesselContents.length * 0.2).clamp(0.0, 0.85);

      // Check for reactions
      final ids = _vesselContents.map((i) => i.id).toSet();
      _activeReaction = LabItemRegistry.findReaction(ids);
    });

    // Trigger drop flash
    _dropFlashController.forward(from: 0);

    // Award XP when a NEW reaction is triggered
    if (_activeReaction != null && !hadReaction) {
      context.read<ProgressProvider>().completeExperiment(context: context);
    }
  }

  void _resetVessel() {
    setState(() {
      _vesselContents.clear();
      _activeReaction = null;
      _fillLevel = 0.0;
      _shelfItems = LabItemRegistry.resolveAll(widget.toolNames);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isArabic = locale.isArabic;

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(isArabic),
        body: Stack(
          children: [
            // ─── Background Lab Ambiance ───
            _LabBackground(),

            // ─── Main Content ───
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // ─── SHELF ───
                  _buildShelf(isArabic),

                  // ─── WORKBENCH ───
                  Expanded(
                    child: _buildWorkbench(isArabic),
                  ),

                  // ─── REACTION INFO PANEL ───
                  _buildInfoPanel(isArabic),
                ],
              ),
            ),

            // ─── Drop Flash Overlay ───
            AnimatedBuilder(
              animation: _dropFlash,
              builder: (context, _) {
                if (_dropFlash.value <= 0.01) return const SizedBox.shrink();
                return IgnorePointer(
                  child: Container(
                    color: Colors.white
                        .withAlpha((15 * (1 - _dropFlash.value)).toInt()),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: _vesselContents.isNotEmpty
            ? FloatingActionButton.small(
                backgroundColor: AppColors.danger.withAlpha(200),
                onPressed: _resetVessel,
                child: const Icon(Icons.refresh_rounded,
                    color: Colors.white, size: 20),
              )
            : null,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  APP BAR
  // ═══════════════════════════════════════════════════════════════

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
          const Text('⚗️', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(
            isArabic ? 'المعمل الافتراضي' : 'Virtual Lab',
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

  // ═══════════════════════════════════════════════════════════════
  //  SHELF — Draggable Tools
  // ═══════════════════════════════════════════════════════════════

  Widget _buildShelf(bool isArabic) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shelf label
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.shelves, size: 14,
                    color: AppColors.accent.withAlpha(180)),
                const SizedBox(width: 6),
                Text(
                  isArabic ? 'رف الأدوات' : 'Tool Shelf',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                const Spacer(),
                Text(
                  isArabic ? 'اسحب للأسفل ↓' : 'Drag down ↓',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.textMuted.withAlpha(120),
                  ),
                ),
              ],
            ),
          ),

          // Tool items
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _shelfItems.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _shelfEntryController,
                  builder: (context, child) {
                    final delay = index * 0.12;
                    final t = Curves.easeOutBack.transform(
                      ((_shelfEntryController.value - delay) / (1 - delay))
                          .clamp(0.0, 1.0),
                    );
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - t)),
                      child: Opacity(opacity: t, child: child),
                    );
                  },
                  child: _buildDraggableItem(_shelfItems[index], isArabic),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableItem(LabItem item, bool isArabic) {
    final alreadyUsed = _vesselContents.contains(item);

    return Draggable<LabItem>(
      data: item,
      maxSimultaneousDrags: alreadyUsed ? 0 : 1,
      feedback: Material(
        color: Colors.transparent,
        child: _ShelfItemCard(item: item, isArabic: isArabic, isDragging: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _ShelfItemCard(item: item, isArabic: isArabic),
      ),
      child: Opacity(
        opacity: alreadyUsed ? 0.4 : 1.0,
        child: _ShelfItemCard(item: item, isArabic: isArabic),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  WORKBENCH — DragTarget + ReactionVessel
  // ═══════════════════════════════════════════════════════════════

  Widget _buildWorkbench(bool isArabic) {
    return DragTarget<LabItem>(
      onWillAcceptWithDetails: (details) {
        if (!_isDragOver) setState(() => _isDragOver = true);
        return !_vesselContents.contains(details.data);
      },
      onLeave: (_) {
        if (_isDragOver) setState(() => _isDragOver = false);
      },
      onAcceptWithDetails: (details) {
        setState(() => _isDragOver = false);
        _onItemDropped(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: AppDurations.fast,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF111525),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isDragOver
                  ? AppColors.accent.withAlpha(80)
                  : Colors.white.withAlpha(6),
              width: _isDragOver ? 2 : 1,
            ),
            boxShadow: [
              if (_isDragOver)
                BoxShadow(
                  color: AppColors.accent.withAlpha(20),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Grid pattern on workbench surface
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CustomPaint(
                    painter: _GridPainter(),
                  ),
                ),
              ),

              // Reaction Vessel (Beaker)
              Center(
                child: SizedBox(
                  width: 200,
                  height: 260,
                  child: ReactionVessel(
                    contents: _vesselContents,
                    reaction: _activeReaction,
                    fillLevel: _fillLevel,
                  ),
                ),
              ),

              // Added Items indicators (small chips at top of vessel)
              if (_vesselContents.isNotEmpty)
                Positioned(
                  top: 16,
                  child: Wrap(
                    spacing: 6,
                    children: _vesselContents.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: item.color.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: item.color.withAlpha(50)),
                        ),
                        child: Text(
                          '${item.emoji} ${isArabic ? item.nameAr : item.name}',
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Drop zone hint
              if (_vesselContents.isEmpty && !_isDragOver)
                Positioned(
                  bottom: 24,
                  child: Text(
                    isArabic
                        ? 'اسحب الأدوات هنا'
                        : 'Drop tools here',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppColors.textMuted.withAlpha(80),
                    ),
                  ),
                ),

              // Active drag highlight
              if (_isDragOver)
                Positioned(
                  bottom: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withAlpha(15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.accent.withAlpha(40)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_circle_outline,
                            size: 16, color: AppColors.accent),
                        const SizedBox(width: 6),
                        Text(
                          isArabic ? 'أفلت هنا!' : 'Drop here!',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  INFO PANEL — Reaction Status
  // ═══════════════════════════════════════════════════════════════

  Widget _buildInfoPanel(bool isArabic) {
    return AnimatedContainer(
      duration: AppDurations.normal,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _activeReaction != null
            ? const Color(0xFF1A2520)
            : const Color(0xFF1A1E2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _activeReaction != null
              ? AppColors.success.withAlpha(30)
              : Colors.white.withAlpha(6),
        ),
      ),
      child: _activeReaction != null
          ? _buildReactionInfo(isArabic)
          : _buildIdleInfo(isArabic),
    );
  }

  Widget _buildReactionInfo(bool isArabic) {
    final r = _activeReaction!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reaction title
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isArabic ? '⚡ تفاعل!' : '⚡ Reaction!',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isArabic ? r.nameAr : r.name,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Equation
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            r.equation,
            style: GoogleFonts.sourceCodePro(
              fontSize: 14,
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),

        // Description
        Text(
          isArabic ? r.descriptionAr : r.description,
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        ),

        const SizedBox(height: 8),

        // Intensity meters
        Row(
          children: [
            _IntensityMeter(
              label: isArabic ? 'فوران' : 'Fizz',
              value: r.bubbleIntensity,
              color: const Color(0xFF4FC3F7),
            ),
            const SizedBox(width: 12),
            _IntensityMeter(
              label: isArabic ? 'حرارة' : 'Heat',
              value: r.heatIntensity,
              color: const Color(0xFFFF8A65),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIdleInfo(bool isArabic) {
    final count = _vesselContents.length;
    return Row(
      children: [
        Icon(
          count > 0 ? Icons.science_rounded : Icons.info_outline_rounded,
          size: 18,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            count == 0
                ? (isArabic
                    ? 'اسحب الأدوات من الرف إلى الدورق لبدء التجربة'
                    : 'Drag tools from the shelf into the beaker to start')
                : (isArabic
                    ? '$count أداة في الدورق — جرب إضافة المزيد!'
                    : '$count item${count > 1 ? 's' : ''} in vessel — try adding more!'),
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  SHELF ITEM CARD
// ═════════════════════════════════════════════════════════════════

class _ShelfItemCard extends StatelessWidget {
  final LabItem item;
  final bool isArabic;
  final bool isDragging;

  const _ShelfItemCard({
    required this.item,
    required this.isArabic,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: isDragging
            ? item.color.withAlpha(30)
            : const Color(0xFF252A3E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDragging
              ? item.color.withAlpha(80)
              : Colors.white.withAlpha(8),
          width: isDragging ? 1.5 : 1,
        ),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: item.color.withAlpha(40),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.emoji,
            style: TextStyle(fontSize: isDragging ? 28 : 24),
          ),
          const SizedBox(height: 4),
          Text(
            isArabic ? item.nameAr : item.name,
            style: GoogleFonts.cairo(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          // Type badge
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: _typeColor(item.type).withAlpha(20),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _typeLabel(item.type, isArabic),
              style: GoogleFonts.inter(
                fontSize: 7,
                fontWeight: FontWeight.w600,
                color: _typeColor(item.type),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _typeColor(LabItemType type) {
    switch (type) {
      case LabItemType.chemical:
        return const Color(0xFF4FC3F7);
      case LabItemType.container:
        return const Color(0xFFB0BEC5);
      case LabItemType.tool:
        return const Color(0xFFFFB74D);
      case LabItemType.indicator:
        return const Color(0xFFE91E63);
    }
  }

  String _typeLabel(LabItemType type, bool isArabic) {
    switch (type) {
      case LabItemType.chemical:
        return isArabic ? 'مادة' : 'CHEM';
      case LabItemType.container:
        return isArabic ? 'وعاء' : 'CONT';
      case LabItemType.tool:
        return isArabic ? 'أداة' : 'TOOL';
      case LabItemType.indicator:
        return isArabic ? 'كاشف' : 'IND';
    }
  }
}

// ═════════════════════════════════════════════════════════════════
//  INTENSITY METER
// ═════════════════════════════════════════════════════════════════

class _IntensityMeter extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _IntensityMeter({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.white.withAlpha(10),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  LAB BACKGROUND — Ambient Grid Pattern
// ═════════════════════════════════════════════════════════════════

class _LabBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.2,
          colors: [
            Color(0xFF141830),
            Color(0xFF0A0E1A),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  GRID PAINTER — Workbench Surface
// ═════════════════════════════════════════════════════════════════

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(4)
      ..strokeWidth = 0.5;

    const spacing = 24.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => false;
}
