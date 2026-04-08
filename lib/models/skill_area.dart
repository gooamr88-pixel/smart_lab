/// Predefined skill areas, badges, and XP configuration
class SkillAreas {
  SkillAreas._();

  // ─── Physics Skills ───
  static const String mechanics = 'mechanics';
  static const String thermodynamics = 'thermodynamics';
  static const String waves = 'waves';
  static const String electricity = 'electricity';
  static const String optics = 'optics';

  // ─── Chemistry Skills ───
  static const String organicChem = 'organic_chemistry';
  static const String inorganicChem = 'inorganic_chemistry';
  static const String acidBase = 'acid_base';
  static const String electroChem = 'electro_chemistry';
  static const String stoichiometry = 'stoichiometry';

  static const List<String> physicsSkills = [
    mechanics,
    thermodynamics,
    waves,
    electricity,
    optics,
  ];

  static const List<String> chemistrySkills = [
    organicChem,
    inorganicChem,
    acidBase,
    electroChem,
    stoichiometry,
  ];

  static const Map<String, String> skillNamesAr = {
    mechanics: 'الميكانيكا',
    thermodynamics: 'الديناميكا الحرارية',
    waves: 'الموجات',
    electricity: 'الكهرباء',
    optics: 'البصريات',
    organicChem: 'الكيمياء العضوية',
    inorganicChem: 'الكيمياء غير العضوية',
    acidBase: 'الأحماض والقواعد',
    electroChem: 'الكيمياء الكهربية',
    stoichiometry: 'الحسابات الكيميائية',
  };

  static const Map<String, String> skillNamesEn = {
    mechanics: 'Mechanics',
    thermodynamics: 'Thermodynamics',
    waves: 'Waves',
    electricity: 'Electricity',
    optics: 'Optics',
    organicChem: 'Organic Chemistry',
    inorganicChem: 'Inorganic Chemistry',
    acidBase: 'Acid & Base',
    electroChem: 'Electrochemistry',
    stoichiometry: 'Stoichiometry',
  };

  static String getName(String skillId, bool isArabic) {
    return isArabic
        ? (skillNamesAr[skillId] ?? skillId)
        : (skillNamesEn[skillId] ?? skillId);
  }
}

/// XP rewards for different actions
class XpRewards {
  XpRewards._();

  static const int correctAnswer = 25;
  static const int wrongAnswer = 5;       // still get some XP for trying
  static const int completedQuiz = 50;
  static const int perfectQuiz = 100;
  static const int simulationComplete = 40;
  static const int experimentComplete = 60;
  static const int aiQuestion = 10;
  static const int diagnosticComplete = 75;
  static const int dailyLogin = 15;
}

/// Badge definitions
class BadgeDefinition {
  final String id;
  final String nameAr;
  final String nameEn;
  final String emoji;
  final String descAr;
  final String descEn;

  const BadgeDefinition({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.emoji,
    required this.descAr,
    required this.descEn,
  });
}

class Badges {
  Badges._();

  static const List<BadgeDefinition> all = [
    BadgeDefinition(
      id: 'first_experiment',
      nameAr: 'أول تجربة',
      nameEn: 'First Experiment',
      emoji: '🧪',
      descAr: 'أكمل أول تجربة في المعمل',
      descEn: 'Complete your first lab experiment',
    ),
    BadgeDefinition(
      id: 'lab_rat',
      nameAr: 'فأر المعمل',
      nameEn: 'Lab Rat',
      emoji: '🐭',
      descAr: 'أكمل 10 تجارب',
      descEn: 'Complete 10 experiments',
    ),
    BadgeDefinition(
      id: 'perfect_score',
      nameAr: 'علامة كاملة',
      nameEn: 'Perfect Score',
      emoji: '💯',
      descAr: '100% في أي اختبار',
      descEn: '100% on any quiz',
    ),
    BadgeDefinition(
      id: 'streak_7',
      nameAr: 'أسبوع متواصل',
      nameEn: '7-Day Streak',
      emoji: '🔥',
      descAr: 'سجل دخول 7 أيام متتالية',
      descEn: 'Login 7 consecutive days',
    ),
    BadgeDefinition(
      id: 'newton_master',
      nameAr: 'سيد قوانين نيوتن',
      nameEn: 'Newton Master',
      emoji: '🏅',
      descAr: 'أكمل كل محاكيات الميكانيكا',
      descEn: 'Complete all mechanics simulations',
    ),
    BadgeDefinition(
      id: 'deep_thinker',
      nameAr: 'مفكر عميق',
      nameEn: 'Deep Thinker',
      emoji: '🧠',
      descAr: 'اسأل الذكاء الاصطناعي 20 سؤال',
      descEn: 'Ask AI 20 questions',
    ),
    BadgeDefinition(
      id: 'sim_explorer',
      nameAr: 'مستكشف المحاكي',
      nameEn: 'Sim Explorer',
      emoji: '⚡',
      descAr: 'أكمل 5 محاكيات',
      descEn: 'Complete 5 simulations',
    ),
    BadgeDefinition(
      id: 'level_5',
      nameAr: 'المستوى الخامس',
      nameEn: 'Level 5',
      emoji: '⭐',
      descAr: 'وصلت للمستوى 5',
      descEn: 'Reached level 5',
    ),
    BadgeDefinition(
      id: 'accuracy_80',
      nameAr: 'دقة عالية',
      nameEn: 'High Accuracy',
      emoji: '🎯',
      descAr: 'نسبة دقة أعلى من 80%',
      descEn: 'Accuracy above 80%',
    ),
    BadgeDefinition(
      id: 'chemistry_hero',
      nameAr: 'بطل الكيمياء',
      nameEn: 'Chemistry Hero',
      emoji: '🧬',
      descAr: 'أكمل 5 تجارب كيمياء',
      descEn: 'Complete 5 chemistry experiments',
    ),
  ];

  static BadgeDefinition? getById(String id) {
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
