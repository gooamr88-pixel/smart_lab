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

/// Chemistry simulation screen:
/// 1. Acid-Base Titration
/// 2. Element Mixer (reactions)
class ChemistrySimulationScreen extends StatefulWidget {
  const ChemistrySimulationScreen({super.key});

  @override
  State<ChemistrySimulationScreen> createState() =>
      _ChemistrySimulationScreenState();
}

class _ChemistrySimulationScreenState extends State<ChemistrySimulationScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isArabic = locale.isArabic;

    final tabs = [
      isArabic ? 'المعايرة' : 'Titration',
      isArabic ? 'خلط العناصر' : 'Element Mixer',
      isArabic ? 'قوانين الغازات' : 'Gas Laws',
    ];

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceCard,
          title: Text(
            isArabic ? 'محاكاة الكيمياء' : 'Chemistry Simulation',
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
              icon: const Icon(Icons.three_p_rounded, color: AppColors.chemistry),
              tooltip: isArabic ? 'عرض الأبعاد الثلاثية' : '3D View',
              onPressed: () => _show3DViewer(context, isArabic),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            Container(
              height: 50,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: List.generate(tabs.length, (i) {
                  final sel = i == _selectedTab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = i),
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.roadmapLab.withAlpha(25)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: sel
                                ? AppColors.roadmapLab.withAlpha(60)
                                : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            tabs[i],
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight:
                                  sel ? FontWeight.w700 : FontWeight.w500,
                              color: sel
                                  ? AppColors.roadmapLab
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
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: const [
                  _TitrationSim(),
                  _ElementMixerSim(),
                  _GasLawsSim(),
                ],
              ),
            ),
          ],
        ),
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
                  modelUrl: ModelAssets.chemistryModel,
                  backgroundColor: AppColors.surfaceCard,
                  alt: isArabic ? 'نموذج كيمياء 3D' : '3D Chemistry Model',
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
// ═══  ACID-BASE TITRATION  ═══
// ════════════════════════════════════════════════════════

class _TitrationSim extends StatefulWidget {
  const _TitrationSim();

  @override
  State<_TitrationSim> createState() => _TitrationSimState();
}

