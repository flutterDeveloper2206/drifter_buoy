import 'package:another_flushbar/flushbar.dart';
import 'package:drifter_buoy/core/utils/navigation_service.dart';
import 'package:flutter/material.dart';

class AppFlushbar {
  AppFlushbar._();

  static Future<void> show({
    required String message,
    String? title,
    BuildContext? context,
    Color backgroundColor = const Color(0xFF323232),
    Color textColor = Colors.white,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    FlushbarPosition position = FlushbarPosition.TOP,
  }) async {
    final activeContext = context ?? NavigationService.currentContext;
    if (activeContext == null) {
      return;
    }

    await Flushbar<void>(
      title: title,
      message: message,
      duration: duration,
      flushbarPosition: position,
      backgroundColor: backgroundColor,
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
      icon: icon == null ? null : Icon(icon, color: textColor),
      titleColor: textColor,
      messageColor: textColor,
    ).show(activeContext);
  }

  static Future<void> success(
    String message, {
    String title = 'Success',
    BuildContext? context,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      icon: Icons.check_circle_outline,
      backgroundColor: const Color(0xFF2E7D32),
    );
  }

  static Future<void> error(
    String message, {
    String title = 'Error',
    BuildContext? context,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      icon: Icons.error_outline,
      backgroundColor: const Color(0xFFC62828),
      duration: const Duration(seconds: 4),
    );
  }

  static Future<void> info(
    String message, {
    String title = 'Info',
    BuildContext? context,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      icon: Icons.info_outline,
      backgroundColor: const Color(0xFF1565C0),
    );
  }

  static Future<void> warning(
    String message, {
    String title = 'Warning',
    BuildContext? context,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      icon: Icons.warning_amber_outlined,
      backgroundColor: const Color(0xFFEF6C00),
    );
  }
}
