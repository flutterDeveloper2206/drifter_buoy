import 'package:drifter_buoy/core/constants/app_assets.dart';
import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:drifter_buoy/core/utils/widgets/app_elevated_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:drifter_buoy/features/general_user/presentation/bloc/create_password/general_user_create_password_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/create_password/general_user_create_password_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/create_password/general_user_create_password_state.dart';

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
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
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
    final viewInsets = MediaQuery.of(context).viewInsets;

    return BlocListener<
      GeneralUserCreatePasswordBloc,
      GeneralUserCreatePasswordState
    >(
      listener: (context, state) {
        if (state is GeneralUserCreatePasswordSuccess) {
          AppFlushbar.success(state.message);
          context.go(AppRoutes.loginPath);
        } else if (state is GeneralUserCreatePasswordError) {
          AppFlushbar.error(state.message);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _CreatePasswordBackground(),
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
                          child:
                              BlocBuilder<
                                GeneralUserCreatePasswordBloc,
                                GeneralUserCreatePasswordState
                              >(
                                builder: (context, state) {
                                  final isLoading =
                                      state is GeneralUserCreatePasswordLoading;
                                  return IntrinsicHeight(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                              const SizedBox(height: 12),
                              IconButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        context.go(
                                          AppRoutes.forgotPasswordPath,
                                        );
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
                                    enabled: !isLoading,
                                    controller: _newPasswordController,
                                    obscureText: obscure,
                                    decoration: _fieldDecoration.copyWith(
                                      suffixIcon: IconButton(
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                                _obscureNewPasswordNotifier
                                                        .value =
                                                    !obscure;
                                              },
                                        icon: Icon(
                                          obscure
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
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
                                valueListenable:
                                    _obscureConfirmPasswordNotifier,
                                builder: (context, obscure, _) {
                                  return TextField(
                                    enabled: !isLoading,
                                    controller: _confirmPasswordController,
                                    obscureText: obscure,
                                    decoration: _fieldDecoration.copyWith(
                                      suffixIcon: IconButton(
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                                _obscureConfirmPasswordNotifier
                                                        .value =
                                                    !obscure;
                                              },
                                        icon: Icon(
                                          obscure
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
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
                                child: AppElevatedButton(
                                  loading: isLoading,
                                  onPressed: isLoading
                                      ? null
                                      : () => _onSubmit(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF256BBB),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  child: const Text('Submit'),
                                ),
                              ),
                              const Spacer(),
                              const Center(child: _BrandFooter()),
                              const SizedBox(height: 18),
                                      ],
                                    ),
                                  );
                                },
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
    );
  }

  void _onSubmit(BuildContext innerContext) {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty) {
      AppFlushbar.error('New password is required');
      return;
    }

    if (newPassword.length < 6) {
      AppFlushbar.error('Password must be at least 6 characters');
      return;
    }

    if (confirmPassword.isEmpty) {
      AppFlushbar.error('Confirm password is required');
      return;
    }

    if (newPassword != confirmPassword) {
      AppFlushbar.error('Passwords do not match');
      return;
    }

    innerContext.read<GeneralUserCreatePasswordBloc>().add(
      GeneralUserCreatePasswordRequested(
        newPassword: newPassword,
        confirmPassword: confirmPassword,
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