class _TitrationSimState extends State<_TitrationSim>
    with SingleTickerProviderStateMixin {
  double _acidConc = 0.1;  // mol/L
  double _baseConc = 0.1;  // mol/L
  final double _acidVolume = 50;  // mL
  double _addedBaseVolume = 0; // mL
  late AnimationController _dropAnimController;

  // pH calculation (simplified HCl + NaOH)
  double get _pH {
    final molesAcid = _acidConc * _acidVolume / 1000;
    final molesBase = _baseConc * _addedBaseVolume / 1000;
    final totalVolume = (_acidVolume + _addedBaseVolume) / 1000;

    if (totalVolume <= 0) return 7;

    final excessAcid = molesAcid - molesBase;
    if (excessAcid > 0.0001) {
      final h = excessAcid / totalVolume;
      return (-_log10(h)).clamp(0.0, 14.0);
    } else if (excessAcid < -0.0001) {
      final oh = -excessAcid / totalVolume;
      final pOH = (-_log10(oh)).clamp(0.0, 14.0);
      return (14 - pOH).clamp(0.0, 14.0);
    }
    return 7.0;
  }

  double _log10(double x) {
    if (x <= 0) return 0;
    return log(x) / ln10;
  }

  Color get _solutionColor {
    if (_pH < 3) return const Color(0xFFEF4444);
    if (_pH < 5) return const Color(0xFFF97316);
    if (_pH < 6.5) return const Color(0xFFEAB308);
    if (_pH < 7.5) return const Color(0xFF22C55E);
    if (_pH < 9) return const Color(0xFF38BDF8);
    if (_pH < 11) return const Color(0xFF6366F1);
    return const Color(0xFF8B5CF6);
  }

  String get _indicatorStatus {
    if (_pH < 4.4) return '🔴';
    if (_pH < 8.2) return '🟡';
    return '🔵';
  }

  @override
  void initState() {
    super.initState();
    _dropAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _dropAnimController.dispose();
    super.dispose();
  }

  void _addDrop() {
    if (_addedBaseVolume >= 100) return;
    setState(() {
      _addedBaseVolume = (_addedBaseVolume + 0.5).clamp(0, 100);
    });
    _dropAnimController.forward(from: 0);
  }

  void _reset() {
    setState(() => _addedBaseVolume = 0);
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
            height: 300,
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
                animation: _dropAnimController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _TitrationPainter(
                      pH: _pH,
                      solutionColor: _solutionColor,
                      fillLevel: (_addedBaseVolume / 100).clamp(0, 1),
                      dropProgress: _dropAnimController.value,
                      baseLevelInBurette: 1 - (_addedBaseVolume / 100),
                    ),
                  );
                },
              ),
            ),
          ),

          // ADD DROP button
          GestureDetector(
            onTap: _addDrop,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: AppGradients.roadmapLab,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.roadmapLab.withAlpha(50),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  isArabic ? '💧 أضف قطرة قاعدية' : '💧 Add Base Drop',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Readouts
          Row(
            children: [
              Expanded(
                child: SimulationReadout(
                  label: 'pH',
                  value: _pH.toStringAsFixed(1),
                  unit: '',
                  color: _solutionColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'القاعدة المضافة' : 'Base Added',
                  value: _addedBaseVolume.toStringAsFixed(1),
                  unit: 'mL',
                  color: AppColors.roadmapAi,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'المؤشر' : 'Indicator',
                  value: _indicatorStatus,
                  unit: '',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Reset
          GestureDetector(
            onTap: _reset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isArabic ? '🔄 إعادة' : '🔄 Reset',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SimulationSlider(
            label: isArabic ? 'تركيز الحمض' : 'Acid Conc.',
            unit: 'mol/L',
            value: _acidConc,
            min: 0.01,
            max: 1.0,
            activeColor: AppColors.danger,
            onChanged: (v) => setState(() {
              _acidConc = v;
              _addedBaseVolume = 0;
            }),
          ),
          SimulationSlider(
            label: isArabic ? 'تركيز القاعدة' : 'Base Conc.',
            unit: 'mol/L',
            value: _baseConc,
            min: 0.01,
            max: 1.0,
            activeColor: AppColors.roadmapAi,
            onChanged: (v) => setState(() {
              _baseConc = v;
              _addedBaseVolume = 0;
            }),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TitrationPainter extends CustomPainter {
  final double pH;
  final Color solutionColor;
  final double fillLevel;
  final double dropProgress;
  final double baseLevelInBurette;

  _TitrationPainter({
    required this.pH,
    required this.solutionColor,
    required this.fillLevel,
    required this.dropProgress,
    required this.baseLevelInBurette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ─── Flask (Erlenmeyer shape) ───
    final flaskCenterX = w * 0.4;
    final flaskBottom = h * 0.85;
    final flaskWidth = 100.0;
    final flaskTop = h * 0.55;
    final neckWidth = 24.0;

    final flaskPath = Path()
      ..moveTo(flaskCenterX - neckWidth / 2, flaskTop)
      ..lineTo(flaskCenterX - flaskWidth / 2, flaskBottom)
      ..lineTo(flaskCenterX + flaskWidth / 2, flaskBottom)
      ..lineTo(flaskCenterX + neckWidth / 2, flaskTop)
      ..close();

    // Flask glass
    canvas.drawPath(
      flaskPath,
      Paint()
        ..color = Colors.white.withAlpha(15)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      flaskPath,
      Paint()
        ..color = Colors.white.withAlpha(50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Solution inside flask
    final solutionHeight = (flaskBottom - flaskTop) * 0.6;
    final solTop = flaskBottom - solutionHeight;
    final solWidthFactor = (flaskBottom - solTop) / (flaskBottom - flaskTop);
    final solHalfW = flaskWidth / 2 * solWidthFactor;

    final solPath = Path()
      ..moveTo(flaskCenterX - solHalfW, solTop)
      ..lineTo(flaskCenterX - flaskWidth / 2, flaskBottom)
      ..lineTo(flaskCenterX + flaskWidth / 2, flaskBottom)
      ..lineTo(flaskCenterX + solHalfW, solTop)
      ..close();

    canvas.drawPath(solPath, Paint()..color = solutionColor.withAlpha(150));

    // pH meter display
    final meterX = w * 0.75;
    final meterY = h * 0.4;
    // Screen
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(meterX, meterY), width: 80, height: 50),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(meterX, meterY), width: 80, height: 50),
        const Radius.circular(8),
      ),
      Paint()
        ..color = solutionColor.withAlpha(100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // pH text
    final tp = TextPainter(
      text: TextSpan(
        text: 'pH ${pH.toStringAsFixed(1)}',
        style: TextStyle(
          color: solutionColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(meterX - tp.width / 2, meterY - tp.height / 2));

    // ─── Burette ───
    final buretteX = flaskCenterX;
    final buretteTip = flaskTop - 10;
    final buretteTop = 20.0;
    final buretteW = 16.0;

    // Burette body
    canvas.drawRect(
      Rect.fromLTWH(buretteX - buretteW / 2, buretteTop, buretteW, buretteTip - buretteTop),
      Paint()..color = Colors.white.withAlpha(20),
    );
    canvas.drawRect(
      Rect.fromLTWH(buretteX - buretteW / 2, buretteTop, buretteW, buretteTip - buretteTop),
      Paint()
        ..color = Colors.white.withAlpha(50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Base liquid in burette
    final baseLiquidTop = buretteTop + (buretteTip - buretteTop) * (1 - baseLevelInBurette);
    canvas.drawRect(
      Rect.fromLTWH(buretteX - buretteW / 2 + 2, baseLiquidTop, buretteW - 4, buretteTip - baseLiquidTop),
      Paint()..color = const Color(0xFF38BDF8).withAlpha(100),
    );

    // Dropping drop
    if (dropProgress > 0 && dropProgress < 1) {
      final dropY = buretteTip + dropProgress * (solTop - buretteTip);
      canvas.drawCircle(
        Offset(buretteX, dropY),
        4,
        Paint()..color = const Color(0xFF38BDF8),
      );
    }

    // pH color scale on right
    final scaleX = w * 0.92;
    final scaleTop = h * 0.15;
    final scaleHeight = h * 0.6;
    final phColors = [
      const Color(0xFFEF4444), // pH 0
      const Color(0xFFF97316), // pH 3
      const Color(0xFFEAB308), // pH 5
      const Color(0xFF22C55E), // pH 7
      const Color(0xFF38BDF8), // pH 9
      const Color(0xFF6366F1), // pH 11
      const Color(0xFF8B5CF6), // pH 14
    ];

    for (int i = 0; i < 14; i++) {
      final y = scaleTop + scaleHeight * i / 14;
      final colorIdx = (i / 14 * (phColors.length - 1)).floor().clamp(0, phColors.length - 2);
      final t = (i / 14 * (phColors.length - 1)) - colorIdx;
      final color = Color.lerp(phColors[colorIdx], phColors[colorIdx + 1], t)!;
      canvas.drawRect(
        Rect.fromLTWH(scaleX - 8, y, 16, scaleHeight / 14),
        Paint()..color = color,
      );
    }

    // Current pH indicator on scale
    final indY = scaleTop + scaleHeight * (pH / 14).clamp(0, 1);
    canvas.drawCircle(
      Offset(scaleX - 14, indY),
      5,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _TitrationPainter old) =>
      old.pH != pH || old.fillLevel != fillLevel || old.dropProgress != dropProgress;
}

// ════════════════════════════════════════════════════════
// ═══  ELEMENT MIXER  ═══
// ════════════════════════════════════════════════════════

class _ElementMixerSim extends StatefulWidget {
  const _ElementMixerSim();

  @override
  State<_ElementMixerSim> createState() => _ElementMixerSimState();
}

class _Reaction {
  final String nameAr;
  final String nameEn;
  final String equation;
  final String descAr;
  final String descEn;
  final Color color;
  final String emoji;
  final String type; // 'fizz', 'explosion', 'precipitate', 'color_change'

  const _Reaction({
    required this.nameAr,
    required this.nameEn,
    required this.equation,
    required this.descAr,
    required this.descEn,
    required this.color,
    required this.emoji,
    required this.type,
  });
}

class _ElementMixerSimState extends State<_ElementMixerSim>
    with SingleTickerProviderStateMixin {
  int _element1 = 0;
  int _element2 = 1;
  bool _reacted = false;
  late AnimationController _reactAnimController;

  static const _elements = [
    'Na', 'Cl₂', 'H₂', 'O₂', 'H₂O', 'HCl', 'NaOH', 'Fe', 'CuSO₄',
    'Ca', 'Mg', 'Zn', 'AgNO₃', 'CO₂', 'Ca(OH)₂',
  ];
  static const _elementEmojis = [
    '🧂', '🟢', '💨', '🔵', '💧', '🟡', '⚪', '🔩', '🔷',
    '🪨', '✨', '🔧', '💎', '🫧', '🥛',
  ];
  static const _elementNamesAr = [
    'صوديوم', 'كلور', 'هيدروجين', 'أكسجين', 'ماء',
    'حمض الهيدروكلوريك', 'هيدروكسيد صوديوم', 'حديد', 'كبريتات نحاس',
    'كالسيوم', 'ماغنسيوم', 'زنك', 'نترات فضة', 'ثاني أكسيد كربون', 'ماء الجير',
  ];

  static const Map<String, _Reaction> _reactions = {
    // ── Original reactions ──
    '0-1': _Reaction(
      nameAr: 'تفاعل الصوديوم مع الكلور',
      nameEn: 'Sodium + Chlorine',
      equation: '2Na + Cl₂ → 2NaCl',
      descAr: 'يتكون ملح الطعام (كلوريد الصوديوم) مع انبعاث ضوء وحرارة شديدة',
      descEn: 'Table salt (sodium chloride) forms with intense light and heat',
      color: Color(0xFFEAB308),
      emoji: '💥',
      type: 'explosion',
    ),
    '2-3': _Reaction(
      nameAr: 'تفاعل الهيدروجين مع الأكسجين',
      nameEn: 'Hydrogen + Oxygen',
      equation: '2H₂ + O₂ → 2H₂O',
      descAr: 'يتكون الماء مع انفجار (تفاعل احتراق)',
      descEn: 'Water forms with an explosion (combustion reaction)',
      color: Color(0xFF38BDF8),
      emoji: '💧',
      type: 'explosion',
    ),
    '5-6': _Reaction(
      nameAr: 'معادلة حمض وقاعدة',
      nameEn: 'Acid + Base Neutralization',
      equation: 'HCl + NaOH → NaCl + H₂O',
      descAr: 'تفاعل معادلة ينتج ملح وماء مع ارتفاع الحرارة',
      descEn: 'Neutralization produces salt and water with heat release',
      color: Color(0xFF22C55E),
      emoji: '⚗️',
      type: 'fizz',
    ),
    '7-8': _Reaction(
      nameAr: 'إحلال الحديد مع كبريتات النحاس',
      nameEn: 'Iron + Copper Sulfate',
      equation: 'Fe + CuSO₄ → FeSO₄ + Cu',
      descAr: 'يتكون النحاس على سطح الحديد ويتغير لون المحلول',
      descEn: 'Copper deposits on iron surface, solution color changes',
      color: Color(0xFFF97316),
      emoji: '🔶',
      type: 'color_change',
    ),

    // ── Sodium reactions ──
    '0-4': _Reaction(
      nameAr: 'تفاعل الصوديوم مع الماء',
      nameEn: 'Sodium + Water',
      equation: '2Na + 2H₂O → 2NaOH + H₂↑',
      descAr: 'تفاعل عنيف ينتج هيدروكسيد الصوديوم وغاز الهيدروجين مع لهب',
      descEn: 'Violent reaction producing sodium hydroxide and hydrogen gas with flames',
      color: Color(0xFFEF4444),
      emoji: '🔥',
      type: 'explosion',
    ),
    '0-3': _Reaction(
      nameAr: 'احتراق الصوديوم في الأكسجين',
      nameEn: 'Sodium + Oxygen',
      equation: '4Na + O₂ → 2Na₂O',
      descAr: 'يحترق الصوديوم بلهب أصفر ساطع مكوناً أكسيد الصوديوم',
      descEn: 'Sodium burns with bright yellow flame forming sodium oxide',
      color: Color(0xFFEAB308),
      emoji: '🌟',
      type: 'explosion',
    ),

    // ── Calcium reactions ──
    '9-4': _Reaction(
      nameAr: 'تفاعل الكالسيوم مع الماء',
      nameEn: 'Calcium + Water',
      equation: 'Ca + 2H₂O → Ca(OH)₂ + H₂↑',
      descAr: 'يتفاعل الكالسيوم مع الماء مكوناً ماء الجير وغاز الهيدروجين',
      descEn: 'Calcium reacts with water forming lime water and hydrogen gas',
      color: Color(0xFF94A3B8),
      emoji: '🫧',
      type: 'fizz',
    ),
    '9-1': _Reaction(
      nameAr: 'تفاعل الكالسيوم مع الكلور',
      nameEn: 'Calcium + Chlorine',
      equation: 'Ca + Cl₂ → CaCl₂',
      descAr: 'يتكون كلوريد الكالسيوم (ملح) مع انبعاث حرارة',
      descEn: 'Calcium chloride (salt) forms with heat release',
      color: Color(0xFF64748B),
      emoji: '🧂',
      type: 'explosion',
    ),
    '9-5': _Reaction(
      nameAr: 'تفاعل الكالسيوم مع حمض الهيدروكلوريك',
      nameEn: 'Calcium + Hydrochloric Acid',
      equation: 'Ca + 2HCl → CaCl₂ + H₂↑',
      descAr: 'يذوب الكالسيوم في الحمض مع فوران شديد',
      descEn: 'Calcium dissolves in acid with intense fizzing',
      color: Color(0xFF06B6D4),
      emoji: '💨',
      type: 'fizz',
    ),

    // ── Magnesium reactions ──
    '10-3': _Reaction(
      nameAr: 'احتراق الماغنسيوم في الأكسجين',
      nameEn: 'Magnesium + Oxygen',
      equation: '2Mg + O₂ → 2MgO',
      descAr: 'يحترق الماغنسيوم بضوء أبيض شديد السطوع مكوناً أكسيد الماغنسيوم',
      descEn: 'Magnesium burns with intense white light forming magnesium oxide',
      color: Color(0xFFFAFAFA),
      emoji: '⚡',
      type: 'explosion',
    ),
    '10-5': _Reaction(
      nameAr: 'تفاعل الماغنسيوم مع حمض الهيدروكلوريك',
      nameEn: 'Magnesium + Hydrochloric Acid',
      equation: 'Mg + 2HCl → MgCl₂ + H₂↑',
      descAr: 'يذوب الماغنسيوم في الحمض مع فوران وتصاعد غاز الهيدروجين',
      descEn: 'Magnesium dissolves in acid with fizzing and hydrogen gas release',
      color: Color(0xFF22C55E),
      emoji: '🫧',
      type: 'fizz',
    ),
    '10-4': _Reaction(
      nameAr: 'تفاعل الماغنسيوم مع الماء الساخن',
      nameEn: 'Magnesium + Hot Water',
      equation: 'Mg + 2H₂O → Mg(OH)₂ + H₂↑',
      descAr: 'تفاعل بطيء مع الماء الساخن ينتج هيدروكسيد الماغنسيوم',
      descEn: 'Slow reaction with hot water producing magnesium hydroxide',
      color: Color(0xFFA3E635),
      emoji: '💧',
      type: 'fizz',
    ),

    // ── Zinc reactions ──
    '11-5': _Reaction(
      nameAr: 'تفاعل الزنك مع حمض الهيدروكلوريك',
      nameEn: 'Zinc + Hydrochloric Acid',
      equation: 'Zn + 2HCl → ZnCl₂ + H₂↑',
      descAr: 'يذوب الزنك في الحمض مع فوران وتصاعد غاز الهيدروجين',
      descEn: 'Zinc dissolves in acid with fizzing and hydrogen gas bubbles',
      color: Color(0xFF60A5FA),
      emoji: '🫧',
      type: 'fizz',
    ),
    '11-8': _Reaction(
      nameAr: 'إحلال الزنك مع كبريتات النحاس',
      nameEn: 'Zinc + Copper Sulfate',
      equation: 'Zn + CuSO₄ → ZnSO₄ + Cu',
      descAr: 'يترسب النحاس الأحمر على الزنك ويتحول المحلول من أزرق لشفاف',
      descEn: 'Red copper deposits on zinc, solution turns from blue to colorless',
      color: Color(0xFFFB923C),
      emoji: '🔶',
      type: 'color_change',
    ),

    // ── Silver Nitrate reactions ──
    '12-5': _Reaction(
      nameAr: 'تفاعل نترات الفضة مع حمض الهيدروكلوريك',
      nameEn: 'Silver Nitrate + HCl',
      equation: 'AgNO₃ + HCl → AgCl↓ + HNO₃',
      descAr: 'يتكون راسب أبيض من كلوريد الفضة (كشف عن أيون الكلوريد)',
      descEn: 'White precipitate of silver chloride forms (chloride ion test)',
      color: Color(0xFFE2E8F0),
      emoji: '🤍',
      type: 'precipitate',
    ),
    '12-6': _Reaction(
      nameAr: 'تفاعل نترات الفضة مع هيدروكسيد الصوديوم',
      nameEn: 'Silver Nitrate + NaOH',
      equation: 'AgNO₃ + NaOH → AgOH↓ + NaNO₃',
      descAr: 'يتكون راسب بني من هيدروكسيد الفضة',
      descEn: 'Brown precipitate of silver hydroxide forms',
      color: Color(0xFF78350F),
      emoji: '🟤',
      type: 'precipitate',
    ),

    // ── CO₂ + Lime Water ──
    '13-14': _Reaction(
      nameAr: 'تفاعل ثاني أكسيد الكربون مع ماء الجير',
      nameEn: 'CO₂ + Lime Water',
      equation: 'CO₂ + Ca(OH)₂ → CaCO₃↓ + H₂O',
      descAr: 'يتعكر ماء الجير بسبب تكوّن كربونات الكالسيوم (كشف عن CO₂)',
      descEn: 'Lime water turns milky due to calcium carbonate formation (CO₂ test)',
      color: Color(0xFFF1F5F9),
      emoji: '🥛',
      type: 'precipitate',
    ),

    // ── Iron + Oxygen (Rust) ──
    '7-3': _Reaction(
      nameAr: 'صدأ الحديد (أكسدة)',
      nameEn: 'Iron + Oxygen (Rusting)',
      equation: '4Fe + 3O₂ → 2Fe₂O₃',
      descAr: 'يتأكسد الحديد ببطء مكوناً أكسيد الحديد (الصدأ) بلون بني محمر',
      descEn: 'Iron slowly oxidizes forming iron oxide (rust) with reddish-brown color',
      color: Color(0xFFB45309),
      emoji: '🟫',
      type: 'color_change',
    ),

    // ── Iron + HCl ──
    '7-5': _Reaction(
      nameAr: 'تفاعل الحديد مع حمض الهيدروكلوريك',
      nameEn: 'Iron + Hydrochloric Acid',
      equation: 'Fe + 2HCl → FeCl₂ + H₂↑',
      descAr: 'يذوب الحديد ببطء في الحمض مع فقاعات غاز الهيدروجين',
      descEn: 'Iron slowly dissolves in acid with hydrogen gas bubbles',
      color: Color(0xFF84CC16),
      emoji: '🫧',
      type: 'fizz',
    ),
  };

  _Reaction? get _currentReaction {
    final key1 = '$_element1-$_element2';
    final key2 = '$_element2-$_element1';
    return _reactions[key1] ?? _reactions[key2];
  }

  @override
  void initState() {
    super.initState();
    _reactAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _reactAnimController.dispose();
    super.dispose();
  }

  void _mix() {
    if (_currentReaction == null) return;
    setState(() => _reacted = true);
    _reactAnimController.forward(from: 0);
  }

  void _reset() {
    _reactAnimController.reset();
    setState(() => _reacted = false);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isArabic = locale.isArabic;
    final reaction = _currentReaction;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Reaction canvas
          Container(
            height: 240,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(8)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AnimatedBuilder(
                animation: _reactAnimController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ElementMixerPainter(
                      element1: _elements[_element1],
                      element2: _elements[_element2],
                      emoji1: _elementEmojis[_element1],
                      emoji2: _elementEmojis[_element2],
                      reacted: _reacted,
                      progress: _reactAnimController.value,
                      reactionColor: reaction?.color ?? Colors.grey,
                      reactionType: reaction?.type ?? '',
                    ),
                  );
                },
              ),
            ),
          ),

          // Element selectors
          Row(
            children: [
              Expanded(
                child: _ElementPicker(
                  label: isArabic ? 'العنصر ١' : 'Element 1',
                  elements: _elements,
                  emojis: _elementEmojis,
                  namesAr: _elementNamesAr,
                  selected: _element1,
                  isArabic: isArabic,
                  color: AppColors.roadmapAi,
                  onChanged: (v) => setState(() {
                    _element1 = v;
                    _reacted = false;
                    _reactAnimController.reset();
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('+', style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                )),
              ),
              Expanded(
                child: _ElementPicker(
                  label: isArabic ? 'العنصر ٢' : 'Element 2',
                  elements: _elements,
                  emojis: _elementEmojis,
                  namesAr: _elementNamesAr,
                  selected: _element2,
                  isArabic: isArabic,
                  color: AppColors.roadmapQuiz,
                  onChanged: (v) => setState(() {
                    _element2 = v;
                    _reacted = false;
                    _reactAnimController.reset();
                  }),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Mix button
          GestureDetector(
            onTap: reaction != null && !_reacted ? _mix : _reset,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: reaction != null
                    ? (_reacted ? null : AppGradients.roadmapLab)
                    : null,
                color: reaction == null
                    ? AppColors.surfaceLight
                    : (_reacted ? AppColors.surfaceLight : null),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  _reacted
                      ? (isArabic ? '🔄 إعادة' : '🔄 Reset')
                      : reaction != null
                          ? (isArabic ? '⚗️ أخلط!' : '⚗️ Mix!')
                          : (isArabic ? 'لا يوجد تفاعل معروف' : 'No known reaction'),
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: reaction != null ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Reaction result
          if (_reacted && reaction != null)
            AnimatedContainer(
              duration: AppDurations.normal,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: reaction.color.withAlpha(15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: reaction.color.withAlpha(30)),
              ),
              child: Column(
                children: [
                  Text(
                    reaction.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic ? reaction.nameAr : reaction.nameEn,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      reaction.equation,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: reaction.color,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isArabic ? reaction.descAr : reaction.descEn,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ElementPicker extends StatelessWidget {
  final String label;
  final List<String> elements;
  final List<String> emojis;
  final List<String> namesAr;
  final int selected;
  final bool isArabic;
  final Color color;
  final ValueChanged<int> onChanged;

  const _ElementPicker({
    required this.label,
    required this.elements,
    required this.emojis,
    required this.namesAr,
    required this.selected,
    required this.isArabic,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(25)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(emojis[selected], style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 4),
          Text(
            elements[selected],
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: elements.length,
              itemBuilder: (context, i) {
                final sel = i == selected;
                return GestureDetector(
                  onTap: () => onChanged(i),
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: sel ? color.withAlpha(40) : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: sel ? color : Colors.transparent,
                        width: sel ? 2 : 0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        emojis[i],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ElementMixerPainter extends CustomPainter {
  final String element1, element2, emoji1, emoji2;
  final bool reacted;
  final double progress;
  final Color reactionColor;
  final String reactionType;

  _ElementMixerPainter({
    required this.element1,
    required this.element2,
    required this.emoji1,
    required this.emoji2,
    required this.reacted,
    required this.progress,
    required this.reactionColor,
    required this.reactionType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Test tubes
    final tube1X = w * 0.3;
    final tube2X = w * 0.7;
    final tubeY = h * 0.3;
    final tubeH = h * 0.45;
    final tubeW = 30.0;

    // Draw tubes
    _drawTube(canvas, tube1X, tubeY, tubeW, tubeH, const Color(0xFF38BDF8));
    _drawTube(canvas, tube2X, tubeY, tubeW, tubeH, const Color(0xFFEF4444));

    if (reacted && progress > 0) {
      // Merging animation — tubes tilt toward center
      final centerX = w / 2;
      final centerY = h * 0.6;

      // Beaker in center
      final beakerW = 80.0;
      final beakerH = 60.0;
      final beakerPath = Path()
        ..moveTo(centerX - beakerW / 2, centerY - beakerH / 2)
        ..lineTo(centerX - beakerW / 2 + 10, centerY + beakerH / 2)
        ..lineTo(centerX + beakerW / 2 - 10, centerY + beakerH / 2)
        ..lineTo(centerX + beakerW / 2, centerY - beakerH / 2)
        ..close();

      canvas.drawPath(
        beakerPath,
        Paint()..color = Colors.white.withAlpha(20),
      );
      canvas.drawPath(
        beakerPath,
        Paint()
          ..color = Colors.white.withAlpha(50)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Reaction glow
      if (progress > 0.3) {
        final glowProg = ((progress - 0.3) / 0.7).clamp(0.0, 1.0);
        canvas.drawCircle(
          Offset(centerX, centerY),
          40 * glowProg,
          Paint()..color = reactionColor.withAlpha((100 * glowProg).toInt()),
        );

        // Bubbles / particles
        if (reactionType == 'fizz' || reactionType == 'explosion') {
          final rng = Random(42);
          for (int i = 0; i < 12; i++) {
            final bx = centerX + rng.nextDouble() * 60 - 30;
            final by = centerY - rng.nextDouble() * 80 * glowProg;
            canvas.drawCircle(
              Offset(bx, by),
              3 + rng.nextDouble() * 3,
              Paint()..color = reactionColor.withAlpha((80 * glowProg).toInt()),
            );
          }
        }
      }
    }

    // Element labels
    _drawLabel(canvas, Offset(tube1X, tubeY - 16), element1, Colors.white);
    _drawLabel(canvas, Offset(tube2X, tubeY - 16), element2, Colors.white);
  }

  void _drawTube(Canvas canvas, double x, double y, double w, double h, Color liquidColor) {
    // Glass outline
    final tubePath = Path()
      ..addRRect(RRect.fromRectAndCorners(
        Rect.fromLTWH(x - w / 2, y, w, h),
        bottomLeft: Radius.circular(w / 2),
        bottomRight: Radius.circular(w / 2),
      ));

    canvas.drawPath(tubePath, Paint()..color = Colors.white.withAlpha(15));
    canvas.drawPath(
      tubePath,
      Paint()
        ..color = Colors.white.withAlpha(50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Liquid
    final liquidH = h * 0.6;
    final liquidPath = Path()
      ..addRRect(RRect.fromRectAndCorners(
        Rect.fromLTWH(x - w / 2 + 3, y + h - liquidH, w - 6, liquidH - 3),
        bottomLeft: Radius.circular(w / 2 - 3),
        bottomRight: Radius.circular(w / 2 - 3),
      ));
    canvas.drawPath(liquidPath, Paint()..color = liquidColor.withAlpha(100));
  }

  void _drawLabel(Canvas canvas, Offset pos, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy));
  }

  @override
  bool shouldRepaint(covariant _ElementMixerPainter old) =>
      old.progress != progress || old.reacted != reacted ||
      old.element1 != element1 || old.element2 != element2;
}

// ════════════════════════════════════════════════════════
// ═══  GAS LAWS SIMULATION  ═══
// ════════════════════════════════════════════════════════

class _GasLawsSim extends StatefulWidget {
  const _GasLawsSim();

  @override
  State<_GasLawsSim> createState() => _GasLawsSimState();
}

class _GasLawsSimState extends State<_GasLawsSim>
    with SingleTickerProviderStateMixin {
  double _pressure = 1.0; // atm
  double _temperature = 300; // Kelvin
  int _selectedLaw = 0; // 0=Boyle, 1=Charles

  // Boyle's Law: P1*V1 = P2*V2 → V2 = (P1*V1)/P2
  // At P=1 atm, V=1 L (reference)
  double get _volumeBoyle => (1.0 * 1.0) / _pressure;

  // Charles's Law: V1/T1 = V2/T2 → V2 = V1 * T2/T1
  // At T=300K, V=1 L (reference)
  double get _volumeCharles => 1.0 * _temperature / 300;

  double get _currentVolume => _selectedLaw == 0 ? _volumeBoyle : _volumeCharles;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isArabic = locale.isArabic;

    final lawNames = [
      isArabic ? 'قانون بويل' : "Boyle's Law",
      isArabic ? 'قانون شارل' : "Charles's Law",
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Law selector
          Container(
            height: 44,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: List.generate(2, (i) {
                final sel = i == _selectedLaw;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedLaw = i;
                      _pressure = 1.0;
                      _temperature = 300;
                    }),
                    child: AnimatedContainer(
                      duration: AppDurations.fast,
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.chemistry.withAlpha(25)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel
                              ? AppColors.chemistry.withAlpha(60)
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          lawNames[i],
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                            color: sel
                                ? AppColors.chemistry
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

          // Balloon canvas
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
                animation: _pulseController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _GasLawPainter(
                      volume: _currentVolume,
                      pulse: _pulseController.value,
                      isBoyle: _selectedLaw == 0,
                    ),
                  );
                },
              ),
            ),
          ),

          // Formula
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.chemistry.withAlpha(15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.chemistry.withAlpha(30)),
            ),
            child: Column(
              children: [
                Text(
                  _selectedLaw == 0
                      ? 'P₁V₁ = P₂V₂'
                      : 'V₁/T₁ = V₂/T₂',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.chemistry,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedLaw == 0
                      ? (isArabic
                          ? 'الضغط × الحجم = ثابت (عند درجة حرارة ثابتة)'
                          : 'Pressure × Volume = Constant (at constant T)')
                      : (isArabic
                          ? 'الحجم يتناسب طردياً مع درجة الحرارة (عند ضغط ثابت)'
                          : 'Volume is proportional to Temperature (at constant P)'),
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Slider
          if (_selectedLaw == 0)
            SimulationSlider(
              label: isArabic ? 'الضغط' : 'Pressure',
              value: _pressure,
              min: 0.2,
              max: 5.0,
              divisions: 48,
              unit: 'atm',
              activeColor: AppColors.chemistry,
              onChanged: (v) => setState(() => _pressure = v),
            )
          else
            SimulationSlider(
              label: isArabic ? 'الحرارة' : 'Temperature',
              value: _temperature,
              min: 100,
              max: 600,
              divisions: 50,
              unit: 'K',
              activeColor: AppColors.chemistry,
              onChanged: (v) => setState(() => _temperature = v),
            ),

          const SizedBox(height: 8),

          // Readouts
          Row(
            children: [
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'الحجم' : 'Volume',
                  value: _currentVolume.toStringAsFixed(2),
                  unit: 'L',
                  color: AppColors.chemistry,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'الضغط' : 'Pressure',
                  value: _pressure.toStringAsFixed(1),
                  unit: 'atm',
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SimulationReadout(
                  label: isArabic ? 'الحرارة' : 'Temp',
                  value: '${_temperature.round()}',
                  unit: 'K',
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

// ─── Gas Law Painter ───
class _GasLawPainter extends CustomPainter {
  final double volume;
  final double pulse;
  final bool isBoyle;

  _GasLawPainter({
    required this.volume,
    required this.pulse,
    required this.isBoyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 - 10;

    // Background gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0D1B2A), Color(0xFF1A2980)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Balloon size based on volume (clamped)
    final radius = (40.0 + volume.clamp(0.1, 5.0) * 25).clamp(20.0, 120.0);
    final pr = pulse * 3; // breathing effect

    // Balloon glow
    final glowPaint = Paint()
      ..color = (isBoyle ? const Color(0xFF00B4D8) : const Color(0xFFEF4444))
          .withAlpha(30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(Offset(cx, cy), radius + 20 + pr, glowPaint);

    // Balloon body
    final balloonPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: isBoyle
            ? [const Color(0xFF00B4D8), const Color(0xFF0077B6)]
            : [const Color(0xFFEF4444), const Color(0xFFB91C1C)],
      ).createShader(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius + pr),
      );
    canvas.drawCircle(Offset(cx, cy), radius + pr, balloonPaint);

    // Shine
    final shinePaint = Paint()
      ..color = Colors.white.withAlpha(50);
    canvas.drawCircle(
      Offset(cx - radius * 0.3, cy - radius * 0.3),
      radius * 0.25,
      shinePaint,
    );

    // Balloon tie (triangle)
    final tiePath = Path()
      ..moveTo(cx - 6, cy + radius + pr)
      ..lineTo(cx + 6, cy + radius + pr)
      ..lineTo(cx, cy + radius + pr + 12)
      ..close();
    canvas.drawPath(
      tiePath,
      Paint()..color = isBoyle ? const Color(0xFF0077B6) : const Color(0xFFB91C1C),
    );

    // String
    final stringPaint = Paint()
      ..color = Colors.white.withAlpha(80)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final stringPath = Path()
      ..moveTo(cx, cy + radius + pr + 12)
      ..quadraticBezierTo(
        cx + 10, cy + radius + pr + 40,
        cx, cy + radius + pr + 60,
      );
    canvas.drawPath(stringPath, stringPaint);

    // Volume label
    final tp = TextPainter(
      text: TextSpan(
        text: 'V = ${volume.toStringAsFixed(2)} L',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, size.height - 30));
  }

  @override
  bool shouldRepaint(covariant _GasLawPainter old) =>
      old.volume != volume || old.pulse != pulse || old.isBoyle != isBoyle;
}
