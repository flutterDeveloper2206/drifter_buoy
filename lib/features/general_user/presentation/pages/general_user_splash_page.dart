import 'dart:async';

import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/network/network_connection_checker.dart';
import 'package:drifter_buoy/core/storage/auth_session_store.dart';
import 'package:drifter_buoy/core/utils/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GeneralUserSplashPage extends StatefulWidget {
  final bool autoNavigate;

  const GeneralUserSplashPage({super.key, this.autoNavigate = true});

  @override
  State<GeneralUserSplashPage> createState() => _GeneralUserSplashPageState();
}

class _GeneralUserSplashPageState extends State<GeneralUserSplashPage> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _scheduleNavigation();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _scheduleNavigation() {
    if (!widget.autoNavigate) {
      return;
    }

    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }
      _navigateAfterSplash();
    });
  }

  Future<void> _navigateAfterSplash() async {
    final hasInternet = await NetworkConnectionChecker.hasInternetConnection();
    if (!mounted) return;

    if (!hasInternet) {
      await _showNoInternetDialog();
      return;
    }

    final authSessionStore = sl<AuthSessionStore>();
    final token = await authSessionStore.getAccessToken();

    if (!mounted) return;
    if (token != null && token.trim().isNotEmpty) {
      final loginResponse = await authSessionStore.getLoginResponse();
      if (!mounted) return;
      final roleName = loginResponse?.result.roleName ?? '';
      final isAdmin = roleName.toLowerCase() == 'admin';
      context.go(AppRoutes.dashboardPath, extra: isAdmin);
      return;
    }

    context.go(AppRoutes.loginPath);
  }

  Future<void> _showNoInternetDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text(
            'Please connect to the internet to continue. '
            'If you dismiss this dialog, you will see the offline screen.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Dismiss'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    final hasInternet = await NetworkConnectionChecker.hasInternetConnection();
    if (!mounted) return;
    if (hasInternet) {
      await _navigateAfterSplash();
      return;
    }
    context.go(AppRoutes.noInternetPath);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          const _SplashBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.94, end: 1),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            builder: (context, scale, child) =>
                                Transform.scale(scale: scale, child: child),
                            child: Container(
                              width: 136,
                              height: 136,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 24,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 78,
                                  height: 78,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2E6FB6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.waves_rounded,
                                    color: Colors.white,
                                    size: 44,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                          Text(
                            'Drifter Buoy Monitoring System',
                            textAlign: TextAlign.center,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2B2F33),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Track. Configure. Diagnose -\nAnytime, Anywhere.',
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF40464D),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const _BrandFooter(),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFC5D4DE), Color(0xFFCFDEE7), Color(0xFFDCE6ED)],
            ),
          ),
        ),
        Positioned(
          top: 120,
          left: -60,
          child: _CloudPatch(width: 180, height: 90),
        ),
        Positioned(
          top: 160,
          right: -40,
          child: _CloudPatch(width: 220, height: 95),
        ),
        Positioned(
          top: 240,
          left: 80,
          child: _CloudPatch(width: 160, height: 70),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 230,
            width: double.infinity,
            child: CustomPaint(painter: _WaterPainter()),
          ),
        ),
      ],
    );
  }
}

class _CloudPatch extends StatelessWidget {
  final double width;
  final double height;

  const _CloudPatch({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.26),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
      ),
    );
  }
}

class _WaterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xD5D7E2EA), Color(0xE3DEE8EF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    final ripplePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0x88B9CAD6);

    for (double y = 22; y < size.height; y += 16) {
      final path = Path()..moveTo(0, y);

      for (double x = 0; x <= size.width; x += 24) {
        path.quadraticBezierTo(x + 12, y - 2, x + 24, y);
      }

      canvas.drawPath(path, ripplePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BrandFooter extends StatelessWidget {
  const _BrandFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('🪷', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 2),
        Text(
          'Azista',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: const Color(0xFFC93333),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
