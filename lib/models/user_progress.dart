import 'dart:convert';
import 'dart:math' as math;

/// Tracks a user's overall progress, XP, level, streaks, and skill breakdown.
/// Serializable to JSON for SharedPreferences persistence.
class UserProgress {
  int totalXp;
  int level;
  int streak;
  int bestStreak;
  int questionsAnswered;
  int correctAnswers;
  int simulationsCompleted;
  int experimentsCompleted;
  int aiQuestionsAsked;
  bool diagnosticComplete;
  DateTime? lastActiveDate;
  List<String> earnedBadges;
  Map<String, SkillProgress> skills;
  Map<String, int> weakAreas;   // topic → wrong count
  Map<String, int> strongAreas; // topic → correct count
  List<String> activityLog;     // last 30 days: "2026-04-06" format

  UserProgress({
    this.totalXp = 0,
    this.level = 1,
    this.streak = 0,
    this.bestStreak = 0,
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.simulationsCompleted = 0,
    this.experimentsCompleted = 0,
    this.aiQuestionsAsked = 0,
    this.diagnosticComplete = false,
    this.lastActiveDate,
    List<String>? earnedBadges,
    Map<String, SkillProgress>? skills,
    Map<String, int>? weakAreas,
    Map<String, int>? strongAreas,
    List<String>? activityLog,
  })  : earnedBadges = earnedBadges ?? [],
        skills = skills ?? {},
        weakAreas = weakAreas ?? {},
        strongAreas = strongAreas ?? {},
        activityLog = activityLog ?? [];

  /// XP needed for next level: 100 * level^1.5
  int get xpForNextLevel => (100 * _pow15(level)).toInt();

  /// XP earned in current level
  int get currentLevelXp {
    int accumulated = 0;
    for (int i = 1; i < level; i++) {
      accumulated += (100 * _pow15(i)).toInt();
    }
    return totalXp - accumulated;
  }

  /// Progress 0.0–1.0 toward next level
  double get levelProgress {
    final needed = xpForNextLevel;
    if (needed <= 0) return 0;
    return (currentLevelXp / needed).clamp(0.0, 1.0);
  }

  /// Accuracy percentage
  double get accuracy =>
      questionsAnswered > 0 ? correctAnswers / questionsAnswered : 0;

  /// Top 3 weak areas sorted by frequency
  List<MapEntry<String, int>> get topWeaknesses {
    final sorted = weakAreas.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).toList();
  }

  double _pow15(int n) {
    // n^1.5 = n * sqrt(n)
    return n * math.sqrt(n.toDouble());
  }

  Map<String, dynamic> toJson() => {
    'totalXp': totalXp,
    'level': level,
    'streak': streak,
    'bestStreak': bestStreak,
    'questionsAnswered': questionsAnswered,
    'correctAnswers': correctAnswers,
    'simulationsCompleted': simulationsCompleted,
    'experimentsCompleted': experimentsCompleted,
    'aiQuestionsAsked': aiQuestionsAsked,
    'diagnosticComplete': diagnosticComplete,
    'lastActiveDate': lastActiveDate?.toIso8601String(),
    'earnedBadges': earnedBadges,
    'skills': skills.map((k, v) => MapEntry(k, v.toJson())),
    'weakAreas': weakAreas,
    'strongAreas': strongAreas,
    'activityLog': activityLog,
  };

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      totalXp: json['totalXp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      streak: json['streak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      questionsAnswered: json['questionsAnswered'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      simulationsCompleted: json['simulationsCompleted'] as int? ?? 0,
      experimentsCompleted: json['experimentsCompleted'] as int? ?? 0,
      aiQuestionsAsked: json['aiQuestionsAsked'] as int? ?? 0,
      diagnosticComplete: json['diagnosticComplete'] as bool? ?? false,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.tryParse(json['lastActiveDate'] as String)
          : null,
      earnedBadges: (json['earnedBadges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      skills: (json['skills'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, SkillProgress.fromJson(v as Map<String, dynamic>)),
          ) ??
          {},
      weakAreas: (json['weakAreas'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as int),
          ) ??
          {},
      strongAreas: (json['strongAreas'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as int),
          ) ??
          {},
      activityLog: (json['activityLog'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  factory UserProgress.fromJsonString(String jsonString) {
    return UserProgress.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  String toJsonString() => jsonEncode(toJson());
}

/// Progress for a single skill area (e.g., "mechanics", "thermodynamics")
class SkillProgress {
  int xp;
  int questionsAttempted;
  int questionsCorrect;

  SkillProgress({
    this.xp = 0,
    this.questionsAttempted = 0,
    this.questionsCorrect = 0,
  });

  double get accuracy =>
      questionsAttempted > 0 ? questionsCorrect / questionsAttempted : 0;

  int get skillLevel {
    if (xp < 100) return 1;
    if (xp < 300) return 2;
    if (xp < 600) return 3;
    if (xp < 1000) return 4;
    return 5;
  }

  String get skillTitle {
    switch (skillLevel) {
      case 1: return 'مبتدئ';
      case 2: return 'متعلم';
      case 3: return 'متقدم';
      case 4: return 'خبير';
      case 5: return 'أسطورة';
      default: return 'مبتدئ';
    }
  }

  Map<String, dynamic> toJson() => {
    'xp': xp,
    'questionsAttempted': questionsAttempted,
    'questionsCorrect': questionsCorrect,
  };

  factory SkillProgress.fromJson(Map<String, dynamic> json) {
    return SkillProgress(
      xp: json['xp'] as int? ?? 0,
      questionsAttempted: json['questionsAttempted'] as int? ?? 0,
      questionsCorrect: json['questionsCorrect'] as int? ?? 0,
    );
  }
}
