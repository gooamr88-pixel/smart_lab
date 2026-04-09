import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/skill_area.dart';
import '../widgets/xp_overlay.dart';

/// Provider managing user progress, XP, levels, badges, and adaptive learning.
/// Persists data to SharedPreferences.
class ProgressProvider extends ChangeNotifier {
  static const String _storageKey = 'smart_lab_progress';

  UserProgress _progress = UserProgress();
  bool _isLoaded = false;
  String? _lastBadgeEarned;
  int _lastXpGained = 0;
  bool _showLevelUp = false;

  // Getters
  UserProgress get progress => _progress;
  bool get isLoaded => _isLoaded;
  String? get lastBadgeEarned => _lastBadgeEarned;
  int get lastXpGained => _lastXpGained;
  bool get showLevelUp => _showLevelUp;

  /// Load progress from SharedPreferences
  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      _progress = UserProgress.fromJsonString(jsonString);
    }
    _updateStreak();
    _isLoaded = true;
    notifyListeners();
  }

  /// Save progress to SharedPreferences
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, _progress.toJsonString());
  }

  /// Update streak based on last active date
  void _updateStreak() {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (_progress.lastActiveDate != null) {
      final diff = today.difference(_progress.lastActiveDate!).inDays;
      if (diff == 1) {
        _progress.streak++;
        if (_progress.streak > _progress.bestStreak) {
          _progress.bestStreak = _progress.streak;
        }
      } else if (diff > 1) {
        _progress.streak = 1;
      }
      // diff == 0 → same day, don't change
    } else {
      _progress.streak = 1;
    }

    _progress.lastActiveDate = today;

    // Add to activity log
    if (!_progress.activityLog.contains(todayStr)) {
      _progress.activityLog.add(todayStr);
      // Keep only last 90 days
      if (_progress.activityLog.length > 90) {
        _progress.activityLog.removeAt(0);
      }
    }
  }

  /// Award XP and check for level-up
  void addXp(int amount, {String? skill}) {
    final prevLevel = _progress.level;
    _progress.totalXp += amount;
    _lastXpGained = amount;

    // Update skill XP
    if (skill != null) {
      _progress.skills.putIfAbsent(skill, () => SkillProgress());
      _progress.skills[skill]!.xp += amount;
    }

    // Check level-up
    _recalculateLevel();
    _showLevelUp = _progress.level > prevLevel;

    _checkBadges();
    _save();
    notifyListeners();
  }

  /// Award XP with visual overlay feedback.
  ///
  /// This is the primary method to call from screens. It:
  /// 1. Awards the XP via [addXp]
  /// 2. Shows the floating "+XP" badge overlay
  /// 3. Shows level-up celebration if triggered
  /// 4. Shows badge notification if earned
  void addXpWithOverlay(
    BuildContext context, {
    required int amount,
    String? skill,
    String? label,
    String emoji = '⚡',
  }) {
    final prevLevel = _progress.level;
    final prevBadgeCount = _progress.earnedBadges.length;

    addXp(amount, skill: skill);

    // Show XP overlay
    if (context.mounted) {
      XpOverlay.show(context, amount: amount, label: label, emoji: emoji);
    }

    // Show level-up if triggered
    if (_progress.level > prevLevel && context.mounted) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (context.mounted) {
          XpOverlay.showLevelUp(context, newLevel: _progress.level);
        }
      });
    }

    // Show badge if earned
    if (_progress.earnedBadges.length > prevBadgeCount && context.mounted) {
      final newBadgeId = _progress.earnedBadges.last;
      final badge = Badges.getById(newBadgeId);
      if (badge != null) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (context.mounted) {
            XpOverlay.showBadge(
              context,
              name: badge.nameEn,
              emoji: badge.emoji,
            );
          }
        });
      }
    }

    clearLevelUp();
  }

  void _recalculateLevel() {
    int accumulated = 0;
    int level = 1;
    while (true) {
      final needed = (100 * _pow15(level)).toInt();
      if (accumulated + needed > _progress.totalXp) break;
      accumulated += needed;
      level++;
      if (level > 100) break; // safety cap
    }
    _progress.level = level;
  }

  double _pow15(int n) {
    return n * math.sqrt(n.toDouble());
  }

  /// Record a quiz answer
  void recordAnswer({
    required String topic,
    required bool correct,
    String? skill,
  }) {
    _progress.questionsAnswered++;
    if (correct) {
      _progress.correctAnswers++;
      _progress.strongAreas[topic] = (_progress.strongAreas[topic] ?? 0) + 1;
      addXp(XpRewards.correctAnswer, skill: skill);
    } else {
      _progress.weakAreas[topic] = (_progress.weakAreas[topic] ?? 0) + 1;
      addXp(XpRewards.wrongAnswer, skill: skill);
    }

    if (skill != null) {
      _progress.skills.putIfAbsent(skill, () => SkillProgress());
      _progress.skills[skill]!.questionsAttempted++;
      if (correct) _progress.skills[skill]!.questionsCorrect++;
    }
  }

  /// Record experiment completion with optional overlay
  void completeExperiment({BuildContext? context}) {
    _progress.experimentsCompleted++;
    if (context != null && context.mounted) {
      addXpWithOverlay(
        context,
        amount: XpRewards.experimentComplete,
        label: 'Experiment! 🧪',
        emoji: '🧪',
      );
    } else {
      addXp(XpRewards.experimentComplete);
    }
  }

  /// Record simulation completion with optional overlay
  void completeSimulation({BuildContext? context}) {
    _progress.simulationsCompleted++;
    if (context != null && context.mounted) {
      addXpWithOverlay(
        context,
        amount: XpRewards.simulationComplete,
        label: 'Simulation! 🚀',
        emoji: '🚀',
      );
    } else {
      addXp(XpRewards.simulationComplete);
    }
  }

  /// Record AI question asked
  void recordAiQuestion() {
    _progress.aiQuestionsAsked++;
    addXp(XpRewards.aiQuestion);
  }

  /// Record quiz completion
  void completeQuiz({required int score, required int total}) {
    int xp = XpRewards.completedQuiz;
    if (score == total && total > 0) {
      xp += XpRewards.perfectQuiz;
    }
    addXp(xp);
  }

  /// Mark diagnostic as complete
  void completeDiagnostic() {
    _progress.diagnosticComplete = true;
    addXp(XpRewards.diagnosticComplete);
  }

  /// Clear level-up flag
  void clearLevelUp() {
    _showLevelUp = false;
    notifyListeners();
  }

  /// Clear last badge flag
  void clearLastBadge() {
    _lastBadgeEarned = null;
    notifyListeners();
  }

  /// Get recommended difficulty based on accuracy
  String getDifficulty() {
    final acc = _progress.accuracy;
    if (acc < 0.4) return 'easy';
    if (acc < 0.7) return 'medium';
    return 'hard';
  }

  /// Get recommended topics (weak areas)
  List<String> getRecommendedTopics() {
    if (_progress.weakAreas.isEmpty) return [];
    final sorted = _progress.weakAreas.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  /// Check if user was active on a given date
  bool wasActiveOn(DateTime date) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _progress.activityLog.contains(dateStr);
  }

  /// Check and award badges
  void _checkBadges() {
    _lastBadgeEarned = null;

    for (final badge in Badges.all) {
      if (_progress.earnedBadges.contains(badge.id)) continue;

      bool earned = false;
      switch (badge.id) {
        case 'first_experiment':
          earned = _progress.experimentsCompleted >= 1;
          break;
        case 'lab_rat':
          earned = _progress.experimentsCompleted >= 10;
          break;
        case 'perfect_score':
          earned = false; // awarded in completeQuiz
          break;
        case 'streak_7':
          earned = _progress.streak >= 7;
          break;
        case 'deep_thinker':
          earned = _progress.aiQuestionsAsked >= 20;
          break;
        case 'sim_explorer':
          earned = _progress.simulationsCompleted >= 5;
          break;
        case 'level_5':
          earned = _progress.level >= 5;
          break;
        case 'accuracy_80':
          earned = _progress.questionsAnswered >= 10 && _progress.accuracy >= 0.8;
          break;
        case 'chemistry_hero':
          earned = _progress.experimentsCompleted >= 5;
          break;
        case 'newton_master':
          earned = _progress.simulationsCompleted >= 3;
          break;
      }

      if (earned) {
        _progress.earnedBadges.add(badge.id);
        _lastBadgeEarned = badge.id;
      }
    }
  }

  /// Reset all progress (for testing)
  Future<void> resetProgress() async {
    _progress = UserProgress();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }
}
