import 'package:flutter/material.dart';

/// Staggered entrance for list rows: slides **in from the right** and fades in.
///
/// Reuse on any vertical list by wrapping each row and passing its [index].
class AnimatedListEntrance extends StatelessWidget {
  const AnimatedListEntrance({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 420),
    this.slideFromRightPx = 32,
    this.staggerFraction = 0.055,
    this.maxStaggerLeading = 0.52,
  });

  /// Row index (0-based); used to stagger start times.
  final int index;

  final Widget child;

  /// Total duration of one row’s motion (stagger shifts the active window inside).
  final Duration duration;

  /// Horizontal offset at progress 0 (positive = start off-screen to the right).
  final double slideFromRightPx;

  /// Each row starts its interval later by this fraction of [duration].
  final double staggerFraction;

  /// Cap so the first interval’s start does not exceed this (keeps long lists sane).
  final double maxStaggerLeading;

  @override
  Widget build(BuildContext context) {
    final start = (index * staggerFraction).clamp(0.0, maxStaggerLeading);
    final end = (start + 0.38).clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
      builder: (context, double t, Widget? animatedChild) {
        final dx = slideFromRightPx * (1 - t);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(dx, 0),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }
}
