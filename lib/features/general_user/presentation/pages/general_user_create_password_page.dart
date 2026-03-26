import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GeneralUserCreatePasswordPage extends StatefulWidget {
  const GeneralUserCreatePasswordPage({super.key});

  @override
  State<GeneralUserCreatePasswordPage> createState() =>
      _GeneralUserCreatePasswordPageState();
}

class _GeneralUserCreatePasswordPageState
    extends State<GeneralUserCreatePasswordPage> {
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  late final ValueNotifier<bool> _obscureNewPasswordNotifier;
  late final ValueNotifier<bool> _obscureConfirmPasswordNotifier;

  @override
  void initState() {
    super.initState();
    _newPasswordController = TextEditingController(text: '**********');
    _confirmPasswordController = TextEditingController(text: '**********');
    _obscureNewPasswordNotifier = ValueNotifier<bool>(true);
    _obscureConfirmPasswordNotifier = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _obscureNewPasswordNotifier.dispose();
    _obscureConfirmPasswordNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          const _CreatePasswordBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, progress, child) {
                  final offsetY = (1 - progress) * 16;
                  return Opacity(
                    opacity: progress,
                    child: Transform.translate(offset: Offset(0, offsetY), child: child),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const SizedBox(height: 12),
                  IconButton(
                    onPressed: () {
                      context.go(AppRoutes.forgotPasswordPath);
                    },
                    icon: const Icon(Icons.arrow_back, size: 24),
                  ),
                  const SizedBox(height: 150),
                  Text(
                    'Create New Psssoword',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2B2F33),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create new password to Sign In',
                    style: textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF30363C),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'New Password',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3F4750),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<bool>(
                    valueListenable: _obscureNewPasswordNotifier,
                    builder: (context, obscure, _) {
                      return TextField(
                        controller: _newPasswordController,
                        obscureText: obscure,
                        decoration: _fieldDecoration.copyWith(
                          suffixIcon: IconButton(
                            onPressed: () {
                              _obscureNewPasswordNotifier.value = !obscure;
                            },
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF3A4046),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Confirm New Password',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3F4750),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<bool>(
                    valueListenable: _obscureConfirmPasswordNotifier,
                    builder: (context, obscure, _) {
                      return TextField(
                        controller: _confirmPasswordController,
                        obscureText: obscure,
                        decoration: _fieldDecoration.copyWith(
                          suffixIcon: IconButton(
                            onPressed: () {
                              _obscureConfirmPasswordNotifier.value = !obscure;
                            },
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF3A4046),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF256BBB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        AppFlushbar.success(
                          'Password updated successfully.',
                          context: context,
                        );
                        context.go(AppRoutes.loginPath);
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                  const Spacer(),
                  const Center(child: _BrandFooter()),
                  const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration get _fieldDecoration {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF2F2F2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC2C7CC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A86D1), width: 1.1),
      ),
    );
  }
}

class _CreatePasswordBackground extends StatelessWidget {
  const _CreatePasswordBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFD0DEE8), Color(0xFFD5E2EA), Color(0xFFDFE8EE)],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 190,
            width: double.infinity,
            child: CustomPaint(painter: _WaterPainter()),
          ),
        ),
      ],
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
        colors: [Color(0xD9D8E4EB), Color(0xE7DFE9EF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    final ripplePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05
      ..color = const Color(0x7AAFC2CF);

    for (double y = 20; y < size.height; y += 14) {
      final path = Path()..moveTo(0, y);
      for (double x = 0; x <= size.width; x += 22) {
        path.quadraticBezierTo(x + 11, y - 2, x + 22, y);
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
        Image.asset(
          'assets/icons/ic_azista.png',
          width: 38,
          height: 38,
          fit: BoxFit.contain,
        ),
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
