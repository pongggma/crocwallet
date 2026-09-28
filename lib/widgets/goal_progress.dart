import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class GoalProgress extends StatelessWidget {
  final double progress; // 0..1
  final Color? color;
  final double height;

  const GoalProgress({
    super.key,
    required this.progress,
    this.color,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    final c = progress >= 1 ? AppColors.gold : (color ?? Theme.of(context).colorScheme.primary);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0).toDouble()),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: LinearProgressIndicator(
          value: v,
          minHeight: height,
          backgroundColor: c.withOpacity(0.15),
          valueColor: AlwaysStoppedAnimation(c),
        ),
      ),
    );
  }
}
