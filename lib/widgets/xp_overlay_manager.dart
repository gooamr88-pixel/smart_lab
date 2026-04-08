import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import 'xp_animation_widget.dart';

/// Wrapper widget that shows XP gain and Level-up animations.
/// Wrap any Scaffold body with this to get automatic XP overlay.
class XpOverlayManager extends StatefulWidget {
  final Widget child;

  const XpOverlayManager({super.key, required this.child});

  @override
  State<XpOverlayManager> createState() => _XpOverlayManagerState();
}

class _XpOverlayManagerState extends State<XpOverlayManager> {
  final List<_XpNotification> _notifications = [];
  int _notifId = 0;
  int _lastProcessedXp = 0;
  int _lastProcessedLevel = 0;
  String? _lastProcessedBadge;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final progress = context.watch<ProgressProvider>();

    // Show XP animation — only on NEW XP events
    final currentXp = progress.lastXpGained;
    if (currentXp > 0 && currentXp != _lastProcessedXp) {
      _lastProcessedXp = currentXp;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _notifications.add(_XpNotification(id: _notifId++, xp: currentXp));
        });
      });
    }

    // Show level-up overlay — only on NEW level-ups
    if (progress.showLevelUp && progress.progress.level != _lastProcessedLevel) {
      _lastProcessedLevel = progress.progress.level;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showLevelUp(progress.progress.level);
        progress.clearLevelUp();
      });
    }

    // Show badge earned — only on NEW badges
    if (progress.lastBadgeEarned != null && progress.lastBadgeEarned != _lastProcessedBadge) {
      _lastProcessedBadge = progress.lastBadgeEarned;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showBadge(progress.lastBadgeEarned!);
        progress.clearLastBadge();
      });
    }
  }

  void _showLevelUp(int level) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Level Up',
      barrierColor: Colors.transparent,
      pageBuilder: (context, anim1, anim2) {
        return LevelUpOverlay(
          newLevel: level,
          onDismiss: () => Navigator.of(context, rootNavigator: true).pop(),
        );
      },
    );
  }

  void _showBadge(String badgeId) {
    final badges = {
      'first_experiment': '🧪 أول تجربة!',
      'lab_rat': '🐭 فأر المعمل!',
      'perfect_score': '💯 علامة كاملة!',
      'streak_7': '🔥 أسبوع متواصل!',
      'newton_master': '🏅 نيوتن ماستر!',
      'deep_thinker': '🧠 مفكر عميق!',
      'sim_explorer': '⚡ مستكشف المحاكي!',
      'level_5': '⭐ المستوى الخامس!',
      'accuracy_80': '🎯 دقة عالية!',
      'chemistry_hero': '🧬 بطل الكيمياء!',
    };

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🏅 شارة جديدة: ${badges[badgeId] ?? badgeId}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFFFD700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _removeNotification(int id) {
    if (!mounted) return;
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // XP floating notifications
        ...List.generate(_notifications.length, (i) {
          final notif = _notifications[i];
          return Positioned(
            top: 100 + (i * 60.0),
            left: 0,
            right: 0,
            child: Center(
              child: XpAnimationWidget(
                key: ValueKey(notif.id),
                xpAmount: notif.xp,
                onComplete: () => _removeNotification(notif.id),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _XpNotification {
  final int id;
  final int xp;
  _XpNotification({required this.id, required this.xp});
}
