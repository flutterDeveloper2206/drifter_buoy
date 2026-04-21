import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/core/utils/widgets/app_elevated_button.dart';
import 'package:drifter_buoy/core/utils/injection_container.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile/general_user_profile_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile/general_user_profile_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile/general_user_profile_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile_update/general_user_update_profile_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile_update/general_user_update_profile_state.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/profile/profile_card.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/profile/profile_edit_form.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/profile/profile_header.dart';
import 'package:drifter_buoy/features/general_user/presentation/widgets/profile/profile_info_tile.dart';
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
                const GeneralUserProfileHeader(),
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
                                      GeneralUserProfileCard(data: data),
                                      const SizedBox(height: 14),
                                      GeneralUserProfileInfoTile(
                                        icon: Icons.badge_outlined,
                                        title: 'Full Name',
                                        value: data.fullName,
                                      ),
                                      const SizedBox(height: 10),
                                      GeneralUserProfileInfoTile(
                                        icon: Icons.mail_outline_rounded,
                                        title: 'Email',
                                        value: data.email,
                                      ),
                                      const SizedBox(height: 10),
                                      GeneralUserProfileInfoTile(
                                        icon: Icons.security_outlined,
                                        title: 'Role',
                                        value: data.role,
                                      ),
                                      const SizedBox(height: 10),
                                      GeneralUserProfileInfoTile(
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
                                      SizedBox(height: 20,),
                                      Text('V 1.0.2'),
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

                                return GeneralUserProfileEditForm(
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
