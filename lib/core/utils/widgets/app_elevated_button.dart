import 'package:flutter/material.dart';

/// Common elevated button with built-in loading support.
/// When `loading` is true the button becomes disabled and shows a spinner.
class AppElevatedButton extends StatelessWidget {
  const AppElevatedButton({
    super.key,
    required this.child,
    required this.loading,
    required this.onPressed,
    this.style,
    this.loadingColor = Colors.white,
  });

  final Widget child;
  final bool loading;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Color loadingColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed: (loading ? null : onPressed),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: loading
            ? SizedBox(
                key: const ValueKey<String>('loading'),
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
                ),
              )
            : child is Text
            ? SizedBox(key: const ValueKey<String>('child'), child: child)
            : child,
      ),
    );
  }
}
