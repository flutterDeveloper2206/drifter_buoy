import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/core/utils/widgets/app_elevated_button.dart';
import 'package:drifter_buoy/core/utils/injection_container.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile/general_user_profile_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile/general_user_profile_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile/general_user_profile_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile_update/general_user_update_profile_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile_update/general_user_update_profile_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile_update/general_user_update_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GeneralUserProfilePage extends StatefulWidget {
  const GeneralUserProfilePage({super.key});

  @override
  State<GeneralUserProfilePage> createState() => _GeneralUserProfilePageState();
}

class _GeneralUserProfilePageState extends State<GeneralUserProfilePage> {
  final ValueNotifier<bool> _isEditingNotifier = ValueNotifier<bool>(false);

  late final TextEditingController _firstNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _middleNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _isEditingNotifier.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GeneralUserUpdateProfileBloc>(
      create: (_) => sl<GeneralUserUpdateProfileBloc>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFDDE1E4),
        body: SafeArea(
          child: MultiBlocListener(
            listeners: [
              BlocListener<GeneralUserProfileBloc, GeneralUserProfileState>(
                listenWhen: (previous, current) =>
                    previous.message != current.message,
                listener: (context, state) {
                  if (state.message.isEmpty) {
                    return;
                  }

                  if (state.logoutSuccess) {
                    AppFlushbar.success(state.message, context: context);
                    context.read<GeneralUserProfileBloc>().add(
                      const ClearGeneralUserProfileMessage(),
                    );
                    context.go(AppRoutes.loginPath);
                    return;
                  }

                  AppFlushbar.info(state.message, context: context);
                  context.read<GeneralUserProfileBloc>().add(
                    const ClearGeneralUserProfileMessage(),
                  );
                },
              ),
              BlocListener<GeneralUserProfileBloc, GeneralUserProfileState>(
                listenWhen: (previous, current) =>
                    current is GeneralUserProfileLoaded,
                listener: (context, state) {
                  if (state is! GeneralUserProfileLoaded) return;
                  final data = state.data;
                  _firstNameController.text = data.firstName;
                  _middleNameController.text = data.middleName;
                  _lastNameController.text = data.lastName;
                  _emailController.text = data.email;
                  _phoneController.text = data.phone;
                },
              ),
              BlocListener<
                GeneralUserUpdateProfileBloc,
                GeneralUserUpdateProfileState
              >(
                listenWhen: (previous, current) =>
                    previous != current &&
                    current is! GeneralUserUpdateProfileInitial,
                listener: (context, state) {
                  if (state is GeneralUserUpdateProfileSuccess) {
                    AppFlushbar.success(state.message, context: context);
                    _isEditingNotifier.value = false;
                    context.read<GeneralUserProfileBloc>().add(
                      const LoadGeneralUserProfile(),
                    );
                    return;
                  }

                  if (state is GeneralUserUpdateProfileError) {
                    AppFlushbar.error(state.message, context: context);
                    return;
                  }
                },
              ),
            ],
            child: Column(
              children: [
                const _Header(),
                Expanded(
                  child:
                      BlocBuilder<
                        GeneralUserProfileBloc,
                        GeneralUserProfileState
                      >(
                        builder: (context, state) {
                          if (state is GeneralUserProfileLoading ||
                              state is GeneralUserProfileInitial) {
                            return const AppLoader();
                          }

                          if (state is GeneralUserProfileError ||
                              state.data == null) {
                            return AppErrorView(
                              message: state.message.isNotEmpty
                                  ? state.message
                                  : 'Unable to load profile.',
                              onRetry: () {
                                context.read<GeneralUserProfileBloc>().add(
                                  const LoadGeneralUserProfile(),
                                );
                              },
                            );
                          }

                          final data = state.data!;
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: ValueListenableBuilder<bool>(
                              valueListenable: _isEditingNotifier,
                              builder: (context, isEditing, _) {
                                if (!isEditing) {
                                  return Column(
                                    children: [
                                      _ProfileCard(data: data),
                                      const SizedBox(height: 14),
                                      _InfoTile(
                                        icon: Icons.badge_outlined,
                                        title: 'Full Name',
                                        value: data.fullName,
                                      ),
                                      const SizedBox(height: 10),
                                      _InfoTile(
                                        icon: Icons.mail_outline_rounded,
                                        title: 'Email',
                                        value: data.email,
                                      ),
                                      const SizedBox(height: 10),
                                      _InfoTile(
                                        icon: Icons.security_outlined,
                                        title: 'Role',
                                        value: data.role,
                                      ),
                                      const SizedBox(height: 10),
                                      _InfoTile(
                                        icon: Icons.phone_outlined,
                                        title: 'Phone',
                                        value: data.phone,
                                      ),
                                      const SizedBox(height: 14),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: AppElevatedButton(
                                          loading: false,
                                          onPressed: () {
                                            _isEditingNotifier.value = true;
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF1F88D1,
                                            ),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text('Edit Profile'),
                                        ),
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: AppElevatedButton(
                                          loading: state.isLoggingOut,
                                          onPressed: state.isLoggingOut
                                              ? null
                                              : () {
                                                  context
                                                      .read<
                                                        GeneralUserProfileBloc
                                                      >()
                                                      .add(
                                                        const RequestGeneralUserLogout(),
                                                      );
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFC62828,
                                            ),
                                            foregroundColor: Colors.white,
                                            disabledBackgroundColor:
                                                const Color(
                                                  0xFFC62828,
                                                ).withValues(alpha: 0.65),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text('Log Out'),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return _EditProfileForm(
                                  userId: data.userId,
                                  firstNameController: _firstNameController,
                                  middleNameController: _middleNameController,
                                  lastNameController: _lastNameController,
                                  emailController: _emailController,
                                  phoneController: _phoneController,
                                  isEditingNotifier: _isEditingNotifier,
                                );
                              },
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditProfileForm extends StatelessWidget {
  final String userId;
  final TextEditingController firstNameController;
  final TextEditingController middleNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final ValueNotifier<bool> isEditingNotifier;

  const _EditProfileForm({
    required this.userId,
    required this.firstNameController,
    required this.middleNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.isEditingNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<
      GeneralUserUpdateProfileBloc,
      GeneralUserUpdateProfileState
    >(
      builder: (context, updateState) {
        final isUpdating = updateState is GeneralUserUpdateProfileLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileCard(
              data: GeneralUserProfileData(
                userId: userId,
                firstName: firstNameController.text.trim(),
                middleName: middleNameController.text.trim(),
                lastName: lastNameController.text.trim(),
                fullName:
                    '${firstNameController.text.trim()} ${middleNameController.text.trim()} ${lastNameController.text.trim()}'
                        .replaceAll(RegExp(r'\s+'), ' ')
                        .trim(),
                email: emailController.text.trim(),
                role: '',
                phone: phoneController.text.trim(),
              ),
            ),
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
                    'Edit Profile',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF23282D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _LabeledTextField(
                    label: 'First Name',
                    controller: firstNameController,
                    enabled: !isUpdating,
                  ),
                  const SizedBox(height: 12),
                  _LabeledTextField(
                    label: 'Middle Name',
                    controller: middleNameController,
                    enabled: !isUpdating,
                  ),
                  const SizedBox(height: 12),
                  _LabeledTextField(
                    label: 'Last Name',
                    controller: lastNameController,
                    enabled: !isUpdating,
                  ),
                  const SizedBox(height: 12),
                  _LabeledTextField(
                    label: 'Mobile Number',
                    controller: phoneController,
                    enabled: !isUpdating,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _LabeledTextField(
                    label: 'Email Address',
                    controller: emailController,
                    enabled: !isUpdating,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: AppElevatedButton(
                          loading: false,
                          onPressed: isUpdating
                              ? null
                              : () => isEditingNotifier.value = false,
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppElevatedButton(
                          loading: isUpdating,
                          onPressed: isUpdating
                              ? null
                              : () {
                                  final firstName = firstNameController.text
                                      .trim();
                                  final middleName = middleNameController.text
                                      .trim();
                                  final lastName = lastNameController.text
                                      .trim();
                                  final phone = phoneController.text.trim();
                                  final email = emailController.text.trim();

                                  if (firstName.isEmpty) {
                                    AppFlushbar.error(
                                      'First name is required',
                                      context: context,
                                    );
                                    return;
                                  }
                                  if (lastName.isEmpty) {
                                    AppFlushbar.error(
                                      'Last name is required',
                                      context: context,
                                    );
                                    return;
                                  }
                                  if (phone.isEmpty) {
                                    AppFlushbar.error(
                                      'Phone is required',
                                      context: context,
                                    );
                                    return;
                                  }
                                  if (email.isEmpty || !email.contains('@')) {
                                    AppFlushbar.error(
                                      'Enter a valid email',
                                      context: context,
                                    );
                                    return;
                                  }

                                  context
                                      .read<GeneralUserUpdateProfileBloc>()
                                      .add(
                                        UpdateGeneralUserProfileRequested(
                                          userId: userId,
                                          firstName: firstName,
                                          middleName: middleName,
                                          lastName: lastName,
                                          mobileNumber: phone,
                                          emailAddress: email,
                                        ),
                                      );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF256BBB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType keyboardType;

  const _LabeledTextField({
    required this.label,
    required this.controller,
    required this.enabled,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3F4750),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          enabled: enabled,
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFC2C7CC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF3A86D1),
                width: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          AppIconCircleButton(
            onTap: () {
              if (GoRouter.of(context).canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.dashboardPath);
              }
            },
            icon: Icons.arrow_back,
          ),
          Expanded(
            child: Center(
              child: Text(
                'Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF262C31),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final GeneralUserProfileData data;

  const _ProfileCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF206BBE),
            child: Text(
              data.initials,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.fullName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF2A2F34),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.email,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF356EA7)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF7B8288),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF2B3138),
                    fontWeight: FontWeight.w700,
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
