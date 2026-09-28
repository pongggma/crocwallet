import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../models/wallet_model.dart' show CrocLevel;
import '../theme/app_colors.dart';

/// Colours for one croc, derived from the wallet colour.
/// The Golden Croc ignores the wallet colour and always turns gold.
class CrocPalette {
  final Color body;
  final Color bodyTop;
  final Color dark;
  final Color belly;
  final Color outline;

  const CrocPalette({
    required this.body,
    required this.bodyTop,
    required this.dark,
    required this.belly,
    required this.outline,
  });

  factory CrocPalette.of(CrocLevel level, Color base) {
    if (level == CrocLevel.golden) {
      return const CrocPalette(
        body: Color(0xFFF0B429),
        bodyTop: Color(0xFFFFD25E),
        dark: Color(0xFFC98A0B),
        belly: Color(0xFFFFEDB0),
        outline: Color(0xFF8A5A00),
      );
    }
    final body = switch (level) {
      CrocLevel.baby => base.lighten(0.08),
      CrocLevel.money => base,
      _ => base.darken(0.05),
    };
    return CrocPalette(
      body: body,
      bodyTop: body.lighten(0.07),
      dark: body.darken(0.16),
      belly: body.lighten(0.30).saturate(-0.05),
      outline: body.darken(0.30),
    );
  }
}

/// Draws a side-view crocodile in a 100 x 100 design space.
///
/// The croc grows with [level]: Baby (small, big eyes, eggshell), Money
/// (spinning coin), Strong (heavy brow, big spikes) and Golden (gold skin,
/// crown, sparkles). Pass an [animation] (0..1, looping) for the idle bob,
/// blink and twinkle; without it the croc is drawn as a still pose.
class CrocPainter extends CustomPainter {
  final CrocLevel level;
  final Color color;
  final Animation<double>? animation;
  final bool shadow;

  CrocPainter({
    required this.level,
    required this.color,
    this.animation,
    this.shadow = true,
  }) : super(repaint: animation);

  // Back line (also used to place spikes). Left to right.
  static const _back0 = Offset(27, 42);
  static const _back1 = Offset(36, 33);
  static const _back2 = Offset(50, 33);
  static const _back3 = Offset(58, 38);

  // Tail top line.
  static const _tail0 = Offset(4, 47);
  static const _tail1 = Offset(12, 44);
  static const _tail2 = Offset(20, 45);
  static const _tail3 = Offset(27, 42);

  static const _eye = Offset(63.6, 35.6);

  double _sizeFactor() => switch (level) {
        CrocLevel.baby => 0.66,
        CrocLevel.money => 0.76,
        CrocLevel.strong => 0.84,
        CrocLevel.golden => 0.92,
      };

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final pal = CrocPalette.of(level, color);
    final animated = animation != null;
    final t = animation?.value ?? 0.0;
    final bob = animated ? math.sin(t * 2 * math.pi) * 1.1 : 0.0;

    // Blink for a short window near the end of each loop.
    double blink = 0;
    if (animated && t > 0.86 && t < 0.92) {
      blink = math.sin(math.pi * (t - 0.86) / 0.06);
    }

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(side / 100 * _sizeFactor());
    canvas.translate(-50, -54);

    if (level == CrocLevel.golden) _glow(canvas, t, animated);
    if (shadow) _shadow(canvas, bob);
    if (level == CrocLevel.baby) _eggShell(canvas);
    if (level == CrocLevel.money) _coin(canvas, t, animated);

    canvas.translate(0, bob);
    _croc(canvas, pal, blink);
    canvas.restore();

