import 'package:drifter_buoy/core/utils/widgets/app_elevated_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/change_password/general_user_change_password_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/change_password/general_user_change_password_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/change_password/general_user_change_password_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/profile/profile_password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserProfileChangePasswordForm extends StatefulWidget {
  const GeneralUserProfileChangePasswordForm({
    super.key,
    required this.isChangingPasswordNotifier,
    this.userEmail = '',
  });

  final ValueNotifier<bool> isChangingPasswordNotifier;
  final String userEmail;

  @override
  State<GeneralUserProfileChangePasswordForm> createState() =>
      _GeneralUserProfileChangePasswordFormState();
}

class _GeneralUserProfileChangePasswordFormState
    extends State<GeneralUserProfileChangePasswordForm> {
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  late final ValueNotifier<bool> _obscureCurrentPasswordNotifier;
  late final ValueNotifier<bool> _obscureNewPasswordNotifier;
  late final ValueNotifier<bool> _obscureConfirmPasswordNotifier;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _obscureCurrentPasswordNotifier = ValueNotifier<bool>(true);
    _obscureNewPasswordNotifier = ValueNotifier<bool>(true);
    _obscureConfirmPasswordNotifier = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _obscureCurrentPasswordNotifier.dispose();
    _obscureNewPasswordNotifier.dispose();
    _obscureConfirmPasswordNotifier.dispose();
    super.dispose();
  }

  void _clearFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocBuilder<GeneralUserChangePasswordBloc,
        GeneralUserChangePasswordState>(
      builder: (context, changeState) {
        final isLoading = changeState is GeneralUserChangePasswordLoading;

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(bottom: bottomInset + 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ChangePasswordHeaderCard(userEmail: widget.userEmail),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update Password',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF23282D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Use at least 6 characters. Your new password must be '
                      'different from the current one.',
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF616870),
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<bool>(
                      valueListenable: _obscureCurrentPasswordNotifier,
                      builder: (context, obscure, _) {
                        return GeneralUserProfilePasswordField(
                          label: 'Current Password',
                          controller: _currentPasswordController,
                          enabled: !isLoading,
                          obscureText: obscure,
                          textInputAction: TextInputAction.next,
                          onToggleVisibility: () {
                            _obscureCurrentPasswordNotifier.value = !obscure;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<bool>(
                      valueListenable: _obscureNewPasswordNotifier,
                      builder: (context, obscure, _) {
                        return GeneralUserProfilePasswordField(
                          label: 'New Password',
                          controller: _newPasswordController,
                          enabled: !isLoading,
                          obscureText: obscure,
                          textInputAction: TextInputAction.next,
                          onToggleVisibility: () {
                            _obscureNewPasswordNotifier.value = !obscure;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<bool>(
                      valueListenable: _obscureConfirmPasswordNotifier,
                      builder: (context, obscure, _) {
                        return GeneralUserProfilePasswordField(
                          label: 'Confirm New Password',
                          controller: _confirmPasswordController,
                          enabled: !isLoading,
                          obscureText: obscure,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            if (!isLoading) {
                              _onSubmit(context);
                            }
                          },
                          onToggleVisibility: () {
                            _obscureConfirmPasswordNotifier.value = !obscure;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: AppElevatedButton(
                              loading: false,
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      _clearFields();
                                      widget.isChangingPasswordNotifier.value =
                                          false;
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF23282D),
                                disabledForegroundColor: const Color(
                                  0xFF23282D,
                                ).withValues(alpha: 0.65),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: AppElevatedButton(
                              loading: isLoading,
                              onPressed:
                                  isLoading ? null : () => _onSubmit(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF256BBB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Update Password'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSubmit(BuildContext context) {
    FocusScope.of(context).unfocus();

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      AppFlushbar.error('Current password is required', context: context);
      return;
    }

    if (newPassword.isEmpty) {
      AppFlushbar.error('New password is required', context: context);
      return;
    }

    if (newPassword.length < 6) {
      AppFlushbar.error(
        'New password must be at least 6 characters',
        context: context,
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      AppFlushbar.error('Confirm password is required', context: context);
      return;
    }

    if (newPassword != confirmPassword) {
      AppFlushbar.error('New passwords do not match', context: context);
      return;
    }

    if (currentPassword == newPassword) {
      AppFlushbar.error(
        'New password must be different from current password',
        context: context,
      );
      return;
    }

    context.read<GeneralUserChangePasswordBloc>().add(
          ChangeGeneralUserPasswordRequested(
            currentPassword: currentPassword,
            newPassword: newPassword,
            confirmPassword: confirmPassword,
          ),
        );
  }
}

class _ChangePasswordHeaderCard extends StatelessWidget {
  const _ChangePasswordHeaderCard({required this.userEmail});

  final String userEmail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF206BBE).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF206BBE),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Security',
                  style: textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF2A2F34),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail.trim().isNotEmpty
                      ? userEmail.trim()
                      : 'Update your sign-in password',
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF616870),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
