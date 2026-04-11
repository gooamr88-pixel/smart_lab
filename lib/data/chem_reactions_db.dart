import 'package:flutter/material.dart';
import '../models/lab_item.dart';

// ═══════════════════════════════════════════════════════════════════
//  CHEMISTRY DATABASE — 100 Real Chemical Reactions
// ═══════════════════════════════════════════════════════════════════
//
// Every reaction is scientifically accurate with:
//   • Balanced chemical equation
//   • Unique result color, bubble intensity, heat intensity
//   • Bilingual names & descriptions (Arabic / English)
//
// Organized into 10 categories for educational progressive learning.
// ═══════════════════════════════════════════════════════════════════

class ChemDB {
  ChemDB._();

  // ─────────────────────────────────────────────────────────────────
  //  NEW CHEMICALS (~45 items)
  // ─────────────────────────────────────────────────────────────────

  static const List<LabItem> chemicals = [
    // ── Acids ──
    LabItem(id: 'h2so4', name: 'Sulfuric Acid', nameAr: 'حمض الكبريتيك',
      color: Color(0xAAFFCC80), type: LabItemType.chemical, emoji: '⚗️', isLiquid: true),
    LabItem(id: 'hno3', name: 'Nitric Acid', nameAr: 'حمض النيتريك',
      color: Color(0xAAFFE082), type: LabItemType.chemical, emoji: '⚗️', isLiquid: true),
    LabItem(id: 'h3po4', name: 'Phosphoric Acid', nameAr: 'حمض الفوسفوريك',
      color: Color(0x88C8E6C9), type: LabItemType.chemical, emoji: '⚗️', isLiquid: true),

    // ── Bases ──
    LabItem(id: 'koh', name: 'Potassium Hydroxide', nameAr: 'هيدروكسيد البوتاسيوم',
      color: Color(0x88E0E0E0), type: LabItemType.chemical, emoji: '🧴', isLiquid: true),
    LabItem(id: 'ca_oh_2', name: 'Calcium Hydroxide', nameAr: 'هيدروكسيد الكالسيوم',
      color: Color(0x88F5F5F5), type: LabItemType.chemical, emoji: '🥛', isLiquid: true),
    LabItem(id: 'nh4oh', name: 'Ammonia Solution', nameAr: 'محلول الأمونيا',
      color: Color(0x66B3E5FC), type: LabItemType.chemical, emoji: '💨', isLiquid: true),
    LabItem(id: 'ba_oh_2', name: 'Barium Hydroxide', nameAr: 'هيدروكسيد الباريوم',
      color: Color(0x88EEEEEE), type: LabItemType.chemical, emoji: '🧴', isLiquid: true),

    // ── Metals ──
    LabItem(id: 'potassium', name: 'Potassium', nameAr: 'بوتاسيوم',
      color: Color(0xFFCFD8DC), type: LabItemType.chemical, emoji: '🪨'),
    LabItem(id: 'lithium', name: 'Lithium', nameAr: 'ليثيوم',
      color: Color(0xFFE0E0E0), type: LabItemType.chemical, emoji: '🪨'),
    LabItem(id: 'calcium', name: 'Calcium', nameAr: 'كالسيوم',
      color: Color(0xFFF5F5F5), type: LabItemType.chemical, emoji: '🪨'),
    LabItem(id: 'magnesium', name: 'Magnesium Ribbon', nameAr: 'شريط مغنيسيوم',
      color: Color(0xFFE0E0E0), type: LabItemType.chemical, emoji: '🔗'),
    LabItem(id: 'zinc', name: 'Zinc', nameAr: 'خارصين',
      color: Color(0xFF90A4AE), type: LabItemType.chemical, emoji: '🔩'),
    LabItem(id: 'aluminum', name: 'Aluminum Foil', nameAr: 'رقائق ألومنيوم',
      color: Color(0xFFBDBDBD), type: LabItemType.chemical, emoji: '🪙'),
    LabItem(id: 'copper_metal', name: 'Copper Metal', nameAr: 'نحاس',
      color: Color(0xFFE57373), type: LabItemType.chemical, emoji: '🟤'),
    LabItem(id: 'tin', name: 'Tin', nameAr: 'قصدير',
      color: Color(0xFF9E9E9E), type: LabItemType.chemical, emoji: '🪙'),

    // ── Salts ──
    LabItem(id: 'silver_nitrate', name: 'Silver Nitrate', nameAr: 'نترات الفضة',
      color: Color(0x88E0E0E0), type: LabItemType.chemical, emoji: '💎', isLiquid: true),
    LabItem(id: 'barium_chloride', name: 'Barium Chloride', nameAr: 'كلوريد الباريوم',
      color: Color(0x88F5F5F5), type: LabItemType.chemical, emoji: '🧂', isLiquid: true),
    LabItem(id: 'sodium_carbonate', name: 'Sodium Carbonate', nameAr: 'كربونات الصوديوم',
      color: Color(0xFFF5F5F5), type: LabItemType.chemical, emoji: '🫧'),
    LabItem(id: 'calcium_carbonate', name: 'Calcium Carbonate', nameAr: 'كربونات الكالسيوم',
      color: Color(0xFFF5F5F5), type: LabItemType.chemical, emoji: '🪨'),
    LabItem(id: 'sodium_sulfate', name: 'Sodium Sulfate', nameAr: 'كبريتات الصوديوم',
      color: Color(0x88F5F5F5), type: LabItemType.chemical, emoji: '🧂', isLiquid: true),
    LabItem(id: 'potassium_iodide', name: 'Potassium Iodide', nameAr: 'يوديد البوتاسيوم',
      color: Color(0x88E0E0E0), type: LabItemType.chemical, emoji: '🧪', isLiquid: true),
    LabItem(id: 'lead_nitrate', name: 'Lead Nitrate', nameAr: 'نترات الرصاص',
      color: Color(0x88F5F5F5), type: LabItemType.chemical, emoji: '⚠️', isLiquid: true),
    LabItem(id: 'iron_iii_chloride', name: 'Iron(III) Chloride', nameAr: 'كلوريد الحديد III',
      color: Color(0xBBFF8F00), type: LabItemType.chemical, emoji: '🟠', isLiquid: true),
    LabItem(id: 'calcium_chloride', name: 'Calcium Chloride', nameAr: 'كلوريد الكالسيوم',
      color: Color(0x88F5F5F5), type: LabItemType.chemical, emoji: '🧂', isLiquid: true),
    LabItem(id: 'sodium_sulfide', name: 'Sodium Sulfide', nameAr: 'كبريتيد الصوديوم',
      color: Color(0x88FFECB3), type: LabItemType.chemical, emoji: '💛', isLiquid: true),
    LabItem(id: 'ammonium_chloride', name: 'Ammonium Chloride', nameAr: 'كلوريد الأمونيوم',
      color: Color(0xFFF5F5F5), type: LabItemType.chemical, emoji: '🫧'),
    LabItem(id: 'iron_ii_sulfate', name: 'Iron(II) Sulfate', nameAr: 'كبريتات الحديد II',
      color: Color(0xBBA5D6A7), type: LabItemType.chemical, emoji: '🟢', isLiquid: true),
    LabItem(id: 'sodium_chloride', name: 'Sodium Chloride', nameAr: 'كلوريد الصوديوم',
      color: Color(0xFFF5F5F5), type: LabItemType.chemical, emoji: '🧂', isLiquid: true),
    LabItem(id: 'sodium_bromide', name: 'Sodium Bromide', nameAr: 'بروميد الصوديوم',
      color: Color(0x88F5F5F5), type: LabItemType.chemical, emoji: '🧂', isLiquid: true),
    LabItem(id: 'sodium_sulfite', name: 'Sodium Sulfite', nameAr: 'كبريتيت الصوديوم',
      color: Color(0x88F5F5F5), type: LabItemType.chemical, emoji: '🧂', isLiquid: true),
    LabItem(id: 'potassium_thiocyanate', name: 'Potassium Thiocyanate', nameAr: 'ثيوسيانات البوتاسيوم',
      color: Color(0x88F5F5F5), type: LabItemType.chemical, emoji: '🧪', isLiquid: true),

    // ── Oxidizers & Special ──
    LabItem(id: 'manganese_dioxide', name: 'Manganese Dioxide', nameAr: 'ثاني أكسيد المنغنيز',
      color: Color(0xFF424242), type: LabItemType.chemical, emoji: '⚫'),
    LabItem(id: 'hydrogen_peroxide', name: 'Hydrogen Peroxide', nameAr: 'بيروكسيد الهيدروجين',
      color: Color(0x66B3E5FC), type: LabItemType.chemical, emoji: '🫧', isLiquid: true),
    LabItem(id: 'potassium_permanganate', name: 'Potassium Permanganate', nameAr: 'برمنغنات البوتاسيوم',
      color: Color(0xDD7B1FA2), type: LabItemType.chemical, emoji: '🟣', isLiquid: true),

    // ── Oxides ──
    LabItem(id: 'copper_oxide', name: 'Copper Oxide', nameAr: 'أكسيد النحاس',
      color: Color(0xFF212121), type: LabItemType.chemical, emoji: '⚫'),
    LabItem(id: 'magnesium_oxide', name: 'Magnesium Oxide', nameAr: 'أكسيد المغنيسيوم',
      color: Color(0xFFFAFAFA), type: LabItemType.chemical, emoji: '⬜'),
    LabItem(id: 'iron_oxide', name: 'Iron Oxide (Rust)', nameAr: 'أكسيد الحديد (صدأ)',
      color: Color(0xFFBF360C), type: LabItemType.chemical, emoji: '🟫'),
    LabItem(id: 'calcium_oxide', name: 'Calcium Oxide', nameAr: 'أكسيد الكالسيوم (جير حي)',
      color: Color(0xFFF5F5F5), type: LabItemType.chemical, emoji: '🔥'),
    LabItem(id: 'sodium_peroxide', name: 'Sodium Peroxide', nameAr: 'بيروكسيد الصوديوم',
      color: Color(0xFFFFECB3), type: LabItemType.chemical, emoji: '⚠️'),

    // ── Analytical / Indicators ──
    LabItem(id: 'starch_solution', name: 'Starch Solution', nameAr: 'محلول النشا',
      color: Color(0x44FFFFFF), type: LabItemType.indicator, emoji: '🥣', isLiquid: true),
    LabItem(id: 'iodine_solution', name: 'Iodine Solution', nameAr: 'محلول اليود',
      color: Color(0xBB8D6E63), type: LabItemType.indicator, emoji: '🟤', isLiquid: true),
    LabItem(id: 'sodium_thiosulfate', name: 'Sodium Thiosulfate', nameAr: 'ثيوكبريتات الصوديوم',
      color: Color(0x88F5F5F5), type: LabItemType.chemical, emoji: '🧪', isLiquid: true),
    LabItem(id: 'methyl_orange', name: 'Methyl Orange', nameAr: 'ميثيل البرتقال',
      color: Color(0xBBFF9800), type: LabItemType.indicator, emoji: '🟠', isLiquid: true),
    LabItem(id: 'universal_indicator', name: 'Universal Indicator', nameAr: 'كاشف عام',
      color: Color(0xBB4CAF50), type: LabItemType.indicator, emoji: '🌈', isLiquid: true),

    // ── Organic ──
    LabItem(id: 'ethanol', name: 'Ethanol', nameAr: 'إيثانول',
      color: Color(0x66FFFFFF), type: LabItemType.chemical, emoji: '🫗', isLiquid: true),
  ];

  // ─────────────────────────────────────────────────────────────────
  //  KEYWORD MAPPING for fuzzy matching AI tool names
  // ─────────────────────────────────────────────────────────────────

