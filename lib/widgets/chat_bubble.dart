import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_constants.dart';

/// A styled chat message bubble with RTL/LTR support and entrance animation
class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isArabic;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.isArabic = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAvatar(),
          if (!isUser) const SizedBox(width: 8),
          Flexible(child: _buildBubble(context)),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withAlpha(80),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Text('🤖', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryLight.withAlpha(40),
      ),
      child: const Center(
        child: Icon(Icons.person, size: 18, color: AppColors.primaryLight),
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isUser ? AppColors.userBubble : AppColors.aiBubble,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isUser ? 20 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: (isUser ? AppColors.userBubble : Colors.black)
                .withAlpha(30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SelectableText(
        text,
        style: GoogleFonts.cairo(
          fontSize: 15,
          height: 1.6,
          color: isUser ? AppColors.primaryDark : AppColors.textPrimary,
          fontWeight: FontWeight.w400,
        ),
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      ),
    );
  }
}

/// Animated typing indicator (three bouncing dots)
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(reverse: true);
    });

    _animations = _controllers.asMap().entries.map((entry) {
      return Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(
          parent: entry.value,
          curve: Interval(entry.key * 0.2, 0.6 + entry.key * 0.2,
              curve: Curves.easeInOut),
        ),
      );
    }).toList();

    // Stagger the start
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppGradients.primary,
          ),
          child: const Center(
            child: Text('🤖', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.aiBubble,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              return AnimatedBuilder(
                animation: _animations[i],
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _animations[i].value),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withAlpha(180),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}
