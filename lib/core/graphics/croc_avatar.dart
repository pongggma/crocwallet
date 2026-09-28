import 'package:flutter/material.dart';
import '../../models/wallet_model.dart' show CrocLevel, CrocLevelX;
import '../theme/app_colors.dart';
import 'croc_painter.dart';

/// A painted croc, optionally inside a tinted round badge.
///
/// [animate] turns on the idle bob, blink, spinning coin and sparkles. Keep it
/// off in long lists and on for hero spots (wallet detail, level-up). It is
/// switched off automatically when the system asks to reduce animations.
class CrocAvatar extends StatefulWidget {
  final CrocLevel level;
  final Color color;
  final double size;
  final bool animate;
  final bool badge;

  const CrocAvatar({
    super.key,
    required this.level,
    required this.color,
    this.size = 52,
    this.animate = false,
    this.badge = true,
  });

  @override
  State<CrocAvatar> createState() => _CrocAvatarState();
}

class _CrocAvatarState extends State<CrocAvatar>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncController();
  }

  @override
  void didUpdateWidget(CrocAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController();
  }

  void _syncController() {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final wanted = widget.animate && !reduce;
    if (wanted && _controller == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4),
      )..repeat();
    } else if (!wanted && _controller != null) {
      _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final golden = widget.level == CrocLevel.golden;
    final tint = golden ? AppColors.gold : widget.color;
    final s = widget.size;

    final art = CustomPaint(
      size: Size.square(s),
      painter: CrocPainter(
        level: widget.level,
        color: widget.color,
        animation: _controller,
        shadow: !widget.badge || s >= 40,
      ),
    );

    return Semantics(
      label: widget.level.title,
      image: true,
      child: RepaintBoundary(
        child: SizedBox(
          width: s,
          height: s,
          child: widget.badge
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tint.withOpacity(golden ? 0.2 : 0.16),
                    border: golden
                        ? Border.all(color: AppColors.gold, width: s * 0.04)
                        : null,
                  ),
                  child: art,
                )
              : art,
        ),
      ),
    );
  }
}
