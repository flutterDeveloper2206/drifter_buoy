import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/self_test_debug/general_user_self_test_debug_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/self_test_debug/general_user_self_test_debug_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/self_test_debug/general_user_self_test_debug_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GeneralUserSelfTestDebugPage extends StatelessWidget {
  const GeneralUserSelfTestDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE1E4),
      body: SafeArea(
        child: BlocListener<
          GeneralUserSelfTestDebugBloc,
          GeneralUserSelfTestDebugState
        >(
          listenWhen: (p, c) => p.message != c.message,
          listener: (context, state) {
            if (state.message.isEmpty) {
              return;
            }
            if (state.isSuccessMessage) {
              AppFlushbar.success(state.message, context: context);
            } else {
              AppFlushbar.error(state.message, context: context);
            }
            context.read<GeneralUserSelfTestDebugBloc>().add(
              const ClearGeneralUserSelfTestDebugMessage(),
            );
          },
          child: Column(
            children: [
              const _Header(),
              Expanded(
                child:
                    BlocBuilder<
                      GeneralUserSelfTestDebugBloc,
                      GeneralUserSelfTestDebugState
                    >(
                      builder: (context, state) {
                        if (state.status == GeneralUserSelfTestDebugStatus.loading ||
                            state.status == GeneralUserSelfTestDebugStatus.initial) {
                          return const AppLoader();
                        }
                        if (state.status == GeneralUserSelfTestDebugStatus.error) {
                          return AppErrorView(
                            message: state.message,
                            onRetry: () {
                              context.read<GeneralUserSelfTestDebugBloc>().add(
                                const LoadGeneralUserSelfTestDebug(),
                              );
                            },
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: state.actions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final action = state.actions[index];
                            final running = state.runningAction == action &&
                                state.status ==
                                    GeneralUserSelfTestDebugStatus.running;
                            return _ActionTile(
                              title: action,
                              running: running,
                              onTap: running
                                  ? null
                                  : () {
                                      context.read<GeneralUserSelfTestDebugBloc>().add(
                                        RunGeneralUserSelfTestDebugAction(action),
                                      );
                                    },
                            );
                          },
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
                context.go(AppRoutes.setupDetailPath);
              }
            },
            icon: Icons.arrow_back,
          ),
          Expanded(
            child: Center(
              child: Text(
                'Self-Test and Debug',
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

class _ActionTile extends StatelessWidget {
  final String title;
  final bool running;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.title,
    required this.running,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF2A2F34),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (running)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF8B9196),
              ),
          ],
        ),
      ),
    );
  }
}