  static const Map<String, String> keywords = {
    // Acids
    'sulfuric': 'h2so4', 'h2so4': 'h2so4', 'كبريتيك': 'h2so4',
    'nitric': 'hno3', 'hno3': 'hno3', 'نيتريك': 'hno3',
    'phosphoric': 'h3po4', 'h3po4': 'h3po4', 'فوسفوريك': 'h3po4',
    // Bases
    'potassium hydroxide': 'koh', 'koh': 'koh', 'هيدروكسيد البوتاسيوم': 'koh',
    'calcium hydroxide': 'ca_oh_2', 'lime water': 'ca_oh_2', 'ca(oh)2': 'ca_oh_2',
    'ماء الجير': 'ca_oh_2', 'هيدروكسيد الكالسيوم': 'ca_oh_2',
    'ammonia': 'nh4oh', 'nh4oh': 'nh4oh', 'nh3': 'nh4oh', 'أمونيا': 'nh4oh',
    'barium hydroxide': 'ba_oh_2', 'ba(oh)2': 'ba_oh_2', 'هيدروكسيد الباريوم': 'ba_oh_2',
    // Metals
    'potassium': 'potassium', 'بوتاسيوم': 'potassium',
    'lithium': 'lithium', 'ليثيوم': 'lithium',
    'calcium': 'calcium', 'كالسيوم': 'calcium',
    'magnesium': 'magnesium', 'مغنيسيوم': 'magnesium', 'mg': 'magnesium',
    'zinc': 'zinc', 'خارصين': 'zinc', 'زنك': 'zinc', 'zn': 'zinc',
    'aluminum': 'aluminum', 'aluminium': 'aluminum', 'ألومنيوم': 'aluminum', 'al': 'aluminum',
    'copper metal': 'copper_metal', 'نحاس': 'copper_metal', 'cu': 'copper_metal',
    'tin': 'tin', 'قصدير': 'tin', 'sn': 'tin',
    // Salts
    'silver nitrate': 'silver_nitrate', 'agno3': 'silver_nitrate', 'نترات الفضة': 'silver_nitrate',
    'barium chloride': 'barium_chloride', 'bacl2': 'barium_chloride', 'كلوريد الباريوم': 'barium_chloride',
    'sodium carbonate': 'sodium_carbonate', 'na2co3': 'sodium_carbonate', 'كربونات الصوديوم': 'sodium_carbonate',
    'calcium carbonate': 'calcium_carbonate', 'caco3': 'calcium_carbonate', 'limestone': 'calcium_carbonate',
    'chalk': 'calcium_carbonate', 'حجر جيري': 'calcium_carbonate', 'كربونات الكالسيوم': 'calcium_carbonate', 'طباشير': 'calcium_carbonate',
    'sodium sulfate': 'sodium_sulfate', 'na2so4': 'sodium_sulfate', 'كبريتات الصوديوم': 'sodium_sulfate',
    'potassium iodide': 'potassium_iodide', 'ki': 'potassium_iodide', 'يوديد البوتاسيوم': 'potassium_iodide', 'يوديد': 'potassium_iodide',
    'lead nitrate': 'lead_nitrate', 'pb(no3)2': 'lead_nitrate', 'نترات الرصاص': 'lead_nitrate', 'رصاص': 'lead_nitrate',
    'iron iii chloride': 'iron_iii_chloride', 'fecl3': 'iron_iii_chloride', 'ferric chloride': 'iron_iii_chloride',
    'كلوريد الحديد': 'iron_iii_chloride',
    'calcium chloride': 'calcium_chloride', 'cacl2': 'calcium_chloride', 'كلوريد الكالسيوم': 'calcium_chloride',
    'sodium sulfide': 'sodium_sulfide', 'na2s': 'sodium_sulfide', 'كبريتيد الصوديوم': 'sodium_sulfide', 'كبريتيد': 'sodium_sulfide',
    'ammonium chloride': 'ammonium_chloride', 'nh4cl': 'ammonium_chloride', 'كلوريد الأمونيوم': 'ammonium_chloride', 'نشادر': 'ammonium_chloride',
    'iron ii sulfate': 'iron_ii_sulfate', 'feso4': 'iron_ii_sulfate', 'ferrous sulfate': 'iron_ii_sulfate',
    'كبريتات الحديد': 'iron_ii_sulfate',
    'sodium chloride': 'sodium_chloride', 'nacl': 'sodium_chloride', 'table salt': 'sodium_chloride',
    'ملح الطعام': 'sodium_chloride', 'ملح': 'sodium_chloride', 'كلوريد الصوديوم': 'sodium_chloride',
    'sodium bromide': 'sodium_bromide', 'nabr': 'sodium_bromide', 'بروميد': 'sodium_bromide',
    'sodium sulfite': 'sodium_sulfite', 'na2so3': 'sodium_sulfite', 'كبريتيت': 'sodium_sulfite',
    'thiocyanate': 'potassium_thiocyanate', 'kscn': 'potassium_thiocyanate', 'ثيوسيانات': 'potassium_thiocyanate',
    // Oxidizers & Special
    'manganese dioxide': 'manganese_dioxide', 'mno2': 'manganese_dioxide', 'ثاني أكسيد المنغنيز': 'manganese_dioxide', 'منغنيز': 'manganese_dioxide',
    'hydrogen peroxide': 'hydrogen_peroxide', 'h2o2': 'hydrogen_peroxide', 'بيروكسيد الهيدروجين': 'hydrogen_peroxide', 'ماء أكسجيني': 'hydrogen_peroxide',
    'potassium permanganate': 'potassium_permanganate', 'kmno4': 'potassium_permanganate', 'برمنغنات': 'potassium_permanganate',
    // Oxides
    'copper oxide': 'copper_oxide', 'cuo': 'copper_oxide', 'أكسيد النحاس': 'copper_oxide',
    'magnesium oxide': 'magnesium_oxide', 'mgo': 'magnesium_oxide', 'أكسيد المغنيسيوم': 'magnesium_oxide',
    'iron oxide': 'iron_oxide', 'fe2o3': 'iron_oxide', 'rust': 'iron_oxide', 'صدأ': 'iron_oxide', 'أكسيد الحديد': 'iron_oxide',
    'calcium oxide': 'calcium_oxide', 'cao': 'calcium_oxide', 'quicklime': 'calcium_oxide', 'جير حي': 'calcium_oxide', 'أكسيد الكالسيوم': 'calcium_oxide',
    'sodium peroxide': 'sodium_peroxide', 'na2o2': 'sodium_peroxide', 'بيروكسيد الصوديوم': 'sodium_peroxide',
    // Analytical
    'starch': 'starch_solution', 'نشا': 'starch_solution', 'محلول النشا': 'starch_solution',
    'iodine': 'iodine_solution', 'يود': 'iodine_solution', 'محلول اليود': 'iodine_solution',
    'sodium thiosulfate': 'sodium_thiosulfate', 'na2s2o3': 'sodium_thiosulfate', 'thio': 'sodium_thiosulfate', 'ثيوكبريتات': 'sodium_thiosulfate',
    'methyl orange': 'methyl_orange', 'ميثيل البرتقال': 'methyl_orange', 'ميثيل': 'methyl_orange',
    'universal indicator': 'universal_indicator', 'كاشف عام': 'universal_indicator',
    // Organic
    'ethanol': 'ethanol', 'alcohol': 'ethanol', 'إيثانول': 'ethanol', 'كحول': 'ethanol',
  };

  // ─────────────────────────────────────────────────────────────────
  //  100 CHEMICAL REACTIONS
  // ─────────────────────────────────────────────────────────────────

