import 'package:cheery/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Dimmed scrim with tight spotlight holes and a soft border pulse.
class OnboardingSpotlightLayer extends StatelessWidget {
  const OnboardingSpotlightLayer({
    required this.holes,
    super.key,
  });

  final List<Rect> holes;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _SpotlightPainter(holes: holes),
          ),
          for (final hole in holes) _HighlightBorder(rect: hole),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({required this.holes});

  final List<Rect> holes;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..addRect(Offset.zero & size);
    for (final hole in holes) {
      final padded = hole.inflate(3);
      path.addRRect(
        RRect.fromRectAndRadius(padded, _radiusFor(padded)),
      );
    }
    path.fillType = PathFillType.evenOdd;

    canvas.drawPath(
      path,
      Paint()..color = AppColors.ink.withValues(alpha: 0.48),
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    if (oldDelegate.holes.length != holes.length) return true;
    for (var i = 0; i < holes.length; i++) {
      if (oldDelegate.holes[i] != holes[i]) return true;
    }
    return false;
  }
}

Radius _radiusFor(Rect rect) {
  final aspect = rect.width / rect.height;
  // Square targets (FAB) get a circular cutout.
  if (aspect > 0.85 && aspect < 1.15) {
    return Radius.circular(rect.shortestSide / 2);
  }
  // Cheery buttons / pills.
  return Radius.circular((rect.shortestSide / 2).clamp(8, 14));
}

class _HighlightBorder extends StatefulWidget {
  const _HighlightBorder({required this.rect});

  final Rect rect;

  @override
  State<_HighlightBorder> createState() => _HighlightBorderState();
}

class _HighlightBorderState extends State<_HighlightBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padded = widget.rect.inflate(3);
    final radius = _radiusFor(padded);

    return Positioned(
      left: padded.left,
      top: padded.top,
      width: padded.width,
      height: padded.height,
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.45, end: 1).animate(_opacity),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(radius),
            border: Border.all(
              color: AppColors.cherry,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
