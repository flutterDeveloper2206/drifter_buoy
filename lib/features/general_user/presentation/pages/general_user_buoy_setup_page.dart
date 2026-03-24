import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_setup/general_user_buoy_setup_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_setup/general_user_buoy_setup_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_setup/general_user_buoy_setup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GeneralUserBuoySetupPage extends StatelessWidget {
  const GeneralUserBuoySetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE1E4),
      body: SafeArea(
        child: BlocListener<GeneralUserBuoySetupBloc, GeneralUserBuoySetupState>(
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
          },
          child: BlocBuilder<GeneralUserBuoySetupBloc, GeneralUserBuoySetupState>(
            builder: (context, state) {
              if (state.status == GeneralUserBuoySetupStatus.loading ||
                  state.status == GeneralUserBuoySetupStatus.initial) {
                return const AppLoader();
              }

              final saving = state.status == GeneralUserBuoySetupStatus.saving;
              return Column(
                children: [
                  const _Header(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Station Information',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: const Color(0xFF2E3238),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _Field(
                              label: 'Station ID',
                              value: state.stationId,
                              onChanged: (v) => context
                                  .read<GeneralUserBuoySetupBloc>()
                                  .add(
                                    UpdateGeneralUserBuoySetupField(
                                      BuoySetupField.stationId,
                                      v,
                                    ),
                                  ),
                            ),
                            _Field(
                              label: 'Station Name',
                              value: state.stationName,
                              onChanged: (v) => context
                                  .read<GeneralUserBuoySetupBloc>()
                                  .add(
                                    UpdateGeneralUserBuoySetupField(
                                      BuoySetupField.stationName,
                                      v,
                                    ),
                                  ),
                            ),
                            _Field(
                              label: 'Transmission Interval',
                              value: state.transmissionInterval,
                              onChanged: (v) => context
                                  .read<GeneralUserBuoySetupBloc>()
                                  .add(
                                    UpdateGeneralUserBuoySetupField(
                                      BuoySetupField.transmissionInterval,
                                      v,
                                    ),
                                  ),
                            ),
                            _Field(
                              label: 'Transmission Start Time',
                              value: state.transmissionStartTime,
                              onChanged: (v) => context
                                  .read<GeneralUserBuoySetupBloc>()
                                  .add(
                                    UpdateGeneralUserBuoySetupField(
                                      BuoySetupField.transmissionStartTime,
                                      v,
                                    ),
                                  ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: saving
                                    ? null
                                    : () => context
                                          .read<GeneralUserBuoySetupBloc>()
                                          .add(const SaveGeneralUserBuoySetup()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF206BBE),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(saving ? 'Saving...' : 'Save Set Up'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
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
                'Buoy Set Up',
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

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _Field({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF4A4A4A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: value,
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFECECEC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD2D6DA)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD2D6DA)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
