import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/theme/app_typography.dart';
import 'package:drifter_buoy/core/utils/widgets/app_elevated_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_setup/general_user_buoy_setup_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_setup/general_user_buoy_setup_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_setup/general_user_buoy_setup_state.dart';
import 'package:drifter_buoy/core/bluetooth/ble_connection_service.dart';
import 'package:drifter_buoy/core/bluetooth/drifter_ble_line_utils.dart';
import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/core/utils/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GeneralUserBuoySetupPage extends StatefulWidget {
  const GeneralUserBuoySetupPage({super.key});

  @override
  State<GeneralUserBuoySetupPage> createState() =>
      _GeneralUserBuoySetupPageState();
}

class _GeneralUserBuoySetupPageState extends State<GeneralUserBuoySetupPage> {
  bool _hasSentInitialCommands = false;
  late TextEditingController _stationIdController;
  late TextEditingController _stationNameController;

  @override
  void initState() {
    super.initState();
    final state = context.read<GeneralUserBuoySetupBloc>().state;
    _stationIdController = TextEditingController(text: state.stationId);
    _stationNameController = TextEditingController(text: state.stationName);
  }

  @override
  void dispose() {
    _stationIdController.dispose();
    _stationNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE1E4),
      body: SafeArea(
        child: BlocListener<GeneralUserBuoySetupBloc, GeneralUserBuoySetupState>(
          listenWhen: (p, c) =>
              p.message != c.message ||
              p.status != c.status ||
              p.stationId != c.stationId ||
              p.stationName != c.stationName,
          listener: (context, state) {
            if (state.status == GeneralUserBuoySetupStatus.loaded) {
              if (!_hasSentInitialCommands) {
                _hasSentInitialCommands = true;
                _getInitialBuoySettings(context);
              }
              if (_stationIdController.text != state.stationId) {
                _stationIdController.text = state.stationId;
              }
              if (_stationNameController.text != state.stationName) {
                _stationNameController.text = state.stationName;
              }
            }
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
                              'Buoy Information',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: const Color(0xFF2E3238),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _Field(
                              label: 'Buoy ID',
                              controller: _stationIdController,
                              maxLength: 8,
                            ),
                            _Field(
                              label: 'Buoy Name',
                              controller: _stationNameController,
                              maxLength: 16,
                            ),
                            //   formFieldKey: ValueKey(
                            //     'txInterval-$fieldsMounted',
                            //   ),
                            //   onChanged: (v) => context
                            //       .read<GeneralUserBuoySetupBloc>()
                            //       .add(
                            //         UpdateGeneralUserBuoySetupField(
                            //           BuoySetupField.transmissionInterval,
                            //           v,
                            //         ),
                            //       ),
                            // ),
                            // _Field(
                            //   label: 'Transmission Start Time',
                            //   value: state.transmissionStartTime,
                            //   formFieldKey: ValueKey(
                            //     'txStart-$fieldsMounted',
                            //   ),
                            //   onChanged: (v) => context
                            //       .read<GeneralUserBuoySetupBloc>()
                            //       .add(
                            //         UpdateGeneralUserBuoySetupField(
                            //           BuoySetupField.transmissionStartTime,
                            //           v,
                            //         ),
                            //       ),
                            // ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: AppElevatedButton(
                                loading: saving,
                                onPressed: saving
                                    ? null
                                    : () {
                                        final bloc = context
                                            .read<GeneralUserBuoySetupBloc>();
                                        final id = _stationIdController.text;
                                        final name =
                                            _stationNameController.text;
                                        bloc.add(
                                          UpdateGeneralUserBuoySetupField(
                                            BuoySetupField.stationId,
                                            id,
                                          ),
                                        );
                                        bloc.add(
                                          UpdateGeneralUserBuoySetupField(
                                            BuoySetupField.stationName,
                                            name,
                                          ),
                                        );
                                        bloc.add(
                                          const SaveGeneralUserBuoySetup(),
                                        );
                                        _sendBleSetupCommands(id, name);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF206BBE),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Save Set Up'),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
  final String? value;
  final Key? formFieldKey;
  final TextEditingController? controller;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.label,
    this.value,
    this.formFieldKey,
    this.controller,
    this.maxLength,
    this.onChanged,
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
            style: Theme.of(
              context,
            ).textTheme.compactFieldLabel(const Color(0xFF4A4A4A)),
          ),
          const SizedBox(height: 6),
          TextFormField(
            key: formFieldKey,
            controller: controller,
            initialValue: controller == null ? value : null,
            maxLength: maxLength,
            onChanged: onChanged,
            style: Theme.of(
              context,
            ).textTheme.compactFieldInput(const Color(0xFF2E3238)),
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

void _sendBleSetupCommands(String stationId, String stationName) {
  final ble = sl<BleConnectionService>();
  if (ble.connectedRemoteId != null) {
    Future.microtask(() async {
      try {
        final formattedId = stationId.trim().toUpperCase().padRight(8, ' ');
        final formattedName = stationName.trim().padRight(16, ' ');
        AppLogger.i('Sending BLE setup: ID=$formattedId, Name=$formattedName');
        await ble.sendDrifterAsciiCommand(
          '?06,$formattedId,#',
          const Duration(seconds: 15),
        );
        await ble.sendDrifterAsciiCommand(
          '?07,$formattedName,#',
          const Duration(seconds: 15),
        );
        AppLogger.i('Sent BLE setup commands successfully');
      } catch (e) {
        AppLogger.e('Failed to send BLE setup commands: $e');
      }
    });
  }
}

void _getInitialBuoySettings(BuildContext context) {
  final ble = sl<BleConnectionService>();
  if (ble.connectedRemoteId != null) {
    Future.microtask(() async {
      try {
        AppLogger.i(
          'Sending initially fetch ?04,,# general parameters command',
        );
        final response = await ble.sendDrifterAsciiCommand(
          '?04,,#',
          const Duration(seconds: 15),
        );
        AppLogger.i('Received ?04 response: $response');

        final trimmed = response.trim();
        final noHash = stripDrifterLineTerminator(trimmed);
        final parts = noHash.split(',').map((e) => e.trim()).toList();
        if (parts.length > 2) {
          final start =
              (parts.first.startsWith(r'$') || parts.first.startsWith('?'))
              ? 1
              : 0;
          if (start < parts.length) {
            final stationId = parts[start].trim();
            final stationName = (start + 1 < parts.length)
                ? parts[start + 1].trim()
                : '';

            if (context.mounted && stationId.isNotEmpty) {
              context.read<GeneralUserBuoySetupBloc>().add(
                UpdateGeneralUserBuoySetupField(
                  BuoySetupField.stationId,
                  stationId,
                ),
              );
            }
            if (context.mounted && stationName.isNotEmpty) {
              context.read<GeneralUserBuoySetupBloc>().add(
                UpdateGeneralUserBuoySetupField(
                  BuoySetupField.stationName,
                  stationName,
                ),
              );
            }
          }
        }
      } catch (e) {
        AppLogger.e('Failed to fetch initial buoy settings via ?04: $e');
      }
    });
  }
}
