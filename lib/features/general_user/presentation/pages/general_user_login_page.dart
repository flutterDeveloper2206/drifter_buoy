import 'package:drifter_buoy/core/constants/app_assets.dart';
import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/injection_container.dart';
import 'package:drifter_buoy/core/utils/widgets/app_elevated_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:drifter_buoy/features/general_user/presentation/bloc/login/general_user_login_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/login/general_user_login_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/login/general_user_login_state.dart';

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

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
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

    return BlocProvider(
      create: (_) => sl<GeneralUserLoginBloc>(),
      child: BlocListener<GeneralUserLoginBloc, GeneralUserLoginState>(
        listener: (context, state) {
          if (state is GeneralUserLoginAuthenticated) {
            context.go(AppRoutes.dashboardPath, extra: state.isAdmin);
            return;
          }

          if (state is GeneralUserLoginError) {
            final msg = state.message.trim().isEmpty
                ? 'Incorrect username or password. Please try again.'
                : state.message;
            AppFlushbar.error(msg);
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            fit: StackFit.expand,
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
                            child: Form(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                                          color: Colors.white.withValues(
                                            alpha: 0.82,
                                          ),
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
                                      'Email or Username',
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
                                          onFieldSubmitted: (_) =>
                                              _onLoginTap(context),
                                          decoration: _fieldDecoration.copyWith(
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                _obscurePasswordNotifier.value =
                                                    !obscure;
                                              },
                                              icon: Icon(
                                                obscure
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                          .visibility_off_outlined,
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
                                        context.go(
                                          AppRoutes.forgotPasswordPath,
                                        );
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
                                      child:
                                          BlocBuilder<
                                            GeneralUserLoginBloc,
                                            GeneralUserLoginState
                                          >(
                                            builder: (context, state) {
                                              final isLoading =
                                                  state
                                                      is GeneralUserLoginLoading;
                                              return AppElevatedButton(
                                                loading: isLoading,
                                                onPressed: isLoading
                                                    ? null
                                                    : () =>
                                                          _onLoginTap(context),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFF256BBB,
                                                  ),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  textStyle: textTheme
                                                      .headlineSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                                child: const Text('Log In'),
                                              );
                                            },
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

  void _onLoginTap(BuildContext innerContext) {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    FocusScope.of(innerContext).unfocus();

    innerContext.read<GeneralUserLoginBloc>().add(
      GeneralUserLoginRequested(
        userName: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  String? _validateEmail(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Email or Username is required';

    // If user typed something like an email, validate format; otherwise treat as username.
    // if (input.contains('@')) {
    //   const emailPattern =
    //       r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
    //   final isValid = RegExp(emailPattern).hasMatch(input);
    //   if (!isValid) return 'Enter a valid email address';
    // }

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