    if (level == CrocLevel.golden) {
      // Sparkles are drawn in the same space but do not bob with the croc.
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.scale(side / 100 * _sizeFactor());
      canvas.translate(-50, -54);
      _sparkles(canvas, t, animated);
      canvas.restore();
    }
  }

  // ---------------------------------------------------------------- pieces

  Paint _fill(Color c) => Paint()..color = c;

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  void _glow(Canvas canvas, double t, bool animated) {
    final pulse = animated ? 0.85 + 0.15 * math.sin(t * 2 * math.pi) : 1.0;
    final shader = ui.Gradient.radial(
      const Offset(50, 54),
      52,
      [AppColors.gold.withOpacity(0.34 * pulse), AppColors.gold.withOpacity(0)],
    );
    canvas.drawCircle(const Offset(50, 54), 52, Paint()..shader = shader);
  }

  void _shadow(Canvas canvas, double bob) {
    final k = 1 - bob * 0.03;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 77.6), width: 82 * k, height: 5.2),
      _fill(const Color(0xFF000000).withOpacity(0.16)),
    );
  }

  void _eggShell(Canvas canvas) {
    final e = Path()
      ..moveTo(8, 71)
      ..lineTo(11, 67.2)
      ..lineTo(14.2, 70.6)
      ..lineTo(17.6, 66.4)
      ..lineTo(21, 70.6)
      ..lineTo(24.2, 67.2)
      ..lineTo(28, 71)
      ..cubicTo(28, 78.2, 8, 78.2, 8, 71)
      ..close();
    canvas.drawPath(e, _fill(const Color(0xFFF7EFD6)));
    canvas.drawPath(e, _stroke(const Color(0xFFB9A778), 1));
  }

  void _coin(Canvas canvas, double t, bool animated) {
    final spin = animated ? 0.3 + 0.7 * (1 + math.cos(t * 2 * math.pi)) / 2 : 1.0;
    final dy = animated ? math.sin(t * 4 * math.pi) * 1.4 : 0.0;
    canvas.save();
    canvas.translate(18, 30 + dy);
    canvas.scale(spin, 1);
    const r = 7.6;
    canvas.drawCircle(
      const Offset(0, 0),
      r,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(-r, -r),
          const Offset(r, r),
          [const Color(0xFFFFD25E), const Color(0xFFE59A00)],
        ),
    );
    canvas.drawCircle(const Offset(0, 0), r, _stroke(AppColors.goldDeep, 1.2));
    canvas.drawCircle(const Offset(0, 0), 5.3, _stroke(AppColors.goldDeep.withOpacity(0.55), 0.9));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-0.95, -3.2, 1.9, 6.4),
        const Radius.circular(0.95),
      ),
      _fill(AppColors.goldDeep.withOpacity(0.85)),
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: 6.3),
      math.pi * 1.05,
      math.pi * 0.35,
      false,
      _stroke(Colors.white.withOpacity(0.65), 1.1),
    );
    canvas.restore();
  }

  void _sparkles(Canvas canvas, double t, bool animated) {
    const spots = [
      Offset(13, 31),
      Offset(89, 29),
      Offset(93, 68),
      Offset(7, 64),
    ];
    for (var i = 0; i < spots.length; i++) {
      final tw = animated ? 0.5 + 0.5 * math.sin(t * 4 * math.pi + i * 1.7) : 0.85;
      final r = (i.isEven ? 4.6 : 3.4) * (0.55 + 0.45 * tw);
      final c = spots[i];
      final p = Path()
        ..moveTo(c.dx, c.dy - r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
        ..close();
      canvas.drawPath(p, _fill(const Color(0xFFFFF3B8).withOpacity(0.55 + 0.45 * tw)));
    }
  }

  Offset _cubicAt(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final m = 1 - t;
    return p0 * (m * m * m) +
        p1 * (3 * m * m * t) +
        p2 * (3 * m * t * t) +
        p3 * (t * t * t);
  }

  Offset _cubicTangent(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final m = 1 - t;
    final d = (p1 - p0) * (3 * m * m) + (p2 - p1) * (6 * m * t) + (p3 - p2) * (3 * t * t);
    return d / d.distance;
  }

  void _spikes(
    Canvas canvas,
    (Offset, Offset, Offset, Offset) c,
    List<double> ts,
    double w,
    double h,
    CrocPalette pal,
  ) {
    for (final t in ts) {
      final b = _cubicAt(c.$1, c.$2, c.$3, c.$4, t);
      final tan = _cubicTangent(c.$1, c.$2, c.$3, c.$4, t);
      final nor = Offset(tan.dy, -tan.dx); // points up for a left-to-right line
      final base = b - nor * 1.8;
      final p = Path()
        ..moveTo(base.dx - tan.dx * w, base.dy - tan.dy * w)
        ..lineTo(b.dx + nor.dx * h - tan.dx * w * 0.35, b.dy + nor.dy * h - tan.dy * w * 0.35)
        ..lineTo(base.dx + tan.dx * w, base.dy + tan.dy * w)
        ..close();
      canvas.drawPath(p, _fill(pal.dark));
      canvas.drawPath(p, _stroke(pal.outline, 1));
    }
  }

  void _croc(Canvas canvas, CrocPalette pal, double blink) {
    final baby = level == CrocLevel.baby;
    final strong = level == CrocLevel.strong;
    final golden = level == CrocLevel.golden;

    // Legs (behind the body).
    for (final x in const [31.0, 52.0]) {
      final leg = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 58, 9.5, 16), const Radius.circular(4.2));
      final foot = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 1.2, 71.5, 12.4, 5.2), const Radius.circular(2.6));
      canvas.drawRRect(leg, _fill(pal.dark));
      canvas.drawRRect(foot, _fill(pal.dark));
      canvas.drawRRect(foot, _stroke(pal.outline, 1));
    }

    // Spikes on the back and tail (behind the body so their bases tuck in).
    final backSpikes = baby
        ? const [0.3, 0.55, 0.8]
        : strong
            ? const [0.08, 0.24, 0.4, 0.56, 0.72, 0.88]
            : const [0.12, 0.3, 0.48, 0.66, 0.84];
    final sw = baby ? 2.2 : strong ? 3.6 : 3.0;
    final sh = baby ? 3.6 : strong ? 6.6 : 5.2;
    _spikes(canvas, (_back0, _back1, _back2, _back3), backSpikes, sw, sh, pal);
    if (!baby) {
      _spikes(canvas, (_tail0, _tail1, _tail2, _tail3), const [0.4, 0.72],
          sw * 0.8, sh * 0.75, pal);
    }

    // Silhouette.
    final body = Path()
      ..moveTo(4, 47)
      ..cubicTo(12, 44, 20, 45, 27, 42)
      ..cubicTo(36, 33, 50, 33, 58, 38)
      ..cubicTo(63, 40, 67, 41.5, 72, 42)
      ..cubicTo(78, 42.5, 86, 43.5, 91, 44.5)
      ..cubicTo(97, 45.5, 98, 57, 91, 58)
      ..cubicTo(84, 60, 74, 61, 66, 62)
      ..cubicTo(60, 66, 54, 68, 46, 68)
      ..cubicTo(36, 68, 30, 66, 24, 60)
      ..cubicTo(16, 56, 8, 52, 4, 47)
      ..close();

    canvas.drawPath(
      body,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 30),
          const Offset(0, 68),
          [pal.bodyTop, pal.body],
        ),
    );

    // Belly, jaw and texture, clipped to the silhouette.
    canvas.save();
    canvas.clipPath(body);
    final belly = Path()
      ..moveTo(0, 55)
      ..cubicTo(16, 61, 34, 59, 52, 62)
      ..cubicTo(60, 62.5, 63, 58.5, 70, 55.2)
      ..cubicTo(77, 57.6, 86, 57.6, 93, 55.6)
      ..lineTo(100, 55.4)
      ..lineTo(100, 90)
      ..lineTo(0, 90)
      ..close();
    canvas.drawPath(belly, _fill(pal.belly));
    if (!baby) {
      final spot = _fill(pal.dark.withOpacity(0.28));
      canvas.drawOval(Rect.fromCenter(center: const Offset(38, 46), width: 5, height: 3.6), spot);
      canvas.drawOval(Rect.fromCenter(center: const Offset(47, 42), width: 4, height: 3), spot);
      canvas.drawOval(Rect.fromCenter(center: const Offset(33, 52), width: 3.6, height: 2.8), spot);
      canvas.drawOval(Rect.fromCenter(center: const Offset(50, 50), width: 4.6, height: 3.4), spot);
    }
    if (baby) {
      canvas.drawCircle(const Offset(75, 49), 3.2, _fill(const Color(0xFFFF8FA3).withOpacity(0.4)));
    }
    canvas.restore();

    canvas.drawPath(body, _stroke(pal.outline, 1.3));

    // Mouth: teeth first so the mouth line sits on top of their bases.
    if (!baby) {
      const teeth = [Offset(87.5, 57.0), Offset(81, 57.6), Offset(74.5, 56.9)];
      for (final p in teeth) {
        final tooth = Path()
          ..moveTo(p.dx - 1.5, p.dy - 0.4)
          ..lineTo(p.dx, p.dy + 3.0)
          ..lineTo(p.dx + 1.5, p.dy - 0.4)
          ..close();
        canvas.drawPath(tooth, _fill(Colors.white));
        canvas.drawPath(tooth, _stroke(pal.outline.withOpacity(0.8), 0.6));
      }
    }
    final mouth = Path()
      ..moveTo(93, 55.6)
      ..cubicTo(86, 57.6, 77, 57.6, 70, 55.2)
      ..quadraticBezierTo(68, 54.6, 66.6, 52.6);
    canvas.drawPath(mouth, _stroke(pal.outline, 1.4));

    // Nostril.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(90.2, 47.2), width: 3.0, height: 2.2),
      _fill(pal.outline),
    );

    // Eye bump, eye, brow.
    const bump = Offset(63, 36);
    canvas.drawCircle(bump, 6.4, _fill(pal.bodyTop));
    canvas.drawArc(
      Rect.fromCircle(center: bump, radius: 6.4),
      math.pi * 0.92,
      math.pi * 1.16,
      false,
      _stroke(pal.outline, 1.3),
    );

    final er = baby ? 5.4 : 4.6;
    canvas.drawCircle(_eye, er, _fill(Colors.white));
    canvas.drawCircle(_eye + const Offset(1.1, 0.3), er * 0.52, _fill(const Color(0xFF14211B)));
    canvas.drawCircle(_eye + Offset(1.9, -0.7), er * 0.2, _fill(Colors.white));

    if (blink > 0.02) {
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: _eye, radius: er)));
      canvas.drawRect(
        Rect.fromLTWH(_eye.dx - er, _eye.dy - er, er * 2, er * 2 * blink),
        _fill(pal.bodyTop),
      );
      canvas.restore();
    }
    if (blink > 0.5) {
      // Closed-eye line once the lid is mostly down.
      final a = ((blink - 0.5) * 2).clamp(0.0, 1.0).toDouble();
      final lid = Path()
        ..moveTo(_eye.dx - er * 0.85, _eye.dy + 0.2)
        ..quadraticBezierTo(_eye.dx, _eye.dy + 1.9, _eye.dx + er * 0.85, _eye.dy + 0.2);
      canvas.drawPath(lid, _stroke(pal.outline.withOpacity(a), 1.3));
    }

    if (strong) {
      canvas.drawLine(
        const Offset(57.6, 30.8),
        const Offset(69.6, 34.4),
        _stroke(pal.dark, 2.4),
      );
    }

    if (golden) _crown(canvas);
  }

  void _crown(Canvas canvas) {
    canvas.save();
    canvas.translate(50.5, 37.4);
    canvas.rotate(-0.16);
    final p = Path()
      ..moveTo(-6.5, 0)
      ..lineTo(-7.2, -8)
      ..lineTo(-3.4, -4.2)
      ..lineTo(0, -9.4)
      ..lineTo(3.4, -4.2)
      ..lineTo(7.2, -8)
      ..lineTo(6.5, 0)
      ..close();
    canvas.drawPath(p, _fill(const Color(0xFFFFF6D6)));
    canvas.drawPath(p, _stroke(const Color(0xFF8A5A00), 1.1));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-6.5, -2.4, 13, 2.6),
        const Radius.circular(1),
      ),
      _fill(const Color(0xFFC98A0B)),
    );
    for (final j in const [Offset(-7.2, -8), Offset(0, -9.4), Offset(7.2, -8)]) {
      canvas.drawCircle(j, 1.25, _fill(const Color(0xFFE5484D)));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CrocPainter old) =>
      old.level != level ||
      old.color != color ||
      old.animation != animation ||
      old.shadow != shadow;
}
