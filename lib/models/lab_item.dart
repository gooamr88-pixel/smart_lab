import 'package:flutter/material.dart';

/// Type classification for lab items
enum LabItemType {
  chemical,   // Reagents and chemicals (HCl, NaOH, etc.)
  container,  // Beakers, flasks, test tubes
  tool,       // Tongs, thermometer, stirrer
  indicator,  // Litmus paper, pH indicator
}

/// Represents a single item in the virtual chemistry lab.
///
/// Contains visual metadata (color, emoji) and reaction properties
/// used by the simulation engine.
class LabItem {
  final String id;
  final String name;
  final String nameAr;
  final Color color;
  final LabItemType type;
  final String emoji;
  final bool isLiquid;

  const LabItem({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.color,
    required this.type,
    required this.emoji,
    this.isLiquid = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LabItem && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Defines a chemical reaction that occurs when specific reagents are combined.
class ChemReaction {
  /// Set of [LabItem.id] values that must be present to trigger this reaction
  final Set<String> reagentIds;

  /// The resulting liquid color after the reaction
  final Color resultColor;

  /// Display name for the reaction
  final String name;
  final String nameAr;

  /// Chemical equation (e.g., "2Na + 2H₂O → 2NaOH + H₂↑")
  final String equation;

  /// Bubble intensity: 0.0 = no bubbles, 1.0 = violent fizzing
  final double bubbleIntensity;

  /// Heat glow intensity: 0.0 = no heat, 1.0 = intense exothermic
  final double heatIntensity;

  /// Short description of what happens
  final String description;
  final String descriptionAr;

  const ChemReaction({
    required this.reagentIds,
    required this.resultColor,
    required this.name,
    required this.nameAr,
    required this.equation,
    this.bubbleIntensity = 0.5,
    this.heatIntensity = 0.0,
    this.description = '',
    this.descriptionAr = '',
  });
}

// ═════════════════════════════════════════════════════════════════
//  KNOWN LAB ITEMS REGISTRY
// ═════════════════════════════════════════════════════════════════

/// Static registry of all known lab items and their chemical reactions.
class LabItemRegistry {
  LabItemRegistry._();

  // ─── Chemicals ───

  static const water = LabItem(
    id: 'water', name: 'Water', nameAr: 'ماء',
    color: Color(0x8800B4D8), type: LabItemType.chemical,
    emoji: '💧', isLiquid: true,
  );

  static const sodium = LabItem(
    id: 'sodium', name: 'Sodium', nameAr: 'صوديوم',
    color: Color(0xFFBDBDBD), type: LabItemType.chemical,
    emoji: '🪨',
  );

  static const hcl = LabItem(
    id: 'hcl', name: 'Hydrochloric Acid', nameAr: 'حمض الهيدروكلوريك',
    color: Color(0xBBFFEB3B), type: LabItemType.chemical,
    emoji: '⚗️', isLiquid: true,
  );

  static const naoh = LabItem(
    id: 'naoh', name: 'Sodium Hydroxide', nameAr: 'هيدروكسيد الصوديوم',
    color: Color(0x88FFFFFF), type: LabItemType.chemical,
    emoji: '🧴', isLiquid: true,
  );

  static const vinegar = LabItem(
    id: 'vinegar', name: 'Vinegar', nameAr: 'خل',
    color: Color(0xAAFFF9C4), type: LabItemType.chemical,
    emoji: '🫗', isLiquid: true,
  );

  static const bakingSoda = LabItem(
    id: 'baking_soda', name: 'Baking Soda', nameAr: 'بيكربونات الصوديوم',
    color: Color(0xFFF5F5F5), type: LabItemType.chemical,
    emoji: '🫧',
  );

  static const copper = LabItem(
    id: 'copper', name: 'Copper Sulfate', nameAr: 'كبريتات النحاس',
    color: Color(0xBB1E88E5), type: LabItemType.chemical,
    emoji: '💎', isLiquid: true,
  );

  static const iron = LabItem(
    id: 'iron', name: 'Iron Nail', nameAr: 'مسمار حديد',
    color: Color(0xFF757575), type: LabItemType.chemical,
    emoji: '🔩',
  );

  static const phenolphthalein = LabItem(
    id: 'phenolphthalein', name: 'Phenolphthalein', nameAr: 'فينولفثالين',
    color: Color(0x44E91E63), type: LabItemType.indicator,
    emoji: '🩷', isLiquid: true,
  );

  static const litmus = LabItem(
    id: 'litmus', name: 'Litmus Paper', nameAr: 'ورق عباد الشمس',
    color: Color(0xFF9C27B0), type: LabItemType.indicator,
    emoji: '📜',
  );

  // ─── Containers ───

  static const beaker = LabItem(
    id: 'beaker', name: 'Beaker', nameAr: 'دورق زجاجي',
    color: Color(0x33FFFFFF), type: LabItemType.container,
    emoji: '🧪',
  );

  static const flask = LabItem(
    id: 'flask', name: 'Erlenmeyer Flask', nameAr: 'دورق مخروطي',
    color: Color(0x33FFFFFF), type: LabItemType.container,
    emoji: '⚗️',
  );

  static const testTube = LabItem(
    id: 'test_tube', name: 'Test Tube', nameAr: 'أنبوب اختبار',
    color: Color(0x33FFFFFF), type: LabItemType.container,
    emoji: '🧫',
  );

  // ─── Tools ───

  static const thermometer = LabItem(
    id: 'thermometer', name: 'Thermometer', nameAr: 'ميزان حرارة',
    color: Color(0xFFE53935), type: LabItemType.tool,
    emoji: '🌡️',
  );

  static const stirrer = LabItem(
    id: 'stirrer', name: 'Glass Stirrer', nameAr: 'محرك زجاجي',
    color: Color(0xFFE0E0E0), type: LabItemType.tool,
    emoji: '🥄',
  );

  static const tongs = LabItem(
    id: 'tongs', name: 'Tongs', nameAr: 'ملقط',
    color: Color(0xFF9E9E9E), type: LabItemType.tool,
    emoji: '🔧',
  );

  static const burner = LabItem(
    id: 'burner', name: 'Bunsen Burner', nameAr: 'موقد بنزن',
    color: Color(0xFFFF6F00), type: LabItemType.tool,
    emoji: '🔥',
  );

  static const scale = LabItem(
    id: 'scale', name: 'Digital Scale', nameAr: 'ميزان حساس',
    color: Color(0xFF78909C), type: LabItemType.tool,
    emoji: '⚖️',
  );

  static const goggles = LabItem(
    id: 'goggles', name: 'Safety Goggles', nameAr: 'نظارات واقية',
    color: Color(0xFFFFCA28), type: LabItemType.tool,
    emoji: '🥽',
  );

  /// All known items
  static const List<LabItem> all = [
    water, sodium, hcl, naoh, vinegar, bakingSoda, copper, iron,
    phenolphthalein, litmus, beaker, flask, testTube,
    thermometer, stirrer, tongs, burner, scale, goggles,
  ];

  /// Map for quick ID lookup
  static final Map<String, LabItem> _byId = {
    for (final item in all) item.id: item,
  };

  /// Get an item by its ID
  static LabItem? getById(String id) => _byId[id];

  // ─────────────────────────────────────────────────────────────
  //  FUZZY MATCHING — Resolve AI tool names to LabItems
  // ─────────────────────────────────────────────────────────────

  /// Keyword map for fuzzy matching tool names from AI responses
  static final Map<String, String> _keywords = {
    // English keywords → item IDs
    'water': 'water', 'h2o': 'water', 'مياه': 'water', 'ماء': 'water',
    'sodium': 'sodium', 'na': 'sodium', 'صوديوم': 'sodium',
    'hydrochloric': 'hcl', 'hcl': 'hcl', 'هيدروكلوريك': 'hcl', 'حمض': 'hcl',
    'hydroxide': 'naoh', 'naoh': 'naoh', 'هيدروكسيد': 'naoh', 'قاعدة': 'naoh',
    'vinegar': 'vinegar', 'acetic': 'vinegar', 'خل': 'vinegar',
    'baking': 'baking_soda', 'bicarbonate': 'baking_soda', 'بيكربونات': 'baking_soda',
    'copper': 'copper', 'cuso4': 'copper', 'نحاس': 'copper', 'كبريتات': 'copper',
    'iron': 'iron', 'nail': 'iron', 'حديد': 'iron', 'مسمار': 'iron',
    'phenolphthalein': 'phenolphthalein', 'فينول': 'phenolphthalein',
    'litmus': 'litmus', 'عباد': 'litmus',
    'beaker': 'beaker', 'دورق': 'beaker', 'كأس': 'beaker',
    'flask': 'flask', 'erlenmeyer': 'flask', 'مخروطي': 'flask',
    'tube': 'test_tube', 'test': 'test_tube', 'أنبوب': 'test_tube',
    'thermometer': 'thermometer', 'حرارة': 'thermometer', 'ميزان حرارة': 'thermometer',
    'stirrer': 'stirrer', 'stir': 'stirrer', 'محرك': 'stirrer',
    'tongs': 'tongs', 'ملقط': 'tongs',
    'burner': 'burner', 'bunsen': 'burner', 'موقد': 'burner', 'بنزن': 'burner',
    'scale': 'scale', 'balance': 'scale', 'ميزان': 'scale',
    'goggles': 'goggles', 'safety': 'goggles', 'نظارات': 'goggles', 'واقية': 'goggles',
  };

  /// Resolves a tool name from the AI into a known [LabItem].
  ///
  /// Returns a fallback generic item if no match is found.
  static LabItem resolveToolName(String name) {
    final lower = name.toLowerCase().trim();

    // Exact ID match
    if (_byId.containsKey(lower)) return _byId[lower]!;

    // Keyword match — check if any keyword is contained in the name
    for (final entry in _keywords.entries) {
      if (lower.contains(entry.key)) {
        return _byId[entry.value]!;
      }
    }

    // Fallback: create a generic item from the name
    return LabItem(
      id: 'unknown_${lower.hashCode.abs()}',
      name: name,
      nameAr: name,
      color: const Color(0x88B0BEC5),
      type: LabItemType.chemical,
      emoji: '🧪',
    );
  }

  /// Resolves a list of tool name strings from the AI into LabItems
  static List<LabItem> resolveAll(List<String> toolNames) {
    return toolNames.map(resolveToolName).toList();
  }

  // ─────────────────────────────────────────────────────────────
  //  CHEMICAL REACTIONS REGISTRY
  // ─────────────────────────────────────────────────────────────

  static final List<ChemReaction> reactions = [
    // Sodium + Water → violent fizz
    ChemReaction(
      reagentIds: {'sodium', 'water'},
      resultColor: const Color(0xCCFFD54F),
      name: 'Sodium + Water',
      nameAr: 'صوديوم + ماء',
      equation: '2Na + 2H₂O → 2NaOH + H₂↑',
      bubbleIntensity: 0.9,
      heatIntensity: 0.8,
      description: 'Violent exothermic reaction! Hydrogen gas is released.',
      descriptionAr: 'تفاعل طارد للحرارة بشدة! يتصاعد غاز الهيدروجين.',
    ),

    // Acid + Base → neutralization
    ChemReaction(
      reagentIds: {'hcl', 'naoh'},
      resultColor: const Color(0x88B3E5FC),
      name: 'Acid-Base Neutralization',
      nameAr: 'تعادل حمض-قاعدة',
      equation: 'HCl + NaOH → NaCl + H₂O',
      bubbleIntensity: 0.3,
      heatIntensity: 0.4,
      description: 'Neutralization produces salt and water. Temperature rises slightly.',
      descriptionAr: 'التعادل ينتج ملح وماء. ترتفع الحرارة قليلاً.',
    ),

    // Vinegar + Baking Soda → fizz
    ChemReaction(
      reagentIds: {'vinegar', 'baking_soda'},
      resultColor: const Color(0xAAE0E0E0),
      name: 'Vinegar + Baking Soda',
      nameAr: 'خل + بيكربونات الصوديوم',
      equation: 'CH₃COOH + NaHCO₃ → CO₂↑ + H₂O + CH₃COONa',
      bubbleIntensity: 0.8,
      heatIntensity: 0.1,
      description: 'CO₂ gas bubbles vigorously! Classic volcano reaction.',
      descriptionAr: 'غاز ثاني أكسيد الكربون يتصاعد بقوة! تفاعل البركان.',
    ),

    // Copper Sulfate + Iron → displacement
    ChemReaction(
      reagentIds: {'copper', 'iron'},
      resultColor: const Color(0xBB4CAF50),
      name: 'Displacement Reaction',
      nameAr: 'تفاعل إحلال',
      equation: 'CuSO₄ + Fe → FeSO₄ + Cu↓',
      bubbleIntensity: 0.1,
      heatIntensity: 0.2,
      description: 'Iron displaces copper. Solution turns green, copper deposits on iron.',
      descriptionAr: 'الحديد يحل محل النحاس. المحلول يتحول للأخضر.',
    ),

    // HCl + Iron → fizz
    ChemReaction(
      reagentIds: {'hcl', 'iron'},
      resultColor: const Color(0xBBC8E6C9),
      name: 'Acid + Metal',
      nameAr: 'حمض + فلز',
      equation: 'Fe + 2HCl → FeCl₂ + H₂↑',
      bubbleIntensity: 0.6,
      heatIntensity: 0.3,
      description: 'Iron dissolves in acid. Hydrogen gas bubbles out.',
      descriptionAr: 'الحديد يذوب في الحمض. فقاعات غاز الهيدروجين.',
    ),
  ];

  /// Finds a reaction matching the given set of reagent IDs.
  /// Returns null if no known reaction matches.
  static ChemReaction? findReaction(Set<String> reagentIds) {
    for (final reaction in reactions) {
      if (reaction.reagentIds.difference(reagentIds).isEmpty &&
          reagentIds.difference(reaction.reagentIds).isEmpty) {
        return reaction;
      }
      // Also check subset — if reagentIds contains all reaction reagents
      if (reagentIds.containsAll(reaction.reagentIds)) {
        return reaction;
      }
    }
    return null;
  }
}
