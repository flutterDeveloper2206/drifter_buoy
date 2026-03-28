import 'package:drifter_buoy/core/constants/app_assets.dart';
import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:drifter_buoy/core/utils/widgets/app_elevated_button.dart';
import 'package:drifter_buoy/core/utils/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:drifter_buoy/features/general_user/presentation/bloc/forgot_password/general_user_forgot_password_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/forgot_password/general_user_forgot_password_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/forgot_password/general_user_forgot_password_state.dart';

class GeneralUserForgotPasswordPage extends StatefulWidget {
  const GeneralUserForgotPasswordPage({super.key});

  @override
  State<GeneralUserForgotPasswordPage> createState() =>
      _GeneralUserForgotPasswordPageState();
}

class _GeneralUserForgotPasswordPageState
    extends State<GeneralUserForgotPasswordPage> {
  late final TextEditingController _emailController;
  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _otpFocusNodes;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: '');
    _otpControllers = List.generate(6, (_) => TextEditingController());
    _otpFocusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return BlocProvider(
      create: (_) => sl<GeneralUserForgotPasswordBloc>(),
      child: BlocListener<GeneralUserForgotPasswordBloc,
          GeneralUserForgotPasswordState>(
        listener: (context, state) {
          if (state is GeneralUserForgotPasswordCodeRequested) {
            AppFlushbar.success(state.message);
          } else if (state is GeneralUserForgotPasswordError) {
            AppFlushbar.error(state.message);
          } else if (state is GeneralUserForgotPasswordVerified) {
            context.go(AppRoutes.createPasswordPath);
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const _ForgotPasswordBackground(),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.only(bottom: viewInsets.bottom),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
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
                            child: IntrinsicHeight(
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
                        child: Image.asset(
                          AppAssets.icLogo,
                          width: 64,
                          height: 64,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 44),
                  Text(
                    'Forgot Password?',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2B2F33),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter Mobile to Reset Password',
                    style: textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF30363C),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Email Address',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3F4750),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    decoration: _fieldDecoration,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child:
                        BlocBuilder<GeneralUserForgotPasswordBloc,
                            GeneralUserForgotPasswordState>(
                      builder: (context, state) {
                        final isRequesting =
                            state is GeneralUserForgotPasswordRequestingCode;
                        final isBusy = isRequesting ||
                            state is GeneralUserForgotPasswordVerifyingCode;

                        return TextButton(
                          onPressed: isBusy
                              ? null
                              : () {
                                  final email = _emailController.text.trim();
                                  if (email.isEmpty) {
                                    AppFlushbar.error('Email is required');
                                    return;
                                  }

                                  context
                                      .read<GeneralUserForgotPasswordBloc>()
                                      .add(
                                        RequestVerificationCodeRequested(
                                          emailAddress: email,
                                        ),
                                      );
                                },
                          child: isRequesting
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      Color(0xFF37414A),
                                    ),
                                  ),
                                )
                              : Text(
                                  'Request Verification Code',
                                  style:
                                      textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF37414A),
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Verification Code',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3F4750),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(6, (index) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index == 5 ? 0 : 10),
                          child: TextField(
                            controller: _otpControllers[index],
                            focusNode: _otpFocusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: _otpDecoration,
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                _otpFocusNodes[index + 1].requestFocus();
                              }
                              if (value.isEmpty && index > 0) {
                                _otpFocusNodes[index - 1].requestFocus();
                              }
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child:
                        BlocBuilder<GeneralUserForgotPasswordBloc,
                            GeneralUserForgotPasswordState>(
                      builder: (context, state) {
                        final isRequesting =
                            state is GeneralUserForgotPasswordRequestingCode;
                        final isVerifying =
                            state is GeneralUserForgotPasswordVerifyingCode;
                        final isDisabled = isRequesting || isVerifying;

                        return AppElevatedButton(
                          loading: isVerifying,
                          onPressed: isDisabled
                              ? null
                              : () {
                                  final email =
                                      _emailController.text.trim();
                                  if (email.isEmpty) {
                                    AppFlushbar.error('Email is required');
                                    return;
                                  }

                                  final otp = _otpControllers
                                      .map((c) => c.text.trim())
                                      .join();
                                  if (otp.length != 6 ||
                                      otp.contains(RegExp(r'\D'))) {
                                    AppFlushbar.error(
                                      'Please enter a valid 6-digit OTP.',
                                    );
                                    return;
                                  }

                                  context
                                      .read<GeneralUserForgotPasswordBloc>()
                                      .add(
                                        VerifyVerificationCodeRequested(
                                          emailAddress: email,
                                          verificationCode: otp,
                                        ),
                                      );
                                },
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
                          child: const Text('Verify & Continue'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.go(AppRoutes.loginPath);
                      },
                      child: Text(
                        'Back to Log In',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF37414A),
                        ),
                      ),
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
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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

  InputDecoration get _otpDecoration {
    return InputDecoration(
      counterText: '',
      filled: true,
      fillColor: const Color(0xFFF2F2F2),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
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

class _ForgotPasswordBackground extends StatelessWidget {
  const _ForgotPasswordBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset(
        AppAssets.imgLoginBg,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _BrandFooter extends StatelessWidget {
  const _BrandFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppAssets.icAzista,
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
