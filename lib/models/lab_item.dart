import 'package:flutter/material.dart';
import '../data/chem_reactions_db.dart';

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

// ═════════════════════════════════════════════════════════════════
//  REACTION VISUAL EFFECTS SYSTEM
// ═════════════════════════════════════════════════════════════════

/// Visual effect types that can be combined to create unique reaction visuals.
/// Each reaction has 1-4 [EffectLayer]s that render simultaneously.
enum ReactionEffect {
  /// Solid particles falling from liquid surface to bottom (ترسيب)
  precipitate,

  /// Vapor/smoke clouds rising above vessel (دخان/بخار)
  smoke,

  /// Bright sparking particles exploding outward (شرر)
  sparks,

  /// Colored flame dancing above liquid surface (لهب)
  flame,

  /// Dense foam dome erupting above surface (رغوة)
  foam,

  /// Color wave spreading through liquid (موجة لون)
  colorWave,

  /// Large bubbles + gas clouds above surface (تصاعد غاز)
  gasRelease,

  /// Intense colored thermal glow (توهج حراري)
  glow,

  /// Geometric crystal shapes growing (تبلور)
  crystallize,

  /// Ice crystal patterns on vessel walls — endothermic (تجمد)
  frost,
}

/// A single visual effect layer with its own color, intensity, and size.
///
/// Reactions combine 1-4 [EffectLayer]s to achieve unique visuals.
/// Example: Na + H₂O = [sparks(yellow), flame(yellow), gasRelease(white)]
class EffectLayer {
  final ReactionEffect type;
  final Color color;
  final double intensity; // 0.0-1.0 — density & speed
  final double size;      // particle size multiplier (default 1.0)

  const EffectLayer(this.type, this.color, [this.intensity = 0.7, this.size = 1.0]);
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

  /// Visual effect layers — each reaction has 1-4 unique effects
  final List<EffectLayer> effects;

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
    this.effects = const [],
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

  /// All known items (original + ChemDB)
  static final List<LabItem> all = [
    water, sodium, hcl, naoh, vinegar, bakingSoda, copper, iron,
    phenolphthalein, litmus, beaker, flask, testTube,
    thermometer, stirrer, tongs, burner, scale, goggles,
    ...ChemDB.chemicals,
  ];

  /// Map for quick ID lookup (rebuilt lazily after merge)
  static final Map<String, LabItem> _byId = {
    for (final item in all) item.id: item,
  };

  /// Get an item by its ID
  static LabItem? getById(String id) => _byId[id];

  // ─────────────────────────────────────────────────────────────
  //  FUZZY MATCHING — Resolve AI tool names to LabItems
  // ─────────────────────────────────────────────────────────────

  /// Keyword map for fuzzy matching tool names from AI responses
  /// Merges original keywords with the ChemDB extended keywords.
  static final Map<String, String> _keywords = {
    // ── Original keywords ──
    'water': 'water', 'h2o': 'water', 'مياه': 'water', 'ماء': 'water',
    'sodium': 'sodium', 'na': 'sodium', 'صوديوم': 'sodium',
    'hydrochloric': 'hcl', 'hcl': 'hcl', 'هيدروكلوريك': 'hcl', 'حمض': 'hcl',
    'hydroxide': 'naoh', 'naoh': 'naoh', 'هيدروكسيد': 'naoh', 'قاعدة': 'naoh',
    'vinegar': 'vinegar', 'acetic': 'vinegar', 'خل': 'vinegar',
    'baking': 'baking_soda', 'bicarbonate': 'baking_soda', 'بيكربونات': 'baking_soda',
    'copper sulfate': 'copper', 'cuso4': 'copper', 'كبريتات النحاس': 'copper',
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
    // ── Extended keywords from ChemDB ──
    ...ChemDB.keywords,
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

  /// All 100 chemical reactions from the ChemDB.
  static final List<ChemReaction> reactions = ChemDB.reactions;

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
