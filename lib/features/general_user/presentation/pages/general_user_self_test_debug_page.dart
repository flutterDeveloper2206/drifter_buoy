import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/theme/app_typography.dart';
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

class GeneralUserSelfTestDebugPage extends StatefulWidget {
  const GeneralUserSelfTestDebugPage({super.key});

  @override
  State<GeneralUserSelfTestDebugPage> createState() =>
      _GeneralUserSelfTestDebugPageState();
}

class _GeneralUserSelfTestDebugPageState
    extends State<GeneralUserSelfTestDebugPage> {
  bool _isSetStationIdDialogOpen = false;
  bool _isMeasurementTimeDialogOpen = false;
  bool _isTransmitterFrequencyDialogOpen = false;
  bool _isSetAttenuationDialogOpen = false;
  bool _isRadioSondeTransmitterIdDialogOpen = false;
  bool _isTransmitterTestDialogOpen = false;
  bool _isCheckStatusDialogOpen = false;

  Future<void> _showSetStationIdDialog(
    BuildContext context,
    String currentStationId,
  ) async {
    if (_isSetStationIdDialogOpen) {
      return;
    }
    _isSetStationIdDialogOpen = true;
    var draftStationId = currentStationId;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Set Station Id'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter 8-character station id',
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6A7178),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    key: ValueKey('set-station-id-$currentStationId'),
                    initialValue: currentStationId,
                    maxLength: 8,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (v) => draftStationId = v,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'XXXXXXXX',
                      counterText: '',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  FocusScope.of(ctx).unfocus();
                  Navigator.of(ctx).pop();
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  FocusScope.of(ctx).unfocus();
                  context.read<GeneralUserSelfTestDebugBloc>().add(
                    SubmitGeneralUserSetStationId(draftStationId),
                  );
                  Navigator.of(ctx).pop();
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      );
      if (context.mounted) {
        context.read<GeneralUserSelfTestDebugBloc>().add(
          const ClearGeneralUserSetStationIdPrompt(),
        );
      }
    } finally {
      _isSetStationIdDialogOpen = false;
    }
  }

  Future<void> _showMeasurementStartTimeDialog(
    BuildContext context,
    String currentTime,
  ) async {
    if (_isMeasurementTimeDialogOpen) {
      return;
    }
    _isMeasurementTimeDialogOpen = true;
    var selected =
        _parseTimeOfDay(currentTime) ?? const TimeOfDay(hour: 0, minute: 0);

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setLocalState) {
              final value = _formatTime(selected);
              return AlertDialog(
                title: const Text('Measurement Start Time'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current/Picked time: $value',
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF2A2F34),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: ctx,
                          initialTime: selected,
                        );
                        if (picked == null) {
                          return;
                        }
                        setLocalState(() {
                          selected = picked;
                        });
                      },
                      icon: const Icon(Icons.access_time_rounded),
                      label: const Text('Pick Time'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      FocusScope.of(ctx).unfocus();
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      FocusScope.of(ctx).unfocus();
                      context.read<GeneralUserSelfTestDebugBloc>().add(
                        SubmitGeneralUserMeasurementStartTime(
                          _formatTime(selected),
                        ),
                      );
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Update'),
                  ),
                ],
              );
            },
          );
        },
      );
      if (context.mounted) {
        context.read<GeneralUserSelfTestDebugBloc>().add(
          const ClearGeneralUserMeasurementStartTimePrompt(),
        );
      }
    } finally {
      _isMeasurementTimeDialogOpen = false;
    }
  }

  TimeOfDay? _parseTimeOfDay(String value) {
    final m = RegExp(
      r'^(\d{2}):(\d{2})(?::(\d{2}))?$',
    ).firstMatch(value.trim());
    if (m == null) {
      return null;
    }
    final hh = int.tryParse(m.group(1) ?? '');
    final mm = int.tryParse(m.group(2) ?? '');
    if (hh == null || mm == null || hh < 0 || hh > 23 || mm < 0 || mm > 59) {
      return null;
    }
    return TimeOfDay(hour: hh, minute: mm);
  }

  String _formatTime(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm:00';
  }

  Future<void> _showTransmitterFrequencyDialog(
    BuildContext context,
    int currentType,
    String currentFfff,
  ) async {
    if (_isTransmitterFrequencyDialogOpen) {
      return;
    }
    _isTransmitterFrequencyDialogOpen = true;
    var draftType = currentType == 1 ? 1 : 0;
    var draftFfff = currentFfff;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setLocalState) {
              return AlertDialog(
                title: const Text('Set/Get transmitter frequency'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: draftType,
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('UHF (N=0)')),
                          DropdownMenuItem(
                            value: 1,
                            child: Text('Radio Sonde (N=1)'),
                          ),
                        ],
                        onChanged: (v) {
                          setLocalState(() {
                            draftType = v ?? 0;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Transmitter type',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: currentFfff,
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        onChanged: (v) => draftFfff = v,
                        decoration: const InputDecoration(
                          labelText: 'Frequency (FFFF)',
                          border: OutlineInputBorder(),
                          hintText: '4025',
                          counterText: '',
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      FocusScope.of(ctx).unfocus();
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      FocusScope.of(ctx).unfocus();
                      context.read<GeneralUserSelfTestDebugBloc>().add(
                        SubmitGeneralUserTransmitterFrequency(
                          transmitterType: draftType,
                          frequencyValue: draftFfff,
                        ),
                      );
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Update'),
                  ),
                ],
              );
            },
          );
        },
      );
      if (context.mounted) {
        context.read<GeneralUserSelfTestDebugBloc>().add(
          const ClearGeneralUserTransmitterFrequencyPrompt(),
        );
      }
    } finally {
      _isTransmitterFrequencyDialogOpen = false;
    }
  }

  Future<void> _showSetAttenuationDialog(
    BuildContext context,
    int currentType,
    String currentXx,
  ) async {
    if (_isSetAttenuationDialogOpen) {
      return;
    }
    _isSetAttenuationDialogOpen = true;
    var draftType = currentType == 1 ? 1 : 0;
    var draftXx = currentXx;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setLocalState) {
              return AlertDialog(
                title: const Text('Set Attenuation'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: draftType,
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('UHF (N=0)')),
                          DropdownMenuItem(
                            value: 1,
                            child: Text('Radio Sonde (N=1)'),
                          ),
                        ],
                        onChanged: (v) {
                          setLocalState(() {
                            draftType = v ?? 0;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Transmitter type',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: currentXx,
                        maxLength: 2,
                        keyboardType: TextInputType.number,
                        onChanged: (v) => draftXx = v,
                        decoration: const InputDecoration(
                          labelText: 'Attenuation (xx)',
                          border: OutlineInputBorder(),
                          hintText: '05',
                          counterText: '',
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      FocusScope.of(ctx).unfocus();
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      FocusScope.of(ctx).unfocus();
                      context.read<GeneralUserSelfTestDebugBloc>().add(
                        SubmitGeneralUserSetAttenuation(
                          transmitterType: draftType,
                          attenuationValue: draftXx,
                        ),
                      );
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Update'),
                  ),
                ],
              );
            },
          );
        },
      );
      if (context.mounted) {
        context.read<GeneralUserSelfTestDebugBloc>().add(
          const ClearGeneralUserSetAttenuationPrompt(),
        );
      }
    } finally {
      _isSetAttenuationDialogOpen = false;
    }
  }

  Future<void> _showRadioSondeTransmitterIdDialog(
    BuildContext context,
    String currentId,
  ) async {
    if (_isRadioSondeTransmitterIdDialogOpen) {
      return;
    }
    _isRadioSondeTransmitterIdDialogOpen = true;
    var draftId = currentId;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Get station ID of Radio sonde Transmitter'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter 5-character transmitter station id',
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6A7178),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: currentId,
                    maxLength: 5,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (v) => draftId = v,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'XXXXX',
                      counterText: '',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  FocusScope.of(ctx).unfocus();
                  Navigator.of(ctx).pop();
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  FocusScope.of(ctx).unfocus();
                  context.read<GeneralUserSelfTestDebugBloc>().add(
                    SubmitGeneralUserRadioSondeTransmitterId(draftId),
                  );
                  Navigator.of(ctx).pop();
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      );
      if (context.mounted) {
        context.read<GeneralUserSelfTestDebugBloc>().add(
          const ClearGeneralUserRadioSondeTransmitterIdPrompt(),
        );
      }
    } finally {
      _isRadioSondeTransmitterIdDialogOpen = false;
    }
  }

  Future<void> _showTransmitterTestDialog(
    BuildContext context,
    SelfTestTransmitterTestPrompt prompt,
  ) async {
    if (_isTransmitterTestDialogOpen) {
      return;
    }
    _isTransmitterTestDialogOpen = true;
    var selectedN = prompt.plainCarrierOn
        ? 0
        : prompt.modulationOn
        ? 1
        : prompt.prbsOn
        ? 2
        : 0;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setLocalState) {
              return AlertDialog(
                title: const Text('Transmitter Test'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose one test mode (N). Only one can be active. '
                        'Update turns the selected mode ON and the others OFF.',
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6A7178),
                        ),
                      ),
                      const SizedBox(height: 8),
                      RadioGroup<int>(
                        groupValue: selectedN,
                        onChanged: (v) {
                          if (v != null) {
                            setLocalState(() => selectedN = v);
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile<int>(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              value: 0,
                              title: const Text('Plain carrier (N = 0)'),
                            ),
                            RadioListTile<int>(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              value: 1,
                              title: const Text('Modulation (N = 1)'),
                            ),
                            RadioListTile<int>(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              value: 2,
                              title: const Text('PRBS (N = 2)'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      FocusScope.of(ctx).unfocus();
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      FocusScope.of(ctx).unfocus();
                      context.read<GeneralUserSelfTestDebugBloc>().add(
                        SubmitGeneralUserTransmitterTest(
                          plainCarrierOn: selectedN == 0,
                          modulationOn: selectedN == 1,
                          prbsOn: selectedN == 2,
                        ),
                      );
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Update'),
                  ),
                ],
              );
            },
          );
        },
      );
      if (context.mounted) {
        context.read<GeneralUserSelfTestDebugBloc>().add(
          const ClearGeneralUserTransmitterTestPrompt(),
        );
      }
    } finally {
      _isTransmitterTestDialogOpen = false;
    }
  }

  Future<void> _showCheckStatusDialog(
    BuildContext context,
    SelfTestCheckStatusPrompt prompt,
  ) async {
    if (_isCheckStatusDialogOpen) {
      return;
    }
    _isCheckStatusDialogOpen = true;
    try {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Check Status'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _checkStatusSectionTitle(ctx, 'Peripheral status (PP)'),
                _checkStatusValueLine(ctx, prompt.peripheralStatus),
                const SizedBox(height: 10),
                _checkStatusSectionTitle(ctx, 'GPRS server status (GG × 4)'),
                _checkStatusValueLine(ctx, 'Primary: ${prompt.gprsPrimary}'),
                _checkStatusValueLine(
                  ctx,
                  'Secondary: ${prompt.gprsSecondary}',
                ),
                _checkStatusValueLine(ctx, 'Third: ${prompt.gprsThird}'),
                _checkStatusValueLine(ctx, 'Factory: ${prompt.gprsFactory}'),
                const SizedBox(height: 10),
                _checkStatusSectionTitle(ctx, 'Memory 1 fail (F1)'),
                _checkStatusOkNotOk(ctx, prompt.memory1Fail),
                _checkStatusSectionTitle(ctx, 'Memory 1 test (MT1)'),
                _checkStatusOkNotOk(ctx, prompt.memory1Test),
                const SizedBox(height: 6),
                _checkStatusSectionTitle(ctx, 'Memory 2 fail (F2)'),
                _checkStatusOkNotOk(ctx, prompt.memory2Fail),
                _checkStatusSectionTitle(ctx, 'Memory 2 test (MT2)'),
                _checkStatusOkNotOk(ctx, prompt.memory2Test),
                const SizedBox(height: 6),
                _checkStatusSectionTitle(ctx, 'Battery charging (CH)'),
                _checkStatusCharging(ctx, prompt.chargeStatus),
                const SizedBox(height: 10),
                _checkStatusSectionTitle(ctx, 'Data logger firmware (DL)'),
                _checkStatusValueLine(
                  ctx,
                  prompt.firmwareVersion.trim().isEmpty
                      ? '—'
                      : prompt.firmwareVersion.trim(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      if (context.mounted) {
        context.read<GeneralUserSelfTestDebugBloc>().add(
          const ClearGeneralUserCheckStatusPrompt(),
        );
      }
    } finally {
      _isCheckStatusDialogOpen = false;
    }
  }

  static const Color _checkOkGreen = Color(0xFF1B5E20);
  static const Color _checkBadRed = Color(0xFFB3261E);
  static const Color _checkWarnAmber = Color(0xFFBF360C);

  Widget _checkStatusSectionTitle(BuildContext ctx, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 2),
      child: Text(
        title,
        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF1D2329),
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _checkStatusValueLine(BuildContext ctx, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        text.isEmpty ? '—' : text,
        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF2A2F34),
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _checkStatusOkNotOk(BuildContext ctx, String raw) {
    final v = int.tryParse(raw.trim());
    late final String line;
    late final Color color;
    if (v == 0) {
      line = '0 — OK';
      color = _checkOkGreen;
    } else if (v == 1) {
      line = '1 — Not OK';
      color = _checkBadRed;
    } else {
      line = raw.isEmpty ? '—' : raw;
      color = const Color(0xFF5C6368);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        line,
        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _checkStatusCharging(BuildContext ctx, String raw) {
    final t = raw.trim();
    if (t.isEmpty) {
      return Text(
        'Not reported (CH omitted before firmware in this response).',
        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF5C6368),
          fontSize: 13,
        ),
      );
    }
    final v = int.tryParse(t);
    late final String line;
    late final Color color;
    if (v == 0) {
      line = '0 — Charging ON';
      color = _checkOkGreen;
    } else if (v == 1) {
      line = '1 — Charging OFF';
      color = _checkWarnAmber;
    } else if (v == 2) {
      line = '2 — Fault';
      color = _checkBadRed;
    } else {
      line = t;
      color = const Color(0xFF5C6368);
    }
    return Text(
      line,
      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE1E4),
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<
              GeneralUserSelfTestDebugBloc,
              GeneralUserSelfTestDebugState
            >(
              listenWhen: (p, c) =>
                  c.message.isNotEmpty &&
                  c.message != p.message &&
                  c.status == GeneralUserSelfTestDebugStatus.loaded,
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
            ),
            BlocListener<
              GeneralUserSelfTestDebugBloc,
              GeneralUserSelfTestDebugState
            >(
              listenWhen: (p, c) =>
                  c.measurementTimePrompt != null &&
                  c.measurementTimePrompt != p.measurementTimePrompt,
              listener: (context, state) {
                final prompt = state.measurementTimePrompt;
                if (prompt == null || _isMeasurementTimeDialogOpen) {
                  return;
                }
                _showMeasurementStartTimeDialog(context, prompt.currentTime);
              },
            ),
            BlocListener<
              GeneralUserSelfTestDebugBloc,
              GeneralUserSelfTestDebugState
            >(
              listenWhen: (p, c) =>
                  c.transmitterFrequencyPrompt != null &&
                  c.transmitterFrequencyPrompt != p.transmitterFrequencyPrompt,
              listener: (context, state) {
                final prompt = state.transmitterFrequencyPrompt;
                if (prompt == null || _isTransmitterFrequencyDialogOpen) {
                  return;
                }
                _showTransmitterFrequencyDialog(
                  context,
                  prompt.transmitterType,
                  prompt.frequencyValue,
                );
              },
            ),
            BlocListener<
              GeneralUserSelfTestDebugBloc,
              GeneralUserSelfTestDebugState
            >(
              listenWhen: (p, c) =>
                  c.setAttenuationPrompt != null &&
                  c.setAttenuationPrompt != p.setAttenuationPrompt,
              listener: (context, state) {
                final prompt = state.setAttenuationPrompt;
                if (prompt == null || _isSetAttenuationDialogOpen) {
                  return;
                }
                _showSetAttenuationDialog(
                  context,
                  prompt.transmitterType,
                  prompt.attenuationValue,
                );
              },
            ),
            BlocListener<
              GeneralUserSelfTestDebugBloc,
              GeneralUserSelfTestDebugState
            >(
              listenWhen: (p, c) =>
                  c.radioSondeTransmitterIdPrompt != null &&
                  c.radioSondeTransmitterIdPrompt !=
                      p.radioSondeTransmitterIdPrompt,
              listener: (context, state) {
                final prompt = state.radioSondeTransmitterIdPrompt;
                if (prompt == null || _isRadioSondeTransmitterIdDialogOpen) {
                  return;
                }
                _showRadioSondeTransmitterIdDialog(
                  context,
                  prompt.currentTransmitterId,
                );
              },
            ),
            BlocListener<
              GeneralUserSelfTestDebugBloc,
              GeneralUserSelfTestDebugState
            >(
              listenWhen: (p, c) =>
                  c.transmitterTestPrompt != null &&
                  c.transmitterTestPrompt != p.transmitterTestPrompt,
              listener: (context, state) {
                final prompt = state.transmitterTestPrompt;
                if (prompt == null || _isTransmitterTestDialogOpen) {
                  return;
                }
                _showTransmitterTestDialog(context, prompt);
              },
            ),
            BlocListener<
              GeneralUserSelfTestDebugBloc,
              GeneralUserSelfTestDebugState
            >(
              listenWhen: (p, c) =>
                  c.stationIdPrompt != null &&
                  c.stationIdPrompt != p.stationIdPrompt,
              listener: (context, state) {
                final prompt = state.stationIdPrompt;
                if (prompt == null) {
                  return;
                }
                if (_isSetStationIdDialogOpen) {
                  return;
                }
                _showSetStationIdDialog(context, prompt.currentStationId);
              },
            ),
            BlocListener<
              GeneralUserSelfTestDebugBloc,
              GeneralUserSelfTestDebugState
            >(
              listenWhen: (p, c) =>
                  c.checkStatusPrompt != null &&
                  c.checkStatusPrompt != p.checkStatusPrompt,
              listener: (context, state) {
                final prompt = state.checkStatusPrompt;
                if (prompt == null || _isCheckStatusDialogOpen) {
                  return;
                }
                _showCheckStatusDialog(context, prompt);
              },
            ),
            BlocListener<
              GeneralUserSelfTestDebugBloc,
              GeneralUserSelfTestDebugState
            >(
              listenWhen: (p, c) =>
                  c.lastSnapshot != null && c.lastSnapshot != p.lastSnapshot,
              listener: (context, state) {
                final snap = state.lastSnapshot;
                if (snap == null) {
                  return;
                }
                showDialog<void>(
                  context: context,
                  builder: (ctx) {
                    final descriptionColor = snap.descriptionSuccess == null
                        ? const Color(0xFF5C6368)
                        : snap.descriptionSuccess!
                        ? const Color(0xFF1B5E20)
                        : const Color(0xFFB3261E);
                    return AlertDialog(
                      title: Text(snap.testName),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!snap.hideResponseLine) ...[
                              Text(
                                'Response',
                                style: Theme.of(ctx).textTheme
                                    .compactSectionTitle(
                                      const Color(0xFF1D2329),
                                    ),
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                snap.responseLine,
                                style: Theme.of(ctx).textTheme.bodySmall
                                    ?.copyWith(color: const Color(0xFF2A2F34)),
                              ),
                            ],
                            if (snap.helpText.isNotEmpty) ...[
                              if (!snap.hideResponseLine)
                                const SizedBox(height: 16),
                              Text(
                                'Description',
                                style: Theme.of(ctx).textTheme
                                    .compactSectionTitle(
                                      const Color(0xFF1D2329),
                                    ),
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                snap.helpText,
                                style: Theme.of(ctx).textTheme.bodySmall
                                    ?.copyWith(
                                      color: descriptionColor,
                                      fontWeight:
                                          snap.descriptionSuccess == null
                                          ? FontWeight.normal
                                          : FontWeight.w600,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
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
                        if (state.status ==
                                GeneralUserSelfTestDebugStatus.loading ||
                            state.status ==
                                GeneralUserSelfTestDebugStatus.initial) {
                          return const AppLoader();
                        }
                        if (state.status ==
                            GeneralUserSelfTestDebugStatus.error) {
                          return AppErrorView(
                            message: state.message,
                            onRetry: () {
                              context.read<GeneralUserSelfTestDebugBloc>().add(
                                const LoadGeneralUserSelfTestDebug(),
                              );
                            },
                          );
                        }

                        if (state.commands.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                state.message.isNotEmpty
                                    ? state.message
                                    : 'No self-test commands available.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: const Color(0xFF5C6368)),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: state.commands.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final command = state.commands[index];
                            final running =
                                state.runningCommandIndex == index &&
                                state.status ==
                                    GeneralUserSelfTestDebugStatus.running;
                            return _ActionTile(
                              title: command.testName,
                              subtitle:
                                  command.requestCommandDescription.isNotEmpty
                                  ? command.requestCommandDescription
                                  : command.requestCommand,
                              running: running,
                              onTap: running
                                  ? null
                                  : () {
                                      context
                                          .read<GeneralUserSelfTestDebugBloc>()
                                          .add(
                                            RunGeneralUserSelfTestDebugAction(
                                              index,
                                            ),
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
                style: Theme.of(
                  context,
                ).textTheme.compactAppBarTitle(const Color(0xFF262C31)),
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
  final String subtitle;
  final bool running;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF2A2F34),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6A7178),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (running)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF8B9196)),
          ],
        ),
      ),
    );
  }
}