  static final List<ChemReaction> reactions = [

    // ═══════════════════════════════════════════════════════════════
    //  A · ALKALI / ALKALINE-EARTH METALS + WATER  (5 reactions)
    // ═══════════════════════════════════════════════════════════════

    // #1 — Sodium + Water (iconic explosion)
    ChemReaction(
      reagentIds: {'sodium', 'water'}, resultColor: const Color(0xCCFFD54F),
      name: 'Sodium + Water', nameAr: 'صوديوم + ماء',
      equation: '2Na + 2H₂O → 2NaOH + H₂↑',
      bubbleIntensity: 0.9, heatIntensity: 0.8,
      description: 'Violent exothermic reaction! Sodium darts on water surface with yellow flame. Hydrogen gas released.',
      descriptionAr: 'تفاعل عنيف! الصوديوم يتحرك على سطح الماء بلهب أصفر ويتصاعد غاز الهيدروجين.',
      effects: [EffectLayer(ReactionEffect.sparks, Color(0xFFFFD740), 0.9), EffectLayer(ReactionEffect.flame, Color(0xFFFFD740), 0.8, 1.2), EffectLayer(ReactionEffect.gasRelease, Color(0x88FFFFFF), 0.7)],
    ),

    // #2 — Potassium + Water (even more violent!)
    ChemReaction(
      reagentIds: {'potassium', 'water'}, resultColor: const Color(0xDDBA68C8),
      name: 'Potassium + Water', nameAr: 'بوتاسيوم + ماء',
      equation: '2K + 2H₂O → 2KOH + H₂↑',
      bubbleIntensity: 1.0, heatIntensity: 0.95,
      description: 'Extremely violent! Purple flame as potassium reacts with water. More reactive than sodium.',
      descriptionAr: 'شديد العنف! لهب بنفسجي عند تفاعل البوتاسيوم مع الماء. أنشط من الصوديوم.',
      effects: [EffectLayer(ReactionEffect.sparks, Color(0xFFCE93D8), 1.0, 1.3), EffectLayer(ReactionEffect.flame, Color(0xFFAB47BC), 0.95, 1.5), EffectLayer(ReactionEffect.gasRelease, Color(0x88FFFFFF), 0.8)],
    ),

    // #3 — Lithium + Water (gentle fizz)
    ChemReaction(
      reagentIds: {'lithium', 'water'}, resultColor: const Color(0x99E0E0E0),
      name: 'Lithium + Water', nameAr: 'ليثيوم + ماء',
      equation: '2Li + 2H₂O → 2LiOH + H₂↑',
      bubbleIntensity: 0.5, heatIntensity: 0.3,
      description: 'Gentle fizz with crimson-red flame. Lithium is the least reactive alkali metal.',
      descriptionAr: 'فوران خفيف مع لهب أحمر قرمزي. الليثيوم أقل الفلزات القلوية نشاطاً.',
      effects: [EffectLayer(ReactionEffect.flame, Color(0xFFE53935), 0.5, 0.8), EffectLayer(ReactionEffect.gasRelease, Color(0x66FFFFFF), 0.4)],
    ),

    // #4 — Calcium + Water (milky)
    ChemReaction(
      reagentIds: {'calcium', 'water'}, resultColor: const Color(0xBBF5F5F5),
      name: 'Calcium + Water', nameAr: 'كالسيوم + ماء',
      equation: 'Ca + 2H₂O → Ca(OH)₂ + H₂↑',
      bubbleIntensity: 0.4, heatIntensity: 0.35,
      description: 'Calcium sinks and reacts steadily. Solution turns milky white (lime water).',
      descriptionAr: 'الكالسيوم يغتس ويتفاعل بثبات. المحلول يصبح أبيض حليبي (ماء الجير).',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0xBBF5F5F5), 0.6), EffectLayer(ReactionEffect.gasRelease, Color(0x55FFFFFF), 0.35), EffectLayer(ReactionEffect.flame, Color(0xFFFF6D00), 0.3, 0.6)],
    ),

    // #5 — Sodium Peroxide + Water (O₂ release!)
    ChemReaction(
      reagentIds: {'sodium_peroxide', 'water'}, resultColor: const Color(0xBBFFF9C4),
      name: 'Sodium Peroxide + Water', nameAr: 'بيروكسيد الصوديوم + ماء',
      equation: '2Na₂O₂ + 2H₂O → 4NaOH + O₂↑',
      bubbleIntensity: 0.7, heatIntensity: 0.6,
      description: 'Releases oxygen gas with heat! Can ignite nearby combustibles.',
      descriptionAr: 'يطلق غاز الأكسجين مع حرارة! قد يشعل المواد القابلة للاشتعال القريبة.',
      effects: [EffectLayer(ReactionEffect.gasRelease, Color(0x88B3E5FC), 0.8, 1.2), EffectLayer(ReactionEffect.glow, Color(0xFFFFAB00), 0.6), EffectLayer(ReactionEffect.sparks, Color(0xFFFFD740), 0.5)],
    ),

    // ═══════════════════════════════════════════════════════════════
    //  B · METALS + HYDROCHLORIC ACID  (5 reactions)
    // ═══════════════════════════════════════════════════════════════

    // #6 — Iron + HCl
    ChemReaction(
      reagentIds: {'iron', 'hcl'}, resultColor: const Color(0xBBC8E6C9),
      name: 'Iron + Hydrochloric Acid', nameAr: 'حديد + حمض الهيدروكلوريك',
      equation: 'Fe + 2HCl → FeCl₂ + H₂↑',
      bubbleIntensity: 0.6, heatIntensity: 0.3,
      description: 'Iron dissolves slowly. Solution turns pale green (iron II chloride). Hydrogen bubbles.',
      descriptionAr: 'الحديد يذوب ببطء. المحلول يتحول للأخضر الفاتح. فقاعات هيدروجين.',
      effects: [EffectLayer(ReactionEffect.gasRelease, Color(0x88FFFFFF), 0.5), EffectLayer(ReactionEffect.colorWave, Color(0xBBC8E6C9), 0.5)],
    ),

    // #7 — Magnesium + HCl (fast!)
    ChemReaction(
      reagentIds: {'magnesium', 'hcl'}, resultColor: const Color(0x88E0E0E0),
      name: 'Magnesium + Hydrochloric Acid', nameAr: 'مغنيسيوم + حمض الهيدروكلوريك',
      equation: 'Mg + 2HCl → MgCl₂ + H₂↑',
      bubbleIntensity: 0.85, heatIntensity: 0.5,
      description: 'Very rapid reaction! Magnesium dissolves quickly with vigorous fizzing and heat.',
      descriptionAr: 'تفاعل سريع جداً! المغنيسيوم يذوب بسرعة مع فوران شديد وحرارة.',
      effects: [EffectLayer(ReactionEffect.gasRelease, Color(0x99FFFFFF), 0.85, 1.3), EffectLayer(ReactionEffect.sparks, Color(0xFFE0E0E0), 0.6), EffectLayer(ReactionEffect.glow, Color(0xFFFF8A65), 0.4)],
    ),

    // #8 — Zinc + HCl
    ChemReaction(
      reagentIds: {'zinc', 'hcl'}, resultColor: const Color(0x88F5F5F5),
      name: 'Zinc + Hydrochloric Acid', nameAr: 'خارصين + حمض الهيدروكلوريك',
      equation: 'Zn + 2HCl → ZnCl₂ + H₂↑',
      bubbleIntensity: 0.7, heatIntensity: 0.3,
      description: 'Steady stream of hydrogen bubbles. Zinc dissolves producing a clear solution.',
      descriptionAr: 'تيار منتظم من فقاعات الهيدروجين. الزنك يذوب منتجاً محلولاً شفافاً.',
      effects: [EffectLayer(ReactionEffect.gasRelease, Color(0x77FFFFFF), 0.65)],
    ),

    // #9 — Aluminum + HCl
    ChemReaction(
      reagentIds: {'aluminum', 'hcl'}, resultColor: const Color(0x88E0E0E0),
      name: 'Aluminum + Hydrochloric Acid', nameAr: 'ألومنيوم + حمض الهيدروكلوريك',
      equation: '2Al + 6HCl → 2AlCl₃ + 3H₂↑',
      bubbleIntensity: 0.6, heatIntensity: 0.4,
      description: 'Slow start (oxide layer), then speeds up. Produces lots of hydrogen gas.',
      descriptionAr: 'بداية بطيئة (طبقة الأكسيد) ثم يتسارع. ينتج كمية كبيرة من غاز الهيدروجين.',
      effects: [EffectLayer(ReactionEffect.gasRelease, Color(0x66FFFFFF), 0.55), EffectLayer(ReactionEffect.glow, Color(0xFFFFCC80), 0.3)],
    ),

    // #10 — Tin + HCl (slow)
    ChemReaction(
      reagentIds: {'tin', 'hcl'}, resultColor: const Color(0x88E0E0E0),
      name: 'Tin + Hydrochloric Acid', nameAr: 'قصدير + حمض الهيدروكلوريك',
      equation: 'Sn + 2HCl → SnCl₂ + H₂↑',
      bubbleIntensity: 0.3, heatIntensity: 0.15,
      description: 'Very slow reaction. Tin is low in the activity series. Gentle bubbles form.',
      descriptionAr: 'تفاعل بطيء جداً. القصدير قليل النشاط. فقاعات خفيفة.',
      effects: [EffectLayer(ReactionEffect.gasRelease, Color(0x44FFFFFF), 0.25)],
    ),

    // ═══════════════════════════════════════════════════════════════
    //  C · METALS + SULFURIC ACID  (5 reactions)
    // ═══════════════════════════════════════════════════════════════

    // #11 — Magnesium + H₂SO₄
    ChemReaction(
      reagentIds: {'magnesium', 'h2so4'}, resultColor: const Color(0x88F5F5F5),
      name: 'Magnesium + Sulfuric Acid', nameAr: 'مغنيسيوم + حمض الكبريتيك',
      equation: 'Mg + H₂SO₄ → MgSO₄ + H₂↑',
      bubbleIntensity: 0.8, heatIntensity: 0.6,
      description: 'Rapid, exothermic reaction. Magnesium ribbon dissolves with intense fizzing.',
      descriptionAr: 'تفاعل سريع طارد للحرارة. شريط المغنيسيوم يذوب مع فوران شديد.',
      effects: [EffectLayer(ReactionEffect.gasRelease, Color(0x99FFFFFF), 0.8, 1.2), EffectLayer(ReactionEffect.sparks, Color(0xFFE0E0E0), 0.5), EffectLayer(ReactionEffect.glow, Color(0xFFFF6E40), 0.5)],
    ),

    // #12 — Zinc + H₂SO₄
    ChemReaction(
      reagentIds: {'zinc', 'h2so4'}, resultColor: const Color(0x88EEEEEE),
      name: 'Zinc + Sulfuric Acid', nameAr: 'خارصين + حمض الكبريتيك',
      equation: 'Zn + H₂SO₄ → ZnSO₄ + H₂↑',
      bubbleIntensity: 0.65, heatIntensity: 0.35,
      description: 'Hydrogen gas bubbles steadily. Classic lab method for producing hydrogen.',
      descriptionAr: 'فقاعات الهيدروجين تتصاعد بانتظام. طريقة معملية كلاسيكية لإنتاج الهيدروجين.',
      effects: [EffectLayer(ReactionEffect.gasRelease, Color(0x77FFFFFF), 0.6)],
    ),

    // #13 — Iron + H₂SO₄
    ChemReaction(
      reagentIds: {'iron', 'h2so4'}, resultColor: const Color(0xBBA5D6A7),
      name: 'Iron + Sulfuric Acid', nameAr: 'حديد + حمض الكبريتيك',
      equation: 'Fe + H₂SO₄ → FeSO₄ + H₂↑',
      bubbleIntensity: 0.5, heatIntensity: 0.3,
      description: 'Iron dissolves producing green iron(II) sulfate solution and hydrogen.',
      descriptionAr: 'الحديد يذوب منتجاً محلول كبريتات الحديد II الأخضر وغاز الهيدروجين.',
      effects: [EffectLayer(ReactionEffect.gasRelease, Color(0x66FFFFFF), 0.45), EffectLayer(ReactionEffect.colorWave, Color(0xBBA5D6A7), 0.5)],
    ),

    // #14 — Aluminum + H₂SO₄
    ChemReaction(
      reagentIds: {'aluminum', 'h2so4'}, resultColor: const Color(0x88E0E0E0),
      name: 'Aluminum + Sulfuric Acid', nameAr: 'ألومنيوم + حمض الكبريتيك',
      equation: '2Al + 3H₂SO₄ → Al₂(SO₄)₃ + 3H₂↑',
      bubbleIntensity: 0.55, heatIntensity: 0.4,
      description: 'Aluminum foil reacts after oxide layer breaks. Gets warm with steady bubbling.',
      descriptionAr: 'رقائق الألومنيوم تتفاعل بعد كسر طبقة الأكسيد. تسخن مع فقاعات منتظمة.',
      effects: [EffectLayer(ReactionEffect.gasRelease, Color(0x66FFFFFF), 0.5), EffectLayer(ReactionEffect.glow, Color(0xFFFFCC80), 0.3)],
    ),

    // #15 — Tin + H₂SO₄
    ChemReaction(
      reagentIds: {'tin', 'h2so4'}, resultColor: const Color(0x88F5F5F5),
      name: 'Tin + Sulfuric Acid', nameAr: 'قصدير + حمض الكبريتيك',
      equation: 'Sn + H₂SO₄ → SnSO₄ + H₂↑',
      bubbleIntensity: 0.25, heatIntensity: 0.15,
      description: 'Very slow. Tin barely reacts with dilute sulfuric acid at room temperature.',
      descriptionAr: 'بطيء جداً. القصدير بالكاد يتفاعل مع حمض الكبريتيك المخفف.',
      effects: [EffectLayer(ReactionEffect.gasRelease, Color(0x33FFFFFF), 0.2)],
    ),

    // ═══════════════════════════════════════════════════════════════
    //  D · ACID-BASE NEUTRALIZATION  (10 reactions)
    // ═══════════════════════════════════════════════════════════════

    // #16 — HCl + NaOH
    ChemReaction(
      reagentIds: {'hcl', 'naoh'}, resultColor: const Color(0x88B3E5FC),
      name: 'HCl + NaOH Neutralization', nameAr: 'تعادل HCl + NaOH',
      equation: 'HCl + NaOH → NaCl + H₂O',
      bubbleIntensity: 0.3, heatIntensity: 0.4,
      description: 'Classic strong acid + strong base. Produces table salt and water. pH becomes 7.',
      descriptionAr: 'حمض قوي + قاعدة قوية. ينتج ملح الطعام وماء. الأس الهيدروجيني يصبح 7.',
      effects: [EffectLayer(ReactionEffect.glow, Color(0xFF42A5F5), 0.4), EffectLayer(ReactionEffect.colorWave, Color(0x88B3E5FC), 0.5)],
    ),

    // #17 — H₂SO₄ + NaOH
    ChemReaction(
      reagentIds: {'h2so4', 'naoh'}, resultColor: const Color(0x88BBDEFB),
      name: 'Sulfuric Acid + Sodium Hydroxide', nameAr: 'حمض الكبريتيك + هيدروكسيد الصوديوم',
      equation: 'H₂SO₄ + 2NaOH → Na₂SO₄ + 2H₂O',
      bubbleIntensity: 0.25, heatIntensity: 0.5,
      description: 'Diprotic acid neutralization. More heat released than HCl+NaOH. Produces sodium sulfate.',
      descriptionAr: 'تعادل حمض ثنائي البروتون. حرارة أكثر من HCl+NaOH. ينتج كبريتات الصوديوم.',
      effects: [EffectLayer(ReactionEffect.glow, Color(0xFF42A5F5), 0.5), EffectLayer(ReactionEffect.colorWave, Color(0x88BBDEFB), 0.4)],
    ),

    // #18 — HNO₃ + KOH
    ChemReaction(
      reagentIds: {'hno3', 'koh'}, resultColor: const Color(0x88E1F5FE),
      name: 'Nitric Acid + Potassium Hydroxide', nameAr: 'حمض النيتريك + هيدروكسيد البوتاسيوم',
      equation: 'HNO₃ + KOH → KNO₃ + H₂O',
      bubbleIntensity: 0.2, heatIntensity: 0.4,
      description: 'Produces potassium nitrate — a key ingredient in fertilizers and fireworks!',
      descriptionAr: 'ينتج نترات البوتاسيوم — مكون أساسي في الأسمدة والألعاب النارية!',
      effects: [EffectLayer(ReactionEffect.glow, Color(0xFF26A69A), 0.4), EffectLayer(ReactionEffect.colorWave, Color(0x88E1F5FE), 0.4)],
    ),

    // #19 — Vinegar + NaOH (weak acid)
    ChemReaction(
      reagentIds: {'vinegar', 'naoh'}, resultColor: const Color(0x77E8EAF6),
      name: 'Vinegar + Sodium Hydroxide', nameAr: 'خل + هيدروكسيد الصوديوم',
      equation: 'CH₃COOH + NaOH → CH₃COONa + H₂O',
      bubbleIntensity: 0.1, heatIntensity: 0.2,
      description: 'Weak acid + strong base. Gentle reaction producing sodium acetate (de-icer salt!).',
      descriptionAr: 'حمض ضعيف + قاعدة قوية. تفاعل لطيف ينتج خلات الصوديوم (ملح مذيب الجليد!).',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0x77E8EAF6), 0.3)],
    ),

    // #20 — HCl + KOH
    ChemReaction(
      reagentIds: {'hcl', 'koh'}, resultColor: const Color(0x88E3F2FD),
      name: 'HCl + Potassium Hydroxide', nameAr: 'حمض الهيدروكلوريك + هيدروكسيد البوتاسيوم',
      equation: 'HCl + KOH → KCl + H₂O',
      bubbleIntensity: 0.2, heatIntensity: 0.4,
      description: 'Produces potassium chloride — used as salt substitute and in medicine.',
      descriptionAr: 'ينتج كلوريد البوتاسيوم — يُستخدم كبديل للملح وفي الطب.',
      effects: [EffectLayer(ReactionEffect.glow, Color(0xFF42A5F5), 0.35), EffectLayer(ReactionEffect.colorWave, Color(0x88E3F2FD), 0.4)],
    ),

    // #21 — H₂SO₄ + Ca(OH)₂ (makes plaster!)
    ChemReaction(
      reagentIds: {'h2so4', 'ca_oh_2'}, resultColor: const Color(0xBBF5F5F5),
      name: 'Sulfuric Acid + Lime Water', nameAr: 'حمض الكبريتيك + ماء الجير',
      equation: 'H₂SO₄ + Ca(OH)₂ → CaSO₄↓ + 2H₂O',
      bubbleIntensity: 0.15, heatIntensity: 0.5,
      description: 'Produces calcium sulfate (gypsum/plaster)! White precipitate forms from neutralization.',
      descriptionAr: 'ينتج كبريتات الكالسيوم (الجبس)! راسب أبيض يتكون من التعادل.',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xDDF5F5F5), 0.6), EffectLayer(ReactionEffect.glow, Color(0xFFFF8A65), 0.4)],
    ),

    // #22 — HCl + NH₄OH (smoky!)
    ChemReaction(
      reagentIds: {'hcl', 'nh4oh'}, resultColor: const Color(0x88F5F5F5),
      name: 'HCl + Ammonia Solution', nameAr: 'حمض الهيدروكلوريك + محلول الأمونيا',
      equation: 'HCl + NH₄OH → NH₄Cl + H₂O',
      bubbleIntensity: 0.3, heatIntensity: 0.3,
      description: 'White smoke of ammonium chloride forms! Classic "smoking" demonstration.',
      descriptionAr: 'دخان أبيض من كلوريد الأمونيوم! تجربة "التدخين" الكلاسيكية.',
      effects: [EffectLayer(ReactionEffect.smoke, Color(0xCCFFFFFF), 0.8, 1.2), EffectLayer(ReactionEffect.glow, Color(0xFFFFCC80), 0.2)],
    ),

    // #23 — H₃PO₄ + NaOH
    ChemReaction(
      reagentIds: {'h3po4', 'naoh'}, resultColor: const Color(0x88E8F5E9),
      name: 'Phosphoric Acid + Sodium Hydroxide', nameAr: 'حمض الفوسفوريك + هيدروكسيد الصوديوم',
      equation: 'H₃PO₄ + 3NaOH → Na₃PO₄ + 3H₂O',
      bubbleIntensity: 0.15, heatIntensity: 0.35,
      description: 'Triprotic acid needs 3x NaOH! Produces sodium phosphate (detergent ingredient).',
      descriptionAr: 'حمض ثلاثي البروتون يحتاج 3 أضعاف NaOH! ينتج فوسفات الصوديوم (مكون المنظفات).',
      effects: [EffectLayer(ReactionEffect.glow, Color(0xFF26A69A), 0.3), EffectLayer(ReactionEffect.colorWave, Color(0x88E8F5E9), 0.3)],
    ),

    // #24 — H₂SO₄ + KOH
    ChemReaction(
      reagentIds: {'h2so4', 'koh'}, resultColor: const Color(0x88E8EAF6),
      name: 'Sulfuric Acid + Potassium Hydroxide', nameAr: 'حمض الكبريتيك + هيدروكسيد البوتاسيوم',
      equation: 'H₂SO₄ + 2KOH → K₂SO₄ + 2H₂O',
      bubbleIntensity: 0.2, heatIntensity: 0.5,
      description: 'Produces potassium sulfate — an important agricultural fertilizer.',
      descriptionAr: 'ينتج كبريتات البوتاسيوم — سماد زراعي مهم.',
      effects: [EffectLayer(ReactionEffect.glow, Color(0xFF42A5F5), 0.45), EffectLayer(ReactionEffect.colorWave, Color(0x88E8EAF6), 0.4)],
    ),

    // #25 — HNO₃ + NaOH
    ChemReaction(
      reagentIds: {'hno3', 'naoh'}, resultColor: const Color(0x88E3F2FD),
      name: 'Nitric Acid + Sodium Hydroxide', nameAr: 'حمض النيتريك + هيدروكسيد الصوديوم',
      equation: 'HNO₃ + NaOH → NaNO₃ + H₂O',
      bubbleIntensity: 0.2, heatIntensity: 0.4,
      description: 'Produces sodium nitrate — historically used as a food preservative.',
      descriptionAr: 'ينتج نترات الصوديوم — استُخدم تاريخياً كمادة حافظة للأغذية.',
      effects: [EffectLayer(ReactionEffect.glow, Color(0xFF42A5F5), 0.4), EffectLayer(ReactionEffect.colorWave, Color(0x88E3F2FD), 0.3)],
    ),

    // ═══════════════════════════════════════════════════════════════
    //  E · SINGLE DISPLACEMENT  (8 reactions)
    // ═══════════════════════════════════════════════════════════════

    // #26 — Fe + CuSO₄ (copper deposits)
    ChemReaction(
      reagentIds: {'iron', 'copper'}, resultColor: const Color(0xBB4CAF50),
      name: 'Iron + Copper Sulfate', nameAr: 'حديد + كبريتات النحاس',
      equation: 'Fe + CuSO₄ → FeSO₄ + Cu↓',
      bubbleIntensity: 0.1, heatIntensity: 0.2,
      description: 'Iron displaces copper. Solution turns green, reddish copper deposits on iron nail.',
      descriptionAr: 'الحديد يحل محل النحاس. المحلول يتحول للأخضر والنحاس يترسب على المسمار.',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xFFE57373), 0.5), EffectLayer(ReactionEffect.colorWave, Color(0xBB4CAF50), 0.6)],
    ),

    // #27 — Zn + CuSO₄
    ChemReaction(
      reagentIds: {'zinc', 'copper'}, resultColor: const Color(0xBB81C784),
      name: 'Zinc + Copper Sulfate', nameAr: 'خارصين + كبريتات النحاس',
      equation: 'Zn + CuSO₄ → ZnSO₄ + Cu↓',
      bubbleIntensity: 0.1, heatIntensity: 0.25,
      description: 'Zinc displaces copper. Blue solution fades to colorless. Copper metal appears.',
      descriptionAr: 'الزنك يحل محل النحاس. المحلول الأزرق يصبح شفافاً. النحاس يظهر.',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xFFE57373), 0.5), EffectLayer(ReactionEffect.colorWave, Color(0xBB81C784), 0.5)],
    ),

    // #28 — Mg + CuSO₄ (exothermic!)
    ChemReaction(
      reagentIds: {'magnesium', 'copper'}, resultColor: const Color(0xBBA5D6A7),
      name: 'Magnesium + Copper Sulfate', nameAr: 'مغنيسيوم + كبريتات النحاس',
      equation: 'Mg + CuSO₄ → MgSO₄ + Cu↓',
      bubbleIntensity: 0.2, heatIntensity: 0.35,
      description: 'More vigorous than iron! Magnesium is higher in activity series. Gets noticeably warm.',
      descriptionAr: 'أقوى من الحديد! المغنيسيوم أنشط في سلسلة النشاط. يسخن بشكل ملحوظ.',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xFFE57373), 0.6), EffectLayer(ReactionEffect.colorWave, Color(0xBBA5D6A7), 0.5), EffectLayer(ReactionEffect.glow, Color(0xFFFFCC80), 0.3)],
    ),

    // #29 — Cu + AgNO₃ (silver tree!)
    ChemReaction(
      reagentIds: {'copper_metal', 'silver_nitrate'}, resultColor: const Color(0xBB4FC3F7),
      name: 'Copper + Silver Nitrate', nameAr: 'نحاس + نترات الفضة',
      equation: 'Cu + 2AgNO₃ → Cu(NO₃)₂ + 2Ag↓',
      bubbleIntensity: 0.05, heatIntensity: 0.1,
      description: 'Silver crystals grow on copper surface like a "silver tree"! Solution turns blue.',
      descriptionAr: 'بلورات الفضة تنمو على سطح النحاس كـ"شجرة فضية"! المحلول يتحول للأزرق.',
      effects: [EffectLayer(ReactionEffect.crystallize, Color(0xFFE0E0E0), 0.7, 1.2), EffectLayer(ReactionEffect.colorWave, Color(0xBB4FC3F7), 0.5)],
    ),

    // #30 — Fe + AgNO₃
    ChemReaction(
      reagentIds: {'iron', 'silver_nitrate'}, resultColor: const Color(0xBBB0BEC5),
      name: 'Iron + Silver Nitrate', nameAr: 'حديد + نترات الفضة',
      equation: 'Fe + 2AgNO₃ → Fe(NO₃)₂ + 2Ag↓',
      bubbleIntensity: 0.05, heatIntensity: 0.1,
      description: 'Silver crystals deposit on iron. Solution turns pale green from iron nitrate.',
      descriptionAr: 'بلورات الفضة تترسب على الحديد. المحلول يتحول للأخضر الفاتح.',
      effects: [EffectLayer(ReactionEffect.crystallize, Color(0xFFE0E0E0), 0.6), EffectLayer(ReactionEffect.colorWave, Color(0xBBA5D6A7), 0.4)],
    ),

    // #31 — Zn + FeSO₄
    ChemReaction(
      reagentIds: {'zinc', 'iron_ii_sulfate'}, resultColor: const Color(0x88E0E0E0),
      name: 'Zinc + Iron(II) Sulfate', nameAr: 'خارصين + كبريتات الحديد',
      equation: 'Zn + FeSO₄ → ZnSO₄ + Fe↓',
      bubbleIntensity: 0.05, heatIntensity: 0.15,
      description: 'Zinc displaces iron. Green solution fades. Dark iron particles appear.',
      descriptionAr: 'الزنك يحل محل الحديد. المحلول الأخضر يبهت. جزيئات حديد داكنة تظهر.',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xFF616161), 0.4), EffectLayer(ReactionEffect.colorWave, Color(0x88E0E0E0), 0.4)],
    ),

    // #32 — Zn + Pb(NO₃)₂ (lead tree)
    ChemReaction(
      reagentIds: {'zinc', 'lead_nitrate'}, resultColor: const Color(0x88E0E0E0),
      name: 'Zinc + Lead Nitrate', nameAr: 'خارصين + نترات الرصاص',
      equation: 'Zn + Pb(NO₃)₂ → Zn(NO₃)₂ + Pb↓',
      bubbleIntensity: 0.05, heatIntensity: 0.1,
      description: 'Lead crystals grow on zinc surface — "Lead Tree" experiment. Beautiful metallic needles.',
      descriptionAr: 'بلورات الرصاص تنمو على سطح الزنك — تجربة "شجرة الرصاص". إبر معدنية جميلة.',
      effects: [EffectLayer(ReactionEffect.crystallize, Color(0xFFBDBDBD), 0.7, 1.3)],
    ),

    // #33 — Al + CuSO₄
    ChemReaction(
      reagentIds: {'aluminum', 'copper'}, resultColor: const Color(0xBB66BB6A),
      name: 'Aluminum + Copper Sulfate', nameAr: 'ألومنيوم + كبريتات النحاس',
      equation: '2Al + 3CuSO₄ → Al₂(SO₄)₃ + 3Cu↓',
      bubbleIntensity: 0.15, heatIntensity: 0.3,
      description: 'Aluminum foil turns brown as copper deposits. Solution becomes colorless.',
      descriptionAr: 'رقائق الألومنيوم تتحول للبني عند ترسب النحاس. المحلول يصبح شفافاً.',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xFFE57373), 0.5), EffectLayer(ReactionEffect.colorWave, Color(0x88E0E0E0), 0.5)],
    ),

    // ═══════════════════════════════════════════════════════════════
    //  F · PRECIPITATION / DOUBLE DISPLACEMENT  (15 reactions)
    // ═══════════════════════════════════════════════════════════════

    // #34 — AgCl↓ (white milky)
    ChemReaction(
      reagentIds: {'sodium_chloride', 'silver_nitrate'}, resultColor: const Color(0xDDF5F5F5),
      name: 'Silver Chloride Precipitation', nameAr: 'ترسيب كلوريد الفضة',
      equation: 'NaCl + AgNO₃ → AgCl↓ + NaNO₃',
      bubbleIntensity: 0.0, heatIntensity: 0.05,
      description: 'Instant white curdy precipitate! Classic test for chloride ions. Darkens in light.',
      descriptionAr: 'راسب أبيض متجبن فوري! اختبار كلاسيكي لأيونات الكلوريد. يسود في الضوء.',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xDDF5F5F5), 0.8, 1.2)],
    ),

    // #35 — BaSO₄↓ (white powder)
    ChemReaction(
      reagentIds: {'barium_chloride', 'sodium_sulfate'}, resultColor: const Color(0xDDEEEEEE),
      name: 'Barium Sulfate Precipitation', nameAr: 'ترسيب كبريتات الباريوم',
      equation: 'BaCl₂ + Na₂SO₄ → BaSO₄↓ + 2NaCl',
      bubbleIntensity: 0.0, heatIntensity: 0.05,
      description: 'Dense white precipitate! Used to test for sulfate ions. Insoluble in all acids.',
      descriptionAr: 'راسب أبيض كثيف! يُستخدم للكشف عن أيونات الكبريتات. غير قابل للذوبان.',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xDDEEEEEE), 0.8)],
    ),

    // #36 — PbI₂↓ (GOLDEN RAIN!! 🌟)
    ChemReaction(
      reagentIds: {'lead_nitrate', 'potassium_iodide'}, resultColor: const Color(0xEEFFD740),
      name: 'Golden Rain (Lead Iodide)', nameAr: 'المطر الذهبي (يوديد الرصاص)',
      equation: 'Pb(NO₃)₂ + 2KI → PbI₂↓ + 2KNO₃',
      bubbleIntensity: 0.0, heatIntensity: 0.05,
      description: '✨ Spectacular golden-yellow crystals! "Golden Rain" — one of chemistry\'s most beautiful reactions.',
      descriptionAr: '✨ بلورات ذهبية رائعة! "المطر الذهبي" — من أجمل التفاعلات في الكيمياء.',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xEEFFD740), 1.0, 1.5), EffectLayer(ReactionEffect.colorWave, Color(0xCCFFD740), 0.7), EffectLayer(ReactionEffect.sparks, Color(0xFFFFD740), 0.3)],
    ),

    // #37 — Fe(OH)₃↓ (rusty brown)
    ChemReaction(
      reagentIds: {'iron_iii_chloride', 'naoh'}, resultColor: const Color(0xCC8D6E63),
      name: 'Iron(III) Hydroxide Precipitation', nameAr: 'ترسيب هيدروكسيد الحديد III',
      equation: 'FeCl₃ + 3NaOH → Fe(OH)₃↓ + 3NaCl',
      bubbleIntensity: 0.0, heatIntensity: 0.1,
      description: 'Reddish-brown gelatinous precipitate. Looks like rust! Test for Fe³⁺ ions.',
      descriptionAr: 'راسب بني محمر هلامي. يبدو كالصدأ! اختبار لأيونات الحديد III.',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xCC8D6E63), 0.8, 1.1), EffectLayer(ReactionEffect.colorWave, Color(0x998D6E63), 0.5)],
    ),

    // #38 — Cu(OH)₂↓ (sky blue gel!)
    ChemReaction(
      reagentIds: {'copper', 'naoh'}, resultColor: const Color(0xCC42A5F5),
      name: 'Copper(II) Hydroxide Precipitation', nameAr: 'ترسيب هيدروكسيد النحاس',
      equation: 'CuSO₄ + 2NaOH → Cu(OH)₂↓ + Na₂SO₄',
      bubbleIntensity: 0.0, heatIntensity: 0.1,
      description: 'Beautiful sky-blue gelatinous precipitate! Decomposes to black CuO when heated.',
      descriptionAr: 'راسب هلامي أزرق سماوي جميل! يتحلل لأكسيد النحاس الأسود عند التسخين.',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xCC42A5F5), 0.8, 1.1), EffectLayer(ReactionEffect.colorWave, Color(0x9942A5F5), 0.5)],
    ),

    // #39 — Fe(OH)₂↓ (dark green → oxidizes!)
    ChemReaction(
      reagentIds: {'iron_ii_sulfate', 'naoh'}, resultColor: const Color(0xCC2E7D32),
      name: 'Iron(II) Hydroxide Precipitation', nameAr: 'ترسيب هيدروكسيد الحديد II',
      equation: 'FeSO₄ + 2NaOH → Fe(OH)₂↓ + Na₂SO₄',
      bubbleIntensity: 0.0, heatIntensity: 0.05,
      description: 'Dark green precipitate that rapidly oxidizes to brown Fe(OH)₃ in air!',
      descriptionAr: 'راسب أخضر داكن يتأكسد سريعاً في الهواء إلى هيدروكسيد حديد III البني!',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xCC2E7D32), 0.7), EffectLayer(ReactionEffect.colorWave, Color(0x992E7D32), 0.5)],
    ),

    // #40 — CuS↓ (JET BLACK!)
    ChemReaction(
      reagentIds: {'copper', 'sodium_sulfide'}, resultColor: const Color(0xDD212121),
      name: 'Copper Sulfide Precipitation', nameAr: 'ترسيب كبريتيد النحاس',
      equation: 'CuSO₄ + Na₂S → CuS↓ + Na₂SO₄',
      bubbleIntensity: 0.0, heatIntensity: 0.05,
      description: 'Jet-black precipitate instantly! One of the most dramatic color changes in chemistry.',
      descriptionAr: 'راسب أسود حالك فوري! من أكثر تغيرات اللون دراماتيكية في الكيمياء.',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xDD212121), 0.9, 1.3), EffectLayer(ReactionEffect.colorWave, Color(0xCC212121), 0.6)],
    ),

    // #41 — PbS↓ (black)
    ChemReaction(
      reagentIds: {'lead_nitrate', 'sodium_sulfide'}, resultColor: const Color(0xDD1A1A1A),
      name: 'Lead Sulfide Precipitation', nameAr: 'ترسيب كبريتيد الرصاص',
      equation: 'Pb(NO₃)₂ + Na₂S → PbS↓ + 2NaNO₃',
      bubbleIntensity: 0.0, heatIntensity: 0.05,
      description: 'Black precipitate. Used historically to detect lead in paints and water.',
      descriptionAr: 'راسب أسود. استُخدم تاريخياً للكشف عن الرصاص في الدهانات والمياه.',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xDD1A1A1A), 0.8)],
    ),

    // #42 — AgI↓ (yellow)
    ChemReaction(
      reagentIds: {'silver_nitrate', 'potassium_iodide'}, resultColor: const Color(0xCCFDD835),
      name: 'Silver Iodide Precipitation', nameAr: 'ترسيب يوديد الفضة',
      equation: 'AgNO₃ + KI → AgI↓ + KNO₃',
      bubbleIntensity: 0.0, heatIntensity: 0.05,
      description: 'Pale yellow precipitate. Silver iodide is used for cloud seeding (making rain!).',
      descriptionAr: 'راسب أصفر فاتح. يوديد الفضة يُستخدم في استمطار السحب (صنع المطر!).',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xCCFDD835), 0.7)],
    ),

    // #43 — CaCO₃↓ (chalky white)
    ChemReaction(
      reagentIds: {'calcium_chloride', 'sodium_carbonate'}, resultColor: const Color(0xCCE0E0E0),
      name: 'Calcium Carbonate Precipitation', nameAr: 'ترسيب كربونات الكالسيوم',
      equation: 'CaCl₂ + Na₂CO₃ → CaCO₃↓ + 2NaCl',
      bubbleIntensity: 0.0, heatIntensity: 0.05,
      description: 'White chalky precipitate — this is how chalk and limestone form in nature!',
      descriptionAr: 'راسب أبيض طباشيري — هكذا تتكون الصخور الجيرية والطباشير في الطبيعة!',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xCCE0E0E0), 0.7), EffectLayer(ReactionEffect.colorWave, Color(0x88E0E0E0), 0.4)],
    ),

    // #44 — PbCl₂↓ (white needles)
    ChemReaction(
      reagentIds: {'lead_nitrate', 'sodium_chloride'}, resultColor: const Color(0xCCF5F5F5),
      name: 'Lead Chloride Precipitation', nameAr: 'ترسيب كلوريد الرصاص',
      equation: 'Pb(NO₃)₂ + 2NaCl → PbCl₂↓ + 2NaNO₃',
      bubbleIntensity: 0.0, heatIntensity: 0.05,
      description: 'White needle-like crystals. Dissolves in hot water, recrystallizes on cooling — beautiful!',
      descriptionAr: 'بلورات بيضاء إبرية. تذوب في الماء الساخن وتتبلور عند التبريد — جميلة!',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xCCF5F5F5), 0.6), EffectLayer(ReactionEffect.crystallize, Color(0xCCF5F5F5), 0.5)],
    ),

    // #45 — Fe(SCN)₃ (BLOOD RED!) 🩸
    ChemReaction(
      reagentIds: {'iron_iii_chloride', 'potassium_thiocyanate'}, resultColor: const Color(0xDDB71C1C),
      name: 'Iron Thiocyanate (Blood Red)', nameAr: 'ثيوسيانات الحديد (أحمر دموي)',
      equation: 'FeCl₃ + 3KSCN → Fe(SCN)₃ + 3KCl',
      bubbleIntensity: 0.0, heatIntensity: 0.0,
      description: '🩸 Dramatic blood-red color! Classic test for Fe³⁺ ions. Used in forensic chemistry.',
      descriptionAr: '🩸 لون أحمر دموي مثير! اختبار كلاسيكي لأيونات الحديد III. يُستخدم في الكيمياء الجنائية.',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0xDDB71C1C), 0.95, 1.3)],
    ),

    // #46 — CuCl₂ + BaSO₄↓ (blue + white!)
    ChemReaction(
      reagentIds: {'copper', 'barium_chloride'}, resultColor: const Color(0xBB4FC3F7),
      name: 'Copper Sulfate + Barium Chloride', nameAr: 'كبريتات النحاس + كلوريد الباريوم',
      equation: 'CuSO₄ + BaCl₂ → CuCl₂ + BaSO₄↓',
      bubbleIntensity: 0.0, heatIntensity: 0.05,
      description: 'Double displacement: white BaSO₄ precipitate in a blue copper chloride solution!',
      descriptionAr: 'إحلال مزدوج: راسب أبيض من كبريتات الباريوم في محلول كلوريد النحاس الأزرق!',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xDDEEEEEE), 0.6), EffectLayer(ReactionEffect.colorWave, Color(0xBB4FC3F7), 0.5)],
    ),

    // #47 — AgBr↓ (cream/pale yellow)
    ChemReaction(
      reagentIds: {'silver_nitrate', 'sodium_bromide'}, resultColor: const Color(0xCCFFF9C4),
      name: 'Silver Bromide Precipitation', nameAr: 'ترسيب بروميد الفضة',
      equation: 'AgNO₃ + NaBr → AgBr↓ + NaNO₃',
      bubbleIntensity: 0.0, heatIntensity: 0.05,
      description: 'Cream-colored precipitate. AgBr was THE key chemical in black & white photography!',
      descriptionAr: 'راسب كريمي اللون. بروميد الفضة كان المادة الأساسية في التصوير بالأبيض والأسود!',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xCCFFF9C4), 0.7)],
    ),

    // #48 — Double precip: Ba(OH)₂ + H₂SO₄
    ChemReaction(
      reagentIds: {'ba_oh_2', 'h2so4'}, resultColor: const Color(0xDDEEEEEE),
      name: 'Barium Hydroxide + Sulfuric Acid', nameAr: 'هيدروكسيد الباريوم + حمض الكبريتيك',
      equation: 'Ba(OH)₂ + H₂SO₄ → BaSO₄↓ + 2H₂O',
      bubbleIntensity: 0.1, heatIntensity: 0.4,
      description: 'Both neutralization AND precipitation! White BaSO₄ precipitate + heat release.',
      descriptionAr: 'تعادل وترسيب معاً! راسب أبيض من كبريتات الباريوم + انطلاق حرارة.',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xDDEEEEEE), 0.7), EffectLayer(ReactionEffect.glow, Color(0xFFFF8A65), 0.4)],
    ),

    // ═══════════════════════════════════════════════════════════════
    //  G · GAS-PRODUCING REACTIONS  (10 reactions)
    // ═══════════════════════════════════════════════════════════════

    // #49 — Vinegar + Baking Soda (volcano! 🌋)
    ChemReaction(
      reagentIds: {'vinegar', 'baking_soda'}, resultColor: const Color(0xAAE0E0E0),
      name: 'Vinegar + Baking Soda', nameAr: 'خل + بيكربونات الصوديوم',
      equation: 'CH₃COOH + NaHCO₃ → CH₃COONa + H₂O + CO₂↑',
      bubbleIntensity: 0.8, heatIntensity: 0.1,
      description: '🌋 Classic volcano reaction! CO₂ gas bubbles vigorously producing foam.',
      descriptionAr: '🌋 تفاعل البركان الكلاسيكي! غاز CO₂ يتصاعد بقوة منتجاً رغوة.',
      effects: [EffectLayer(ReactionEffect.foam, Color(0xCCFFFFFF), 0.85, 1.3), EffectLayer(ReactionEffect.gasRelease, Color(0x88FFFFFF), 0.7)],
    ),

    // #50 — HCl + Na₂CO₃ (fizzy!)
    ChemReaction(
      reagentIds: {'hcl', 'sodium_carbonate'}, resultColor: const Color(0x88E0E0E0),
      name: 'HCl + Sodium Carbonate', nameAr: 'حمض الهيدروكلوريك + كربونات الصوديوم',
      equation: '2HCl + Na₂CO₃ → 2NaCl + H₂O + CO₂↑',
      bubbleIntensity: 0.75, heatIntensity: 0.15,
      description: 'Vigorous fizzing as CO₂ is released. Classic test for carbonate ions.',
      descriptionAr: 'فوران قوي عند تحرر CO₂. اختبار كلاسيكي لأيونات الكربونات.',
      effects: [EffectLayer(ReactionEffect.foam, Color(0xBBFFFFFF), 0.7), EffectLayer(ReactionEffect.gasRelease, Color(0x88FFFFFF), 0.7)],
    ),

    // #51 — HCl + CaCO₃ (limestone dissolving)
    ChemReaction(
      reagentIds: {'hcl', 'calcium_carbonate'}, resultColor: const Color(0x88E0E0E0),
      name: 'Acid + Limestone', nameAr: 'حمض + حجر جيري',
      equation: '2HCl + CaCO₃ → CaCl₂ + H₂O + CO₂↑',
      bubbleIntensity: 0.65, heatIntensity: 0.1,
      description: 'Limestone dissolves with fizzing. This is how acid rain damages buildings!',
      descriptionAr: 'الحجر الجيري يذوب مع فوران. هكذا يُتلف المطر الحمضي المباني!',
      effects: [EffectLayer(ReactionEffect.foam, Color(0xAAFFFFFF), 0.6), EffectLayer(ReactionEffect.gasRelease, Color(0x77FFFFFF), 0.5)],
    ),

    // #52 — H₂SO₄ + Na₂CO₃
    ChemReaction(
      reagentIds: {'h2so4', 'sodium_carbonate'}, resultColor: const Color(0x88E0E0E0),
      name: 'Sulfuric Acid + Sodium Carbonate', nameAr: 'حمض الكبريتيك + كربونات الصوديوم',
      equation: 'H₂SO₄ + Na₂CO₃ → Na₂SO₄ + H₂O + CO₂↑',
      bubbleIntensity: 0.7, heatIntensity: 0.2,
      description: 'CO₂ fizzes out. The remaining sodium sulfate is used in glass manufacturing.',
      descriptionAr: 'CO₂ يتصاعد بفوران. كبريتات الصوديوم المتبقية تُستخدم في صناعة الزجاج.',
      effects: [EffectLayer(ReactionEffect.foam, Color(0xBBFFFFFF), 0.65), EffectLayer(ReactionEffect.gasRelease, Color(0x88FFFFFF), 0.6)],
    ),

    // #53 — H₂O₂ + MnO₂ (ELEPHANT TOOTHPASTE!! 🐘)
    ChemReaction(
      reagentIds: {'hydrogen_peroxide', 'manganese_dioxide'}, resultColor: const Color(0x88FFFFFF),
      name: 'Elephant Toothpaste', nameAr: 'معجون أسنان الفيل',
      equation: '2H₂O₂ →[MnO₂] 2H₂O + O₂↑',
      bubbleIntensity: 0.95, heatIntensity: 0.3,
      description: '🐘 Spectacular foam eruption! MnO₂ catalyzes rapid O₂ release. One of the most famous demos!',
      descriptionAr: '🐘 انفجار رغوي مذهل! MnO₂ يسرّع إطلاق الأكسجين. من أشهر التجارب!',
      effects: [EffectLayer(ReactionEffect.foam, Color(0xEEFFFFFF), 1.0, 1.5), EffectLayer(ReactionEffect.gasRelease, Color(0xAAFFFFFF), 0.95, 1.4)],
    ),

    // #54 — NH₄Cl + NaOH (ammonia gas!)
    ChemReaction(
      reagentIds: {'ammonium_chloride', 'naoh'}, resultColor: const Color(0x88E0E0E0),
      name: 'Ammonia Gas Release', nameAr: 'إطلاق غاز الأمونيا',
      equation: 'NH₄Cl + NaOH → NaCl + H₂O + NH₃↑',
      bubbleIntensity: 0.4, heatIntensity: 0.2,
      description: 'Pungent ammonia gas released! Turns damp litmus paper blue. Strong smell warns you!',
      descriptionAr: 'غاز الأمونيا النفاذ يتحرر! يحوّل ورق عباد الشمس المبلل للأزرق. رائحة قوية!',
      effects: [EffectLayer(ReactionEffect.smoke, Color(0xBBFFFFFF), 0.7, 1.2), EffectLayer(ReactionEffect.gasRelease, Color(0x66FFFFFF), 0.4)],
    ),

    // #55 — HCl + Na₂S (rotten eggs! 🥚💀)
    ChemReaction(
      reagentIds: {'hcl', 'sodium_sulfide'}, resultColor: const Color(0x99FFECB3),
      name: 'Hydrogen Sulfide Release', nameAr: 'إطلاق كبريتيد الهيدروجين',
      equation: '2HCl + Na₂S → 2NaCl + H₂S↑',
      bubbleIntensity: 0.5, heatIntensity: 0.1,
      description: '🥚 Rotten egg smell! H₂S is toxic — this is why volcanoes smell terrible!',
      descriptionAr: '🥚 رائحة بيض فاسد! H₂S سام — لهذا رائحة البراكين مزعجة!',
      effects: [EffectLayer(ReactionEffect.smoke, Color(0xAAC8E6C9), 0.6), EffectLayer(ReactionEffect.gasRelease, Color(0x88FFECB3), 0.5)],
    ),

    // #56 — H₂SO₄ + Na₂SO₃ (SO₂!)
    ChemReaction(
      reagentIds: {'h2so4', 'sodium_sulfite'}, resultColor: const Color(0x88E0E0E0),
      name: 'Sulfur Dioxide Release', nameAr: 'إطلاق ثاني أكسيد الكبريت',
      equation: 'H₂SO₄ + Na₂SO₃ → Na₂SO₄ + H₂O + SO₂↑',
      bubbleIntensity: 0.5, heatIntensity: 0.15,
      description: 'Sharp, choking SO₂ gas! This is the gas that causes acid rain pollution.',
      descriptionAr: 'غاز SO₂ حاد وخانق! هذا الغاز المسبب لتلوث المطر الحمضي.',
      effects: [EffectLayer(ReactionEffect.smoke, Color(0xAA9E9E9E), 0.6), EffectLayer(ReactionEffect.gasRelease, Color(0x77BDBDBD), 0.5)],
    ),

    // #57 — Vinegar + CaCO₃ (eggshell experiment!)
    ChemReaction(
      reagentIds: {'vinegar', 'calcium_carbonate'}, resultColor: const Color(0x88FFF9C4),
      name: 'Vinegar + Eggshell/Chalk', nameAr: 'خل + قشر بيض/طباشير',
      equation: '2CH₃COOH + CaCO₃ → Ca(CH₃COO)₂ + H₂O + CO₂↑',
      bubbleIntensity: 0.5, heatIntensity: 0.05,
      description: 'Eggshell dissolves slowly! Bubbles of CO₂. Leave overnight → shell becomes rubbery!',
      descriptionAr: 'قشر البيض يذوب ببطء! فقاعات CO₂. اتركه ليلة → يصبح القشر مطاطياً!',
      effects: [EffectLayer(ReactionEffect.foam, Color(0x88FFFFFF), 0.4), EffectLayer(ReactionEffect.gasRelease, Color(0x55FFFFFF), 0.4)],
    ),

    // #58 — HNO₃ + CaCO₃
    ChemReaction(
      reagentIds: {'hno3', 'calcium_carbonate'}, resultColor: const Color(0x88E0E0E0),
      name: 'Nitric Acid + Limestone', nameAr: 'حمض النيتريك + حجر جيري',
      equation: '2HNO₃ + CaCO₃ → Ca(NO₃)₂ + H₂O + CO₂↑',
      bubbleIntensity: 0.6, heatIntensity: 0.15,
      description: 'Produces calcium nitrate (fertilizer) and CO₂. Limestone fizzes and dissolves.',
      descriptionAr: 'ينتج نترات الكالسيوم (سماد) و CO₂. الحجر الجيري يفور ويذوب.',
      effects: [EffectLayer(ReactionEffect.foam, Color(0x99FFFFFF), 0.5), EffectLayer(ReactionEffect.gasRelease, Color(0x66FFFFFF), 0.5)],
    ),

    // ═══════════════════════════════════════════════════════════════
    //  H · INDICATOR REACTIONS  (8 reactions)
    // ═══════════════════════════════════════════════════════════════

    // #59 — Phenolphthalein + NaOH → PINK!
    ChemReaction(
      reagentIds: {'phenolphthalein', 'naoh'}, resultColor: const Color(0xCCE91E63),
      name: 'Phenolphthalein + Base', nameAr: 'فينولفثالين + قاعدة',
      equation: 'Phenolphthalein + OH⁻ → Pink complex',
      bubbleIntensity: 0.0, heatIntensity: 0.0,
      description: '💗 Colorless turns BRIGHT PINK! Phenolphthalein changes at pH 8.2-10.',
      descriptionAr: '💗 شفاف يتحول لوردي زاهي! الفينولفثالين يتغير عند pH 8.2-10.',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0xCCE91E63), 0.9, 1.2)],
    ),

    // #60 — Phenolphthalein + HCl → Colorless!
    ChemReaction(
      reagentIds: {'phenolphthalein', 'hcl'}, resultColor: const Color(0x22F5F5F5),
      name: 'Phenolphthalein + Acid', nameAr: 'فينولفثالين + حمض',
      equation: 'Phenolphthalein + H⁺ → Colorless',
      bubbleIntensity: 0.0, heatIntensity: 0.0,
      description: 'Pink color disappears completely! Acid protonates the indicator molecule.',
      descriptionAr: 'اللون الوردي يختفي تماماً! الحمض يبرتن جزيء الكاشف.',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0x22F5F5F5), 0.7)],
    ),

    // #61 — Litmus + HCl → RED
    ChemReaction(
      reagentIds: {'litmus', 'hcl'}, resultColor: const Color(0xCCE53935),
      name: 'Litmus + Acid', nameAr: 'عباد الشمس + حمض',
      equation: 'Blue Litmus + H⁺ → Red',
      bubbleIntensity: 0.0, heatIntensity: 0.0,
      description: 'Blue litmus paper turns RED in acid! The oldest chemical test (used since 1300s).',
      descriptionAr: 'ورق عباد الشمس الأزرق يتحول أحمر في الحمض! أقدم اختبار كيميائي (منذ 1300م).',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0xCCE53935), 0.8)],
    ),

    // #62 — Litmus + NaOH → BLUE
    ChemReaction(
      reagentIds: {'litmus', 'naoh'}, resultColor: const Color(0xCC1565C0),
      name: 'Litmus + Base', nameAr: 'عباد الشمس + قاعدة',
      equation: 'Red Litmus + OH⁻ → Blue',
      bubbleIntensity: 0.0, heatIntensity: 0.0,
      description: 'Red litmus paper turns BLUE in base! Confirms alkaline solution.',
      descriptionAr: 'ورق عباد الشمس الأحمر يتحول أزرق في القاعدة! يؤكد أن المحلول قاعدي.',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0xCC1565C0), 0.8)],
    ),

    // #63 — Methyl Orange + HCl → RED
    ChemReaction(
      reagentIds: {'methyl_orange', 'hcl'}, resultColor: const Color(0xCCFF1744),
      name: 'Methyl Orange + Acid', nameAr: 'ميثيل البرتقال + حمض',
      equation: 'Methyl Orange + H⁺ → Red',
      bubbleIntensity: 0.0, heatIntensity: 0.0,
      description: 'Orange to RED below pH 3.1. Used to detect strong acids precisely.',
      descriptionAr: 'من البرتقالي للأحمر تحت pH 3.1. يُستخدم للكشف الدقيق عن الأحماض القوية.',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0xCCFF1744), 0.8)],
    ),

    // #64 — Methyl Orange + NaOH → YELLOW
    ChemReaction(
      reagentIds: {'methyl_orange', 'naoh'}, resultColor: const Color(0xCCFFEB3B),
      name: 'Methyl Orange + Base', nameAr: 'ميثيل البرتقال + قاعدة',
      equation: 'Methyl Orange + OH⁻ → Yellow',
      bubbleIntensity: 0.0, heatIntensity: 0.0,
      description: 'Turns YELLOW above pH 4.4. The color transition range is very narrow.',
      descriptionAr: 'يتحول أصفر فوق pH 4.4. نطاق تغير اللون ضيق جداً.',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0xCCFFEB3B), 0.8)],
    ),

    // #65 — Universal Indicator + HCl → RED
    ChemReaction(
      reagentIds: {'universal_indicator', 'hcl'}, resultColor: const Color(0xCCFF5252),
      name: 'Universal Indicator + Acid', nameAr: 'كاشف عام + حمض',
      equation: 'Universal Indicator → Red (pH 1-3)',
      bubbleIntensity: 0.0, heatIntensity: 0.0,
      description: '🌈 Shows the full pH spectrum! Strong acid = bright red, weak acid = orange/yellow.',
      descriptionAr: '🌈 يُظهر طيف pH كاملاً! حمض قوي = أحمر زاهي، حمض ضعيف = برتقالي/أصفر.',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0xCCFF5252), 0.9, 1.1)],
    ),

    // #66 — Universal Indicator + NaOH → PURPLE
    ChemReaction(
      reagentIds: {'universal_indicator', 'naoh'}, resultColor: const Color(0xCC7B1FA2),
      name: 'Universal Indicator + Base', nameAr: 'كاشف عام + قاعدة',
      equation: 'Universal Indicator → Purple (pH 12-14)',
      bubbleIntensity: 0.0, heatIntensity: 0.0,
      description: '🌈 Strong base = deep purple/violet. Weak base = blue. Neutral = green.',
      descriptionAr: '🌈 قاعدة قوية = بنفسجي غامق. قاعدة ضعيفة = أزرق. متعادل = أخضر.',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0xCC7B1FA2), 0.9, 1.1)],
    ),

    // ═══════════════════════════════════════════════════════════════
    //  I · REDOX & COLOR CHANGE  (10 reactions)
    // ═══════════════════════════════════════════════════════════════

    // #67 — KMnO₄ + H₂O₂ (purple → CLEAR!)
    ChemReaction(
      reagentIds: {'potassium_permanganate', 'hydrogen_peroxide'}, resultColor: const Color(0x44E0E0E0),
      name: 'Permanganate Decolorization', nameAr: 'إزالة لون البرمنغنات',
      equation: '2KMnO₄ + 5H₂O₂ + 3H₂SO₄ → 2MnSO₄ + K₂SO₄ + 5O₂↑ + 8H₂O',
      bubbleIntensity: 0.8, heatIntensity: 0.4,
      description: '🟣→⬜ Dark purple VANISHES! Vigorous oxygen bubbles. One of chemistry\'s most dramatic demos.',
      descriptionAr: '🟣→⬜ البنفسجي الغامق يختفي! فقاعات أكسجين قوية. من أكثر التجارب إثارة.',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0x44E0E0E0), 0.9), EffectLayer(ReactionEffect.gasRelease, Color(0x88FFFFFF), 0.8, 1.2), EffectLayer(ReactionEffect.sparks, Color(0xBB7B1FA2), 0.3)],
    ),

    // #68 — Starch + Iodine → DARK BLUE/BLACK!
    ChemReaction(
      reagentIds: {'starch_solution', 'iodine_solution'}, resultColor: const Color(0xDD1A237E),
      name: 'Starch-Iodine Test', nameAr: 'اختبار النشا-اليود',
      equation: 'Starch + I₂ → Deep blue-black complex',
      bubbleIntensity: 0.0, heatIntensity: 0.0,
      description: '🔵 Instant dark blue-black! Iodine molecules trapped inside starch helix. Food science test!',
      descriptionAr: '🔵 أزرق-أسود داكن فوري! جزيئات اليود محتجزة داخل حلزون النشا. اختبار غذائي!',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0xDD1A237E), 1.0, 1.3)],
    ),

    // #69 — Na₂S₂O₃ + I₂ (iodine disappears!)
    ChemReaction(
      reagentIds: {'sodium_thiosulfate', 'iodine_solution'}, resultColor: const Color(0x44F5F5F5),
      name: 'Iodine Decolorization', nameAr: 'إزالة لون اليود',
      equation: '2Na₂S₂O₃ + I₂ → Na₂S₄O₆ + 2NaI',
      bubbleIntensity: 0.0, heatIntensity: 0.0,
      description: 'Brown iodine solution turns COLORLESS! Na₂S₂O₃ is the "fixer" in film photography.',
      descriptionAr: 'محلول اليود البني يصبح عديم اللون! Na₂S₂O₃ هو "المثبت" في التصوير الفوتوغرافي.',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0x44F5F5F5), 0.8)],
    ),

    // #70 — Na₂S₂O₃ + HCl (yellow sulfur!)
    ChemReaction(
      reagentIds: {'sodium_thiosulfate', 'hcl'}, resultColor: const Color(0xBBFFEE58),
      name: 'Sulfur Precipitation', nameAr: 'ترسيب الكبريت',
      equation: 'Na₂S₂O₃ + 2HCl → 2NaCl + S↓ + SO₂↑ + H₂O',
      bubbleIntensity: 0.3, heatIntensity: 0.1,
      description: 'Solution turns milky yellow as sulfur precipitates! SO₂ gas also releases. Used to study reaction rates.',
      descriptionAr: 'المحلول يتعكر بأصفر حليبي من ترسب الكبريت! يُستخدم لدراسة سرعة التفاعل.',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xBBFFEE58), 0.6), EffectLayer(ReactionEffect.smoke, Color(0x889E9E9E), 0.4)],
    ),

    // #71 — H₂O₂ + KI (elephant toothpaste v2!)
    ChemReaction(
      reagentIds: {'hydrogen_peroxide', 'potassium_iodide'}, resultColor: const Color(0xBB8D6E63),
      name: 'Catalyzed Peroxide Decomposition', nameAr: 'تحلل فوق الأكسيد المحفز',
      equation: '2H₂O₂ →[KI] 2H₂O + O₂↑',
      bubbleIntensity: 0.75, heatIntensity: 0.3,
      description: '🧪 KI catalyzes H₂O₂ breakdown. Solution turns brown from I₂. Rapid O₂ foam eruption!',
      descriptionAr: '🧪 KI يحفز تحلل H₂O₂. المحلول يتحول بني من I₂. انفجار رغوي سريع من O₂!',
      effects: [EffectLayer(ReactionEffect.foam, Color(0xBB8D6E63), 0.7), EffectLayer(ReactionEffect.gasRelease, Color(0x77FFFFFF), 0.7), EffectLayer(ReactionEffect.colorWave, Color(0xBB8D6E63), 0.5)],
    ),

    // #72 — Cu + HNO₃ (blue + brown gas!)
    ChemReaction(
      reagentIds: {'copper_metal', 'hno3'}, resultColor: const Color(0xBB42A5F5),
      name: 'Copper + Nitric Acid', nameAr: 'نحاس + حمض النيتريك',
      equation: '3Cu + 8HNO₃(dilute) → 3Cu(NO₃)₂ + 2NO↑ + 4H₂O',
      bubbleIntensity: 0.4, heatIntensity: 0.5,
      description: 'Copper dissolves to blue Cu(NO₃)₂. Brown NO₂ fumes. Copper doesn\'t react with HCl — only HNO₃!',
      descriptionAr: 'النحاس يذوب لمحلول أزرق Cu(NO₃)₂. أبخرة NO₂ بنية. النحاس لا يتفاعل مع HCl!',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0xBB42A5F5), 0.7), EffectLayer(ReactionEffect.smoke, Color(0xAA8D6E63), 0.6, 1.1)],
    ),

    // #73 — KMnO₄ + FeSO₄ (purple → pale!)
    ChemReaction(
      reagentIds: {'potassium_permanganate', 'iron_ii_sulfate'}, resultColor: const Color(0x88FFCC80),
      name: 'Permanganate + Iron(II) Titration', nameAr: 'معايرة البرمنغنات + الحديد II',
      equation: '2KMnO₄ + 10FeSO₄ + 8H₂SO₄ → 2MnSO₄ + 5Fe₂(SO₄)₃ + K₂SO₄ + 8H₂O',
      bubbleIntensity: 0.0, heatIntensity: 0.1,
      description: '🟣→🟡 Purple permanganate decolorizes as Fe²⁺ is oxidized to Fe³⁺. Classic titration!',
      descriptionAr: '🟣→🟡 البرمنغنات البنفسجية تفقد لونها عند أكسدة Fe²⁺ إلى Fe³⁺. معايرة كلاسيكية!',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0x88FFCC80), 0.8)],
    ),

    // #74 — KMnO₄ + HCl (chlorine gas!)
    ChemReaction(
      reagentIds: {'potassium_permanganate', 'hcl'}, resultColor: const Color(0x88C8E6C9),
      name: 'Permanganate + HCl', nameAr: 'برمنغنات + حمض الهيدروكلوريك',
      equation: '2KMnO₄ + 16HCl → 2MnCl₂ + 2KCl + 5Cl₂↑ + 8H₂O',
      bubbleIntensity: 0.35, heatIntensity: 0.2,
      description: 'Purple decolorizes. Produces greenish-yellow chlorine gas! ⚠️ Toxic — fan required!',
      descriptionAr: 'البنفسجي يزول. ينتج غاز الكلور الأصفر المخضر! ⚠️ سام — يحتاج تهوية!',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0x88C8E6C9), 0.6), EffectLayer(ReactionEffect.smoke, Color(0xAAC5E1A5), 0.5)],
    ),

    // #75 — CuO + HCl → blue-green CuCl₂!
    ChemReaction(
      reagentIds: {'copper_oxide', 'hcl'}, resultColor: const Color(0xBB26A69A),
      name: 'Copper Oxide + HCl', nameAr: 'أكسيد النحاس + حمض الهيدروكلوريك',
      equation: 'CuO + 2HCl → CuCl₂ + H₂O',
      bubbleIntensity: 0.1, heatIntensity: 0.2,
      description: 'Black powder dissolves to produce a beautiful blue-green solution of copper chloride!',
      descriptionAr: 'المسحوق الأسود يذوب منتجاً محلولاً أزرق مخضراً جميلاً من كلوريد النحاس!',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0xBB26A69A), 0.7)],
    ),

    // #76 — CuO + H₂SO₄ → blue CuSO₄!
    ChemReaction(
      reagentIds: {'copper_oxide', 'h2so4'}, resultColor: const Color(0xBB1E88E5),
      name: 'Copper Oxide + Sulfuric Acid', nameAr: 'أكسيد النحاس + حمض الكبريتيك',
      equation: 'CuO + H₂SO₄ → CuSO₄ + H₂O',
      bubbleIntensity: 0.1, heatIntensity: 0.2,
      description: 'Black CuO dissolves in warm acid → beautiful BLUE copper sulfate solution!',
      descriptionAr: 'أكسيد النحاس الأسود يذوب في حمض دافئ → محلول كبريتات النحاس الأزرق الجميل!',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0xBB1E88E5), 0.7)],
    ),

    // ═══════════════════════════════════════════════════════════════
    //  J · OXIDE REACTIONS  (7 reactions)
    // ═══════════════════════════════════════════════════════════════

    // #77 — CaO + H₂O (QUICKLIME — very exothermic! 🔥)
    ChemReaction(
      reagentIds: {'calcium_oxide', 'water'}, resultColor: const Color(0xBBF5F5F5),
      name: 'Quicklime + Water', nameAr: 'جير حي + ماء',
      equation: 'CaO + H₂O → Ca(OH)₂',
      bubbleIntensity: 0.3, heatIntensity: 0.9,
      description: '🔥 EXTREMELY hot! Can reach 300°C! Quicklime + water was used to heat food in ancient times.',
      descriptionAr: '🔥 حار للغاية! قد يصل 300°C! الجير الحي + ماء استُخدم لتسخين الطعام قديماً.',
      effects: [EffectLayer(ReactionEffect.glow, Color(0xFFFF1744), 0.9, 1.3), EffectLayer(ReactionEffect.smoke, Color(0xBBFFFFFF), 0.7, 1.2)],
    ),

    // #78 — MgO + HCl → clear
    ChemReaction(
      reagentIds: {'magnesium_oxide', 'hcl'}, resultColor: const Color(0x77F5F5F5),
      name: 'Magnesium Oxide + HCl', nameAr: 'أكسيد المغنيسيوم + حمض الهيدروكلوريك',
      equation: 'MgO + 2HCl → MgCl₂ + H₂O',
      bubbleIntensity: 0.05, heatIntensity: 0.2,
      description: 'White MgO powder dissolves to a clear solution. Used in antacid medicines!',
      descriptionAr: 'مسحوق MgO الأبيض يذوب لمحلول شفاف. يُستخدم في أدوية الحموضة!',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0x77F5F5F5), 0.4)],
    ),

    // #79 — Fe₂O₃ + HCl (dissolving rust!)
    ChemReaction(
      reagentIds: {'iron_oxide', 'hcl'}, resultColor: const Color(0xBBFF8F00),
      name: 'Dissolving Rust', nameAr: 'إذابة الصدأ',
      equation: 'Fe₂O₃ + 6HCl → 2FeCl₃ + 3H₂O',
      bubbleIntensity: 0.05, heatIntensity: 0.2,
      description: 'Red-brown rust dissolves in acid! Produces yellow-brown iron(III) chloride solution.',
      descriptionAr: 'الصدأ البني المحمر يذوب في الحمض! ينتج محلول كلوريد الحديد III الأصفر البني.',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0xBBFF8F00), 0.6)],
    ),

    // #80 — CaO + HCl
    ChemReaction(
      reagentIds: {'calcium_oxide', 'hcl'}, resultColor: const Color(0x88F5F5F5),
      name: 'Quicklime + HCl', nameAr: 'جير حي + حمض الهيدروكلوريك',
      equation: 'CaO + 2HCl → CaCl₂ + H₂O',
      bubbleIntensity: 0.1, heatIntensity: 0.35,
      description: 'Quicklime reacts exothermically with HCl. Produces calcium chloride (de-icing salt!).',
      descriptionAr: 'الجير الحي يتفاعل مع الحمض بحرارة. ينتج كلوريد الكالسيوم (ملح مذيب الجليد!).',
      effects: [EffectLayer(ReactionEffect.glow, Color(0xFFFF6D00), 0.3), EffectLayer(ReactionEffect.smoke, Color(0x66FFFFFF), 0.3)],
    ),

    // #81 — MgO + H₂SO₄
    ChemReaction(
      reagentIds: {'magnesium_oxide', 'h2so4'}, resultColor: const Color(0x77F5F5F5),
      name: 'Magnesium Oxide + Sulfuric Acid', nameAr: 'أكسيد المغنيسيوم + حمض الكبريتيك',
      equation: 'MgO + H₂SO₄ → MgSO₄ + H₂O',
      bubbleIntensity: 0.05, heatIntensity: 0.2,
      description: 'Produces Epsom salt (MgSO₄)! Used in bath soaks and gardening.',
      descriptionAr: 'ينتج ملح إبسوم (MgSO₄)! يُستخدم في حمامات الاسترخاء والزراعة.',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0x77F5F5F5), 0.4)],
    ),

    // #82 — Fe₂O₃ + H₂SO₄
    ChemReaction(
      reagentIds: {'iron_oxide', 'h2so4'}, resultColor: const Color(0xBBFFAB40),
      name: 'Rust + Sulfuric Acid', nameAr: 'صدأ + حمض الكبريتيك',
      equation: 'Fe₂O₃ + 3H₂SO₄ → Fe₂(SO₄)₃ + 3H₂O',
      bubbleIntensity: 0.05, heatIntensity: 0.25,
      description: 'Industrial rust removal! Produces iron(III) sulfate — a water treatment chemical.',
      descriptionAr: 'إزالة الصدأ صناعياً! ينتج كبريتات الحديد III — مادة كيميائية لمعالجة المياه.',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0xBBFFAB40), 0.6)],
    ),

    // #83 — CaO + H₂SO₄
    ChemReaction(
      reagentIds: {'calcium_oxide', 'h2so4'}, resultColor: const Color(0xBBF5F5F5),
      name: 'Quicklime + Sulfuric Acid', nameAr: 'جير حي + حمض الكبريتيك',
      equation: 'CaO + H₂SO₄ → CaSO₄ + H₂O',
      bubbleIntensity: 0.1, heatIntensity: 0.4,
      description: 'Produces gypsum (CaSO₄) — used in plaster of Paris, drywall, and dentistry!',
      descriptionAr: 'ينتج الجبس (CaSO₄) — يُستخدم في الجبيرة وألواح الجدران وطب الأسنان!',
      effects: [EffectLayer(ReactionEffect.glow, Color(0xFFFF6D00), 0.35), EffectLayer(ReactionEffect.precipitate, Color(0xBBF5F5F5), 0.4)],
    ),

    // ═══════════════════════════════════════════════════════════════
    //  K · SPECIAL & MIXED REACTIONS  (17 reactions)
    // ═══════════════════════════════════════════════════════════════

    // #84 — NH₄Cl + Ba(OH)₂ (ENDOTHERMIC — gets COLD! 🥶)
    ChemReaction(
      reagentIds: {'ammonium_chloride', 'ba_oh_2'}, resultColor: const Color(0x88B3E5FC),
      name: 'Endothermic Cold Pack', nameAr: 'تفاعل ماص للحرارة (يبرد!)',
      equation: '2NH₄Cl + Ba(OH)₂ → BaCl₂ + 2NH₃↑ + 2H₂O',
      bubbleIntensity: 0.3, heatIntensity: 0.0,
      description: '🥶 Gets FREEZING COLD! Temperature drops below 0°C! This is how instant cold packs work!',
      descriptionAr: '🥶 يصبح بارداً جداً! الحرارة تنخفض تحت الصفر! هكذا تعمل أكياس التبريد الفورية!',
      effects: [EffectLayer(ReactionEffect.frost, Color(0xBB42A5F5), 0.9, 1.3)],
    ),

    // #85 — Ethanol + Sodium
    ChemReaction(
      reagentIds: {'ethanol', 'sodium'}, resultColor: const Color(0x88FFF9C4),
      name: 'Ethanol + Sodium', nameAr: 'إيثانول + صوديوم',
      equation: '2C₂H₅OH + 2Na → 2C₂H₅ONa + H₂↑',
      bubbleIntensity: 0.4, heatIntensity: 0.3,
      description: 'Sodium dissolves in ethanol producing hydrogen. Gentler than water — proves ethanol has an -OH group!',
      descriptionAr: 'الصوديوم يذوب في الإيثانول منتجاً الهيدروجين. أهدأ من الماء — يثبت وجود OH في الإيثانول!',
      effects: [EffectLayer(ReactionEffect.gasRelease, Color(0x55FFFFFF), 0.4), EffectLayer(ReactionEffect.flame, Color(0xFFFFD740), 0.3, 0.5)],
    ),

    // #86 — Al + NaOH (AMPHOTERIC! 🤯)
    ChemReaction(
      reagentIds: {'aluminum', 'naoh'}, resultColor: const Color(0x88E0E0E0),
      name: 'Aluminum + Sodium Hydroxide', nameAr: 'ألومنيوم + هيدروكسيد الصوديوم',
      equation: '2Al + 2NaOH + 2H₂O → 2NaAlO₂ + 3H₂↑',
      bubbleIntensity: 0.55, heatIntensity: 0.4,
      description: '🤯 Aluminum reacts with BASE! Most metals don\'t do this. Al is amphoteric — reacts with acids AND bases!',
      descriptionAr: '🤯 الألومنيوم يتفاعل مع القاعدة! معظم الفلزات لا تفعل هذا. Al مذبذب — يتفاعل مع الأحماض والقواعد!',
      effects: [EffectLayer(ReactionEffect.gasRelease, Color(0x77FFFFFF), 0.55), EffectLayer(ReactionEffect.glow, Color(0xFFFFCC80), 0.35)],
    ),

    // #87 — Zn + NaOH (also amphoteric!)
    ChemReaction(
      reagentIds: {'zinc', 'naoh'}, resultColor: const Color(0x88E0E0E0),
      name: 'Zinc + Sodium Hydroxide', nameAr: 'خارصين + هيدروكسيد الصوديوم',
      equation: 'Zn + 2NaOH → Na₂ZnO₂ + H₂↑',
      bubbleIntensity: 0.4, heatIntensity: 0.3,
      description: 'Zinc also reacts with NaOH! Another amphoteric metal. Important in battery chemistry.',
      descriptionAr: 'الزنك أيضاً يتفاعل مع NaOH! فلز مذبذب آخر. مهم في كيمياء البطاريات.',
      effects: [EffectLayer(ReactionEffect.gasRelease, Color(0x55FFFFFF), 0.4), EffectLayer(ReactionEffect.glow, Color(0xFFFFCC80), 0.25)],
    ),

    // #88 — Na₂CO₃ + Ca(OH)₂ (causticization!)
    ChemReaction(
      reagentIds: {'sodium_carbonate', 'ca_oh_2'}, resultColor: const Color(0xBBEEEEEE),
      name: 'Causticization', nameAr: 'عملية القلونة',
      equation: 'Na₂CO₃ + Ca(OH)₂ → CaCO₃↓ + 2NaOH',
      bubbleIntensity: 0.0, heatIntensity: 0.1,
      description: 'Industrial process! Converts cheap Na₂CO₃ to valuable NaOH. White CaCO₃ precipitate.',
      descriptionAr: 'عملية صناعية! تحويل Na₂CO₃ الرخيص إلى NaOH القيّم. راسب أبيض من CaCO₃.',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xBBEEEEEE), 0.6), EffectLayer(ReactionEffect.colorWave, Color(0x88EEEEEE), 0.3)],
    ),

    // #89 — H₂SO₄ + BaCl₂ (sulfate test!)
    ChemReaction(
      reagentIds: {'h2so4', 'barium_chloride'}, resultColor: const Color(0xDDF5F5F5),
      name: 'Sulfate Ion Test', nameAr: 'اختبار أيون الكبريتات',
      equation: 'H₂SO₄ + BaCl₂ → BaSO₄↓ + 2HCl',
      bubbleIntensity: 0.0, heatIntensity: 0.1,
      description: 'Instant white precipitate confirms sulfate ions! Standard analytical chemistry test.',
      descriptionAr: 'راسب أبيض فوري يؤكد وجود أيونات الكبريتات! اختبار تحليلي قياسي.',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0xDDF5F5F5), 0.7, 1.1), EffectLayer(ReactionEffect.colorWave, Color(0x88F5F5F5), 0.4)],
    ),

    // #90 — CaCO₃ + H₂SO₄ (slow fizz, coats!)
    ChemReaction(
      reagentIds: {'calcium_carbonate', 'h2so4'}, resultColor: const Color(0x88F5F5F5),
      name: 'Limestone + Sulfuric Acid', nameAr: 'حجر جيري + حمض الكبريتيك',
      equation: 'CaCO₃ + H₂SO₄ → CaSO₄ + H₂O + CO₂↑',
      bubbleIntensity: 0.4, heatIntensity: 0.15,
      description: 'Slow! CaSO₄ layer forms on surface, blocking further reaction. Unlike HCl which dissolves completely.',
      descriptionAr: 'بطيء! طبقة CaSO₄ تتكون على السطح وتوقف التفاعل. بعكس HCl الذي يذيب بالكامل.',
      effects: [EffectLayer(ReactionEffect.foam, Color(0x77FFFFFF), 0.35), EffectLayer(ReactionEffect.precipitate, Color(0x88F5F5F5), 0.4)],
    ),

    // #91 — NaHCO₃ + HCl (fizzy!)
    ChemReaction(
      reagentIds: {'baking_soda', 'hcl'}, resultColor: const Color(0x88E0E0E0),
      name: 'Baking Soda + HCl', nameAr: 'بيكربونات الصوديوم + حمض الهيدروكلوريك',
      equation: 'NaHCO₃ + HCl → NaCl + H₂O + CO₂↑',
      bubbleIntensity: 0.7, heatIntensity: 0.1,
      description: 'Rapid fizzing! This is how antacid tablets work in your stomach (HCl is stomach acid!).',
      descriptionAr: 'فوران سريع! هكذا تعمل أقراص مضادات الحموضة في معدتك (HCl هو حمض المعدة!).',
      effects: [EffectLayer(ReactionEffect.foam, Color(0xBBFFFFFF), 0.65), EffectLayer(ReactionEffect.gasRelease, Color(0x88FFFFFF), 0.6)],
    ),

    // #92 — H₂O₂ + FeSO₄ (Fenton reaction!)
    ChemReaction(
      reagentIds: {'hydrogen_peroxide', 'iron_ii_sulfate'}, resultColor: const Color(0xBBFF8F00),
      name: 'Fenton Reaction', nameAr: 'تفاعل فنتون',
      equation: '2Fe²⁺ + H₂O₂ + 2H⁺ → 2Fe³⁺ + 2H₂O',
      bubbleIntensity: 0.3, heatIntensity: 0.2,
      description: 'Green Fe²⁺ → brown Fe³⁺. Fenton\'s reagent generates OH radicals — used in water treatment!',
      descriptionAr: 'أخضر Fe²⁺ → بني Fe³⁺. كاشف فنتون يولّد جذور OH — يُستخدم في معالجة المياه!',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0xBBFF8F00), 0.6), EffectLayer(ReactionEffect.gasRelease, Color(0x55FFFFFF), 0.3)],
    ),

    // #93 — CaCl₂ + NaHCO₃ (double action!)
    ChemReaction(
      reagentIds: {'calcium_chloride', 'baking_soda'}, resultColor: const Color(0xBBEEEEEE),
      name: 'Calcium Chloride + Baking Soda', nameAr: 'كلوريد الكالسيوم + بيكربونات الصوديوم',
      equation: 'CaCl₂ + 2NaHCO₃ → CaCO₃↓ + 2NaCl + H₂O + CO₂↑',
      bubbleIntensity: 0.45, heatIntensity: 0.1,
      description: 'Double feature: white CaCO₃ precipitate AND CO₂ bubbles! Precipitation + gas release.',
      descriptionAr: 'مزدوج: راسب أبيض CaCO₃ وفقاعات CO₂! يجمع بين الترسيب وإنتاج الغاز.',
      effects: [EffectLayer(ReactionEffect.precipitate, Color(0x88EEEEEE), 0.4), EffectLayer(ReactionEffect.foam, Color(0x77FFFFFF), 0.4), EffectLayer(ReactionEffect.gasRelease, Color(0x55FFFFFF), 0.4)],
    ),

    // #94 — CuSO₄ + KI (Cu²⁺ oxidizes I⁻!)
    ChemReaction(
      reagentIds: {'copper', 'potassium_iodide'}, resultColor: const Color(0xBB8D6E63),
      name: 'Copper Sulfate + Potassium Iodide', nameAr: 'كبريتات النحاس + يوديد البوتاسيوم',
      equation: '2CuSO₄ + 4KI → 2CuI↓ + I₂ + 2K₂SO₄',
      bubbleIntensity: 0.0, heatIntensity: 0.1,
      description: 'Blue → Brown! Cu²⁺ oxidizes I⁻ to I₂ (brown). White CuI precipitate hides underneath.',
      descriptionAr: 'أزرق → بني! Cu²⁺ يؤكسد I⁻ إلى I₂ (بني). راسب CuI الأبيض يختبئ تحته.',
      effects: [EffectLayer(ReactionEffect.colorWave, Color(0xBB8D6E63), 0.7), EffectLayer(ReactionEffect.precipitate, Color(0x88F5F5F5), 0.4)],
    ),

    // #95 — Vinegar + Na₂CO₃ (CO₂ fizz!)
    ChemReaction(
      reagentIds: {'vinegar', 'sodium_carbonate'}, resultColor: const Color(0x88FFF9C4),
      name: 'Vinegar + Sodium Carbonate', nameAr: 'خل + كربونات الصوديوم',
      equation: '2CH₃COOH + Na₂CO₃ → 2CH₃COONa + H₂O + CO₂↑',
      bubbleIntensity: 0.6, heatIntensity: 0.05,
      description: 'Gentle fizzing. CO₂ released. Washing soda reacts with any acid including vinegar.',
      descriptionAr: 'فوران لطيف. CO₂ يتحرر. صودا الغسيل تتفاعل مع أي حمض بما فيه الخل.',
      effects: [EffectLayer(ReactionEffect.foam, Color(0x88FFFFFF), 0.5), EffectLayer(ReactionEffect.gasRelease, Color(0x55FFFFFF), 0.5)],
    ),

    // #96 — H₃PO₄ + KOH
    ChemReaction(
      reagentIds: {'h3po4', 'koh'}, resultColor: const Color(0x88E8F5E9),
      name: 'Phosphoric Acid + KOH', nameAr: 'حمض الفوسفوريك + هيدروكسيد البوتاسيوم',
      equation: 'H₃PO₄ + 3KOH → K₃PO₄ + 3H₂O',
      bubbleIntensity: 0.1, heatIntensity: 0.3,
      description: 'Produces potassium phosphate — one of the most important fertilizer compounds worldwide!',
      descriptionAr: 'ينتج فوسفات البوتاسيوم — من أهم مركبات الأسمدة في العالم!',
      effects: [EffectLayer(ReactionEffect.glow, Color(0xFF26A69A), 0.3), EffectLayer(ReactionEffect.colorWave, Color(0x88E8F5E9), 0.3)],
    ),

    // #97 — Vinegar + Zinc (slow fizz)
    ChemReaction(
      reagentIds: {'vinegar', 'zinc'}, resultColor: const Color(0x88F5F5F5),
      name: 'Vinegar + Zinc', nameAr: 'خل + خارصين',
      equation: 'Zn + 2CH₃COOH → Zn(CH₃COO)₂ + H₂↑',
      bubbleIntensity: 0.3, heatIntensity: 0.1,
      description: 'Slow fizz. Zinc dissolves in weak acetic acid producing zinc acetate and hydrogen.',
      descriptionAr: 'فوران بطيء. الزنك يذوب في حمض الخليك الضعيف منتجاً خلات الزنك وهيدروجين.',
      effects: [EffectLayer(ReactionEffect.gasRelease, Color(0x44FFFFFF), 0.3)],
    ),

    // #98 — Mg + HNO₃
    ChemReaction(
      reagentIds: {'magnesium', 'hno3'}, resultColor: const Color(0x88F5F5F5),
      name: 'Magnesium + Nitric Acid', nameAr: 'مغنيسيوم + حمض النيتريك',
      equation: 'Mg + 2HNO₃(dilute) → Mg(NO₃)₂ + H₂↑',
      bubbleIntensity: 0.6, heatIntensity: 0.45,
      description: 'Vigorous! Magnesium sparks and fizzes in dilute HNO₃. Produces magnesium nitrate.',
      descriptionAr: 'قوي! المغنيسيوم يشرر ويفور في HNO₃ المخفف. ينتج نترات المغنيسيوم.',
      effects: [EffectLayer(ReactionEffect.gasRelease, Color(0x88FFFFFF), 0.6, 1.1), EffectLayer(ReactionEffect.sparks, Color(0xFFE0E0E0), 0.4), EffectLayer(ReactionEffect.glow, Color(0xFFFF8A65), 0.4)],
    ),

    // #99 — Zinc + HNO₃ (dilute)
    ChemReaction(
      reagentIds: {'zinc', 'hno3'}, resultColor: const Color(0x88F5F5F5),
      name: 'Zinc + Nitric Acid', nameAr: 'خارصين + حمض النيتريك',
      equation: '4Zn + 10HNO₃(dilute) → 4Zn(NO₃)₂ + NH₄NO₃ + 3H₂O',
      bubbleIntensity: 0.35, heatIntensity: 0.3,
      description: 'With dilute HNO₃, zinc produces ammonium nitrate instead of H₂! Unusual product!',
      descriptionAr: 'مع HNO₃ المخفف، الزنك ينتج نترات الأمونيوم بدل H₂! نتاج غير معتاد!',
      effects: [EffectLayer(ReactionEffect.gasRelease, Color(0x66FFFFFF), 0.35), EffectLayer(ReactionEffect.colorWave, Color(0x88F5F5F5), 0.3)],
    ),

    // #100 — Magnesium + Steam/Hot Water
    ChemReaction(
      reagentIds: {'magnesium', 'water'}, resultColor: const Color(0xBBF5F5F5),
      name: 'Magnesium + Water', nameAr: 'مغنيسيوم + ماء',
      equation: 'Mg + 2H₂O → Mg(OH)₂ + H₂↑',
      bubbleIntensity: 0.35, heatIntensity: 0.25,
      description: 'Very slow with cold water. With steam, magnesium burns brightly producing MgO!',
      descriptionAr: 'بطيء جداً مع الماء البارد. مع البخار، المغنيسيوم يحترق بلمعان خاطف منتجاً MgO!',
      effects: [EffectLayer(ReactionEffect.gasRelease, Color(0x55FFFFFF), 0.3), EffectLayer(ReactionEffect.glow, Color(0xFFFFCC80), 0.2)],
    ),
  ];

  // ─────────────────────────────────────────────────────────────────
  //  SUPPORTED REACTION NAMES (for AI prompt)
  // ─────────────────────────────────────────────────────────────────

  /// Compact list of all supported reaction names for embedding in AI prompts.
  static const List<String> supportedReactionNamesAr = [
    'صوديوم + ماء', 'بوتاسيوم + ماء', 'ليثيوم + ماء', 'كالسيوم + ماء',
    'بيروكسيد الصوديوم + ماء', 'حديد + حمض هيدروكلوريك', 'مغنيسيوم + حمض هيدروكلوريك',
    'زنك + حمض هيدروكلوريك', 'ألومنيوم + حمض هيدروكلوريك', 'قصدير + حمض هيدروكلوريك',
    'مغنيسيوم + حمض كبريتيك', 'زنك + حمض كبريتيك', 'حديد + حمض كبريتيك',
    'ألومنيوم + حمض كبريتيك', 'قصدير + حمض كبريتيك',
    'حمض هيدروكلوريك + هيدروكسيد صوديوم', 'حمض كبريتيك + هيدروكسيد صوديوم',
    'حمض نيتريك + هيدروكسيد بوتاسيوم', 'خل + هيدروكسيد صوديوم',
    'حمض هيدروكلوريك + هيدروكسيد بوتاسيوم', 'حمض كبريتيك + ماء الجير',
    'حمض هيدروكلوريك + أمونيا', 'حمض فوسفوريك + هيدروكسيد صوديوم',
    'حمض كبريتيك + هيدروكسيد بوتاسيوم', 'حمض نيتريك + هيدروكسيد صوديوم',
    'حديد + كبريتات نحاس', 'زنك + كبريتات نحاس', 'مغنيسيوم + كبريتات نحاس',
    'نحاس + نترات فضة', 'حديد + نترات فضة', 'زنك + كبريتات حديد',
    'زنك + نترات رصاص', 'ألومنيوم + كبريتات نحاس',
    'كلوريد صوديوم + نترات فضة', 'كلوريد باريوم + كبريتات صوديوم',
    'نترات رصاص + يوديد بوتاسيوم (المطر الذهبي)', 'كلوريد حديد III + هيدروكسيد صوديوم',
    'كبريتات نحاس + هيدروكسيد صوديوم', 'كبريتات حديد II + هيدروكسيد صوديوم',
    'كبريتات نحاس + كبريتيد صوديوم', 'نترات رصاص + كبريتيد صوديوم',
    'نترات فضة + يوديد بوتاسيوم', 'كلوريد كالسيوم + كربونات صوديوم',
    'نترات رصاص + كلوريد صوديوم', 'كلوريد حديد III + ثيوسيانات بوتاسيوم',
    'كبريتات نحاس + كلوريد باريوم', 'نترات فضة + بروميد صوديوم',
    'هيدروكسيد باريوم + حمض كبريتيك',
    'خل + بيكربونات صوديوم', 'حمض هيدروكلوريك + كربونات صوديوم',
    'حمض هيدروكلوريك + كربونات كالسيوم', 'حمض كبريتيك + كربونات صوديوم',
    'بيروكسيد هيدروجين + ثاني أكسيد المنغنيز (معجون الفيل)',
    'كلوريد أمونيوم + هيدروكسيد صوديوم', 'حمض هيدروكلوريك + كبريتيد صوديوم',
    'حمض كبريتيك + كبريتيت صوديوم', 'خل + كربونات كالسيوم',
    'حمض نيتريك + كربونات كالسيوم',
    'فينولفثالين + قاعدة', 'فينولفثالين + حمض', 'عباد الشمس + حمض', 'عباد الشمس + قاعدة',
    'ميثيل برتقال + حمض', 'ميثيل برتقال + قاعدة', 'كاشف عام + حمض', 'كاشف عام + قاعدة',
    'برمنغنات بوتاسيوم + بيروكسيد هيدروجين', 'نشا + يود',
    'ثيوكبريتات صوديوم + يود', 'ثيوكبريتات صوديوم + حمض هيدروكلوريك',
    'بيروكسيد هيدروجين + يوديد بوتاسيوم', 'نحاس + حمض نيتريك',
    'برمنغنات بوتاسيوم + كبريتات حديد II', 'برمنغنات بوتاسيوم + حمض هيدروكلوريك',
    'أكسيد نحاس + حمض هيدروكلوريك', 'أكسيد نحاس + حمض كبريتيك',
    'جير حي + ماء', 'أكسيد مغنيسيوم + حمض هيدروكلوريك',
    'صدأ + حمض هيدروكلوريك', 'جير حي + حمض هيدروكلوريك',
    'أكسيد مغنيسيوم + حمض كبريتيك', 'صدأ + حمض كبريتيك', 'جير حي + حمض كبريتيك',
    'كلوريد أمونيوم + هيدروكسيد باريوم (يبرد!)',
    'إيثانول + صوديوم', 'ألومنيوم + هيدروكسيد صوديوم', 'زنك + هيدروكسيد صوديوم',
    'كربونات صوديوم + هيدروكسيد كالسيوم', 'حمض كبريتيك + كلوريد باريوم',
    'كربونات كالسيوم + حمض كبريتيك', 'بيكربونات صوديوم + حمض هيدروكلوريك',
    'بيروكسيد هيدروجين + كبريتات حديد II (فنتون)', 'كلوريد كالسيوم + بيكربونات صوديوم',
    'كبريتات نحاس + يوديد بوتاسيوم', 'خل + كربونات صوديوم',
    'حمض فوسفوريك + هيدروكسيد بوتاسيوم', 'خل + زنك',
    'مغنيسيوم + حمض نيتريك', 'زنك + حمض نيتريك', 'مغنيسيوم + ماء',
  ];

  static const List<String> supportedReactionNamesEn = [
    'Sodium + Water', 'Potassium + Water', 'Lithium + Water', 'Calcium + Water',
    'Sodium Peroxide + Water', 'Iron + HCl', 'Magnesium + HCl', 'Zinc + HCl',
    'Aluminum + HCl', 'Tin + HCl', 'Magnesium + Sulfuric Acid', 'Zinc + Sulfuric Acid',
    'Iron + Sulfuric Acid', 'Aluminum + Sulfuric Acid', 'Tin + Sulfuric Acid',
    'HCl + NaOH', 'Sulfuric Acid + NaOH', 'Nitric Acid + KOH', 'Vinegar + NaOH',
    'HCl + KOH', 'Sulfuric Acid + Lime Water', 'HCl + Ammonia', 'Phosphoric Acid + NaOH',
    'Sulfuric Acid + KOH', 'Nitric Acid + NaOH',
    'Iron + Copper Sulfate', 'Zinc + Copper Sulfate', 'Magnesium + Copper Sulfate',
    'Copper + Silver Nitrate', 'Iron + Silver Nitrate', 'Zinc + Iron Sulfate',
    'Zinc + Lead Nitrate', 'Aluminum + Copper Sulfate',
    'NaCl + Silver Nitrate', 'Barium Chloride + Sodium Sulfate',
    'Lead Nitrate + Potassium Iodide (Golden Rain)', 'Iron(III) Chloride + NaOH',
    'Copper Sulfate + NaOH', 'Iron(II) Sulfate + NaOH', 'Copper Sulfate + Sodium Sulfide',
    'Lead Nitrate + Sodium Sulfide', 'Silver Nitrate + Potassium Iodide',
    'Calcium Chloride + Sodium Carbonate', 'Lead Nitrate + NaCl',
    'Iron(III) Chloride + Potassium Thiocyanate (Blood Red)',
    'Copper Sulfate + Barium Chloride', 'Silver Nitrate + Sodium Bromide',
    'Barium Hydroxide + Sulfuric Acid',
    'Vinegar + Baking Soda', 'HCl + Sodium Carbonate', 'HCl + Limestone',
    'Sulfuric Acid + Sodium Carbonate', 'Hydrogen Peroxide + MnO₂ (Elephant Toothpaste)',
    'Ammonium Chloride + NaOH', 'HCl + Sodium Sulfide', 'Sulfuric Acid + Sodium Sulfite',
    'Vinegar + Eggshell/Chalk', 'Nitric Acid + Limestone',
    'Phenolphthalein + Base', 'Phenolphthalein + Acid', 'Litmus + Acid', 'Litmus + Base',
    'Methyl Orange + Acid', 'Methyl Orange + Base', 'Universal Indicator + Acid',
    'Universal Indicator + Base',
    'KMnO₄ + Hydrogen Peroxide', 'Starch + Iodine', 'Sodium Thiosulfate + Iodine',
    'Sodium Thiosulfate + HCl', 'Hydrogen Peroxide + Potassium Iodide',
    'Copper + Nitric Acid', 'KMnO₄ + Iron(II) Sulfate', 'KMnO₄ + HCl',
    'Copper Oxide + HCl', 'Copper Oxide + Sulfuric Acid',
    'Quicklime + Water', 'Magnesium Oxide + HCl', 'Dissolving Rust', 'Quicklime + HCl',
    'Magnesium Oxide + Sulfuric Acid', 'Rust + Sulfuric Acid', 'Quicklime + Sulfuric Acid',
    'Ammonium Chloride + Barium Hydroxide (Endothermic!)',
    'Ethanol + Sodium', 'Aluminum + NaOH (Amphoteric)', 'Zinc + NaOH (Amphoteric)',
    'Sodium Carbonate + Lime Water', 'Sulfuric Acid + Barium Chloride',
    'Limestone + Sulfuric Acid', 'Baking Soda + HCl', 'Fenton Reaction',
    'Calcium Chloride + Baking Soda', 'Copper Sulfate + Potassium Iodide',
    'Vinegar + Sodium Carbonate', 'Phosphoric Acid + KOH', 'Vinegar + Zinc',
    'Magnesium + Nitric Acid', 'Zinc + Nitric Acid', 'Magnesium + Water',
  ];
}
