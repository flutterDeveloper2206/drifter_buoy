import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Pushes inner routes off the stack first; otherwise navigates to dashboard (home).
class GeneralUserTabRootPopScope extends StatelessWidget {
  const GeneralUserTabRootPopScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final routerCanPop = GoRouter.of(context).canPop();
    return PopScope(
      canPop: routerCanPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        context.go(AppRoutes.dashboardPath);
      },
      child: child,
    );
  }
}

Future<bool?> showGeneralUserExitAppDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (dialogContext) {
      final dialogTextTheme = Theme.of(dialogContext).textTheme;
      return Dialog(
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Exit app',
                textAlign: TextAlign.center,
                style: dialogTextTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF23282D),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Are you sure you want to exit?',
                textAlign: TextAlign.center,
                style: dialogTextTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  color: const Color(0xFF545B61),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF37414A),
                    side: const BorderSide(color: Color(0xFFC2C7CC)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: dialogTextTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: AppElevatedButton(
                  loading: false,
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: dialogTextTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Exit'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> handleGeneralUserDashboardBack(BuildContext context) async {
  if (!context.mounted) {
    return;
  }
  final shouldExit = await showGeneralUserExitAppDialog(context);
  if (shouldExit == true && context.mounted) {
    await SystemNavigator.pop();
  }
}
