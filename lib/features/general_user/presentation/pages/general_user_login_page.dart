import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GeneralUserLoginPage extends StatefulWidget {
  const GeneralUserLoginPage({super.key});

  @override
  State<GeneralUserLoginPage> createState() => _GeneralUserLoginPageState();
}

class _GeneralUserLoginPageState extends State<GeneralUserLoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final ValueNotifier<bool> _obscurePasswordNotifier;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'mailid@example.com');
    _passwordController = TextEditingController(text: '**********');
    _obscurePasswordNotifier = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePasswordNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const _LoginBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(bottom: viewInsets.bottom),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                            child: Transform.translate(
                              offset: Offset(0, offsetY),
                              child: child,
                            ),
                          );
                        },
                        child: Form(
                          key: _formKey,
                          autovalidateMode: _submitted
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 64),
                              Center(
                                child: Container(
                                  width: 92,
                                  height: 92,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.82),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 58,
                                      height: 58,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1682C9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.waves_rounded,
                                        color: Colors.white,
                                        size: 34,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 44),
                              Text(
                                'Log In',
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2B2F33),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'to Access real-time buoy data, configuration, and\ndiagnostics.',
                                style: textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF30363C),
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Email Address',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3F4750),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: _fieldDecoration,
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Password',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3F4750),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ValueListenableBuilder<bool>(
                                valueListenable: _obscurePasswordNotifier,
                                builder: (context, obscure, _) {
                                  return TextFormField(
                                    controller: _passwordController,
                                    obscureText: obscure,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _onLoginTap(),
                                    decoration: _fieldDecoration.copyWith(
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          _obscurePasswordNotifier.value =
                                              !obscure;
                                        },
                                        icon: Icon(
                                          obscure
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: const Color(0xFF3A4046),
                                        ),
                                      ),
                                    ),
                                    validator: _validatePassword,
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              InkWell(
                                onTap: () {
                                  context.go(AppRoutes.forgotPasswordPath);
                                },
                                child: Text(
                                  'Forgot Password ?',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF37414A),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 34),
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
                                  onPressed: _onLoginTap,
                                  child: const Text('Log In'),
                                ),
                              ),
                              const SizedBox(height: 28),
                              const Center(child: _BrandFooter()),
                              const SizedBox(height: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD94A4A), width: 1.1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD94A4A), width: 1.2),
      ),
    );
  }

  void _onLoginTap() {
    setState(() {
      _submitted = true;
    });

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    FocusScope.of(context).unfocus();
    final normalizedEmail = _emailController.text.trim().toLowerCase();
    final isAdmin = normalizedEmail.contains('admin');
    context.go(AppRoutes.dashboardPath, extra: isAdmin);
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required';
    }

    const emailPattern =
        r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
    final isValid = RegExp(emailPattern).hasMatch(email);
    if (!isValid) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value?.trim() ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

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
