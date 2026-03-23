import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile/general_user_profile_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile/general_user_profile_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile/general_user_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GeneralUserProfilePage extends StatelessWidget {
  const GeneralUserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE1E4),
      body: SafeArea(
        child: BlocListener<GeneralUserProfileBloc, GeneralUserProfileState>(
          listenWhen: (previous, current) => previous.message != current.message,
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
          child: Column(
            children: [
              const _Header(),
              Expanded(
                child: BlocBuilder<GeneralUserProfileBloc, GeneralUserProfileState>(
                  builder: (context, state) {
                    if (state.status == GeneralUserProfileStatus.loading ||
                        state.status == GeneralUserProfileStatus.initial) {
                      return const AppLoader();
                    }

                    if (state.status == GeneralUserProfileStatus.error ||
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
                      child: Column(
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
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: state.isLoggingOut
                                  ? null
                                  : () {
                                      context.read<GeneralUserProfileBloc>().add(
                                        const RequestGeneralUserLogout(),
                                      );
                                    },
                              icon: const Icon(Icons.logout_rounded),
                              label: Text(
                                state.isLoggingOut ? 'Logging out...' : 'Log Out',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC62828),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(
                                  0xFFC62828,
                                ).withValues(alpha: 0.65),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
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
