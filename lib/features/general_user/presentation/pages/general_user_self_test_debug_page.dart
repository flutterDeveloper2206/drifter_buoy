import 'dart:convert';

import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/theme/app_typography.dart';
import 'package:drifter_buoy/core/utils/widgets/app_error_view.dart';
import 'package:drifter_buoy/core/utils/widgets/app_flushbar.dart';
import 'package:drifter_buoy/core/utils/widgets/app_icon_circle_button.dart';
import 'package:drifter_buoy/core/utils/widgets/app_loader.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/self_test_debug/general_user_self_test_debug_bloc.dart';
import 'package:drifter_buoy/features/general_user/data/models/drifter_buoy_command_model.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/self_test_debug/general_user_self_test_debug_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/self_test_debug/general_user_self_test_debug_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Mongo ids for FTP password catalog rows (same as [GeneralUserSelfTestDebugBloc] static commands).
const Set<String> _ftpPasswordCatalogIds = {
  '6a04547227be22811320695b',
  '6a04547227be228113206963',
  '6a04547227be22811320696b',
  '6a04547227be228113206973',
};

String? _validateSelfTestParameterizedFtp20(String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) {
    return 'Enter a value (1–20 characters).';
  }
  if (t.length > 20) {
    return 'Maximum 20 characters.';
  }
  if (!RegExp(r'^[\x20-\x7E]+$').hasMatch(t)) {
    return 'Use printable ASCII only.';
  }
  return null;
}

String? _validateSelfTestApn31(String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) {
    return 'Enter APN name (Para 1).';
  }
  if (t.length > 31) {
    return 'Maximum 31 characters.';
  }
  if (t.contains(',')) {
    return 'APN cannot contain a comma.';
  }
  if (!RegExp(r'^[\x20-\x7E]+$').hasMatch(t)) {
    return 'Use printable ASCII only.';
  }
  return null;
}

String? _validateSelfTestPrintableAsciiMax128NoComma(String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) {
    return 'Enter HTTP website address.';
  }
  if (t.length > 128) {
    return 'Maximum 128 characters.';
  }
  if (t.contains(',')) {
    return 'Cannot contain a comma.';
  }
  if (!RegExp(r'^[\x20-\x7E]+$').hasMatch(t)) {
    return 'Use printable ASCII only.';
  }
  return null;
}

String? _validateSelfTestPrintableAsciiMax15NoComma(String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) {
    return 'Enter RTC server key.';
  }
  if (t.length > 15) {
    return 'Maximum 15 characters.';
  }
  if (t.contains(',')) {
    return 'Cannot contain a comma.';
  }
  if (!RegExp(r'^[\x20-\x7E]+$').hasMatch(t)) {
    return 'Use printable ASCII only.';
  }
  return null;
}

String? _validateSelfTestParameterizedPort(String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) {
    return 'Enter a port number.';
  }
  if (!RegExp(r'^\d{1,5}$').hasMatch(t)) {
    return 'Use 1–5 digits only.';
  }
  final n = int.tryParse(t);
  if (n == null || n < 0 || n > 65535) {
    return 'Port must be between 0 and 65535.';
  }
  return null;
}

String? _validateSelfTestParameterizedSmsCell(String? value) {
  var s = value?.trim().replaceAll(RegExp(r'\s'), '') ?? '';
  if (s.isEmpty) {
    return 'Enter a mobile number.';
  }
  if (s.startsWith('+91')) {
    s = s.substring(3);
  }
  if (s.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(s)) {
    return 'Use 10 digits, or +91 followed by 10 digits.';
  }
  return null;
}

String? _validateSelfTestBatteryVoltageIndex(String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) {
    return 'Enter an index (00 to 11).';
  }
  final v = int.tryParse(t);
  if (v == null || v < 0 || v > 11) {
    return 'Index must be between 00 and 11.';
  }
  return null;
}

String? _validateSelfTestHhMmSs(String label, String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) {
    return '$label is required.';
  }
  final m = RegExp(r'^(\d{2}):(\d{2}):(\d{2})$').firstMatch(raw);
  if (m == null) {
    return '$label must be HH:MM:SS.';
  }
  final hh = int.parse(m.group(1)!);
  final mm = int.parse(m.group(2)!);
  final ss = int.parse(m.group(3)!);
  if (hh > 23 || mm > 59 || ss > 59) {
    return '$label must use valid 24-hour time.';
  }
  return null;
}

String? _validateSelfTestStationIdSetAllGeneral(String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) {
    return 'Station id is required.';
  }
  if (t.contains(',')) {
    return 'Station id cannot contain a comma.';
  }
  if (t.length > 8) {
    return 'Station id must be at most 8 characters.';
  }
  return null;
}

String? _validateSelfTestStationNameSetAllGeneral(String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) {
    return 'Station name is required.';
  }
  if (t.contains(',')) {
    return 'Station name cannot contain a comma.';
  }
  if (t.length > 16) {
    return 'Station name must be at most 16 characters.';
  }
  return null;
}

String? _validateSelfTestApnSetAllGeneral(String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) {
    return 'APN is required.';
  }
  if (t.contains(',')) {
    return 'APN cannot contain a comma.';
  }
  if (t.length > 31) {
    return 'APN must be at most 31 characters.';
  }
  return null;
}

String? _validateSelfTestFastSmsSetAllGeneral(String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) {
    return 'Fast SMS check is required.';
  }
  if (t != '0' && t != '1') {
    return 'Enter 0 or 1.';
  }
  return null;
}

String? _validateSelfTestSetAllServerStationId(String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) {
    return 'Station id is required.';
  }
  if (t.contains(',')) {
    return 'Station id cannot contain a comma.';
  }
  if (t.length > 8) {
    return 'Station id must be at most 8 characters.';
  }
  if (!RegExp(r'^[\x20-\x7E]+$').hasMatch(t)) {
    return 'Use printable ASCII only.';
  }
  return null;
}

class GeneralUserSelfTestDebugPage extends StatefulWidget {
  const GeneralUserSelfTestDebugPage({super.key});

  @override
  State<GeneralUserSelfTestDebugPage> createState() =>
      _GeneralUserSelfTestDebugPageState();
}

class _GeneralUserSelfTestDebugPageState
    extends State<GeneralUserSelfTestDebugPage> {
  late final TextEditingController _commandSearchController;

  bool _isSetStationIdDialogOpen = false;
  bool _isSetStationNameDialogOpen = false;
  bool _isMeasurementTimeDialogOpen = false;
  bool _isTransmissionTimeDialogOpen = false;
  bool _isTransmissionIntervalDialogOpen = false;
  bool _isMeasurementIntervalDialogOpen = false;
  bool _isSetApnDialogOpen = false;
  bool _isTransmitterFrequencyDialogOpen = false;
  bool _isSetAttenuationDialogOpen = false;
  bool _isRadioSondeTransmitterIdDialogOpen = false;
  bool _isTransmitterTestDialogOpen = false;
  bool _isCheckStatusDialogOpen = false;
  bool _isParameterizedCommandDialogOpen = false;
  bool _isSetAllGeneralParametersDialogOpen = false;
  bool _isSetAllServerParametersDialogOpen = false;
  bool _isRestoreServerParametersDialogOpen = false;

  /// Blocking BLE progress UI lives in the overlay (not [Navigator]) so we never
  /// [Navigator.pop] a Flushbar/snackbar route by mistake.
  OverlayEntry? _bleCommandProgressOverlay;

  @override
  void initState() {
    super.initState();
    _commandSearchController = TextEditingController();
  }

  @override
  void dispose() {
    _removeBleCommandProgressOverlay();
    _commandSearchController.dispose();
    super.dispose();
  }

  /// Shows dimmed full-screen barrier + progress card above routes (safe with Flushbar).
  void _presentBleCommandProgressOverlay(BuildContext context) {
    if (_bleCommandProgressOverlay != null || !context.mounted) {
      return;
    }
    final overlayState = Overlay.of(context, rootOverlay: true);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext ctx) {
        return PopScope(
          canPop: false,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ModalBarrier(
                dismissible: false,
                color: Colors.black54,
                semanticsLabel: MaterialLocalizations.of(
                  ctx,
                ).modalBarrierDismissLabel,
              ),
              Material(
                color: Colors.transparent,
                child: _BleCommandProgressDialog(theme: Theme.of(context)),
              ),
            ],
          ),
        );
      },
    );

    _bleCommandProgressOverlay = entry;
    overlayState.insert(entry);
  }

  void _removeBleCommandProgressOverlay() {
    final entry = _bleCommandProgressOverlay;
    if (entry == null) {
      return;
    }
    _bleCommandProgressOverlay = null;
    entry.remove();
  }

  /// Indices into the full catalog list matching the search box (name, request, description).
  List<int> _filterCommandIndices(
    List<DrifterBuoyCommandModel> commands,
    String query,
  ) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) {
      return List<int>.generate(commands.length, (i) => i);
    }
    final result = <int>[];
    for (var i = 0; i < commands.length; i++) {
      final DrifterBuoyCommandModel c = commands[i];
      final blob =
          '${c.testName} ${c.requestCommand} ${c.requestCommandDescription}'
              .toLowerCase();
      if (blob.contains(needle)) {
        result.add(i);
      }
    }
    return result;
  }

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

  Future<void> _showSetStationNameDialog(
    BuildContext context,
    SelfTestStationNamePrompt prompt,
  ) async {
    if (_isSetStationNameDialogOpen) {
      return;
    }
    _isSetStationNameDialogOpen = true;
    var draftStationName = prompt.currentStationName;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Set station name'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '?07 — up to 16 characters (space-padded when sent).',
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6A7178),
                    ),
                  ),
                  if (prompt.prefetchWarning != null &&
                      prompt.prefetchWarning!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      prompt.prefetchWarning!,
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFBF360C),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  TextFormField(
                    key: ValueKey(
                      'set-station-name-${prompt.currentStationName}',
                    ),
                    initialValue: prompt.currentStationName,
                    maxLength: 16,
                    onChanged: (v) => draftStationName = v,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'e.g. Pakistan',
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
                  final err = _validateSelfTestStationNameSetAllGeneral(
                    draftStationName,
                  );
                  if (err != null) {
                    AppFlushbar.error(err, context: ctx);
                    return;
                  }
                  context.read<GeneralUserSelfTestDebugBloc>().add(
                    SubmitGeneralUserSetStationName(draftStationName.trim()),
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
          const ClearGeneralUserSetStationNamePrompt(),
        );
      }
    } finally {
      _isSetStationNameDialogOpen = false;
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

  Future<void> _showTransmissionTimeDialog(
    BuildContext context,
    SelfTestTransmissionTimePrompt prompt,
  ) async {
    if (_isTransmissionTimeDialogOpen) {
      return;
    }
    _isTransmissionTimeDialogOpen = true;
    var selected = const TimeOfDay(hour: 0, minute: 0);

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setLocalState) {
              final value = _formatTime(selected);
              return AlertDialog(
                title: Text(prompt.testName),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '?08 — transmission time as HH:MM:SS (picker sets seconds to :00).',
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6A7178),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Time to send: $value',
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
                        SubmitGeneralUserSetTransmissionTime(
                          _formatTime(selected),
                        ),
                      );
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Send'),
                  ),
                ],
              );
            },
          );
        },
      );
      if (context.mounted) {
        context.read<GeneralUserSelfTestDebugBloc>().add(
          const ClearGeneralUserTransmissionTimePrompt(),
        );
      }
    } finally {
      _isTransmissionTimeDialogOpen = false;
    }
  }

  Future<void> _showTransmissionIntervalDialog(
    BuildContext context,
    SelfTestTransmissionIntervalPrompt prompt,
  ) async {
    if (_isTransmissionIntervalDialogOpen) {
      return;
    }
    _isTransmissionIntervalDialogOpen = true;
    var selected =
        _parseTimeOfDay(prompt.currentTxInterval) ??
        const TimeOfDay(hour: 0, minute: 10);

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setLocalState) {
              final value = _formatTime(selected);
              final hint = prompt.catalogHelpText.trim();
              return AlertDialog(
                title: Text(prompt.testName),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '?09 — Device was read with ?04,,# (Tx interval = 3rd field). Picker uses HH:MM and sends seconds as :00.',
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6A7178),
                      ),
                    ),
                    if (hint.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        hint,
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF2A2F34),
                        ),
                      ),
                    ],
                    if (prompt.prefetchWarning != null &&
                        prompt.prefetchWarning!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        prompt.prefetchWarning!,
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFBF360C),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      'Interval to send: $value',
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
                      label: const Text('Pick interval'),
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
                      final secs = selected.hour * 3600 + selected.minute * 60;
                      if (secs < 10 * 60) {
                        AppFlushbar.error(
                          'Transmission interval must be at least 00:10:00.',
                          context: ctx,
                        );
                        return;
                      }
                      context.read<GeneralUserSelfTestDebugBloc>().add(
                        SubmitGeneralUserSetTransmissionInterval(
                          _formatTime(selected),
                        ),
                      );
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Send'),
                  ),
                ],
              );
            },
          );
        },
      );
      if (context.mounted) {
        context.read<GeneralUserSelfTestDebugBloc>().add(
          const ClearGeneralUserTransmissionIntervalPrompt(),
        );
      }
    } finally {
      _isTransmissionIntervalDialogOpen = false;
    }
  }

  Future<void> _showMeasurementIntervalDialog(
    BuildContext context,
    SelfTestMeasurementIntervalPrompt prompt,
  ) async {
    if (_isMeasurementIntervalDialogOpen) {
      return;
    }
    _isMeasurementIntervalDialogOpen = true;

    String effectiveMi(String current) {
      if (prompt.allowedMeasurementIntervals.contains(current)) {
        return current;
      }
      return prompt.allowedMeasurementIntervals.isNotEmpty
          ? prompt.allowedMeasurementIntervals.first
          : '';
    }

    var selectedMi = effectiveMi(prompt.currentMeasurementInterval);

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setLocalState) {
              final hint = prompt.catalogHelpText.trim();
              return AlertDialog(
                title: Text(prompt.testName),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '?10 — Measurement interval was read with ?04,,# (4th general-parameter field).',
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6A7178),
                        ),
                      ),
                      if (hint.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          hint,
                          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF2A2F34),
                          ),
                        ),
                      ],
                      if (prompt.prefetchWarning != null &&
                          prompt.prefetchWarning!.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          prompt.prefetchWarning!,
                          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFBF360C),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Measurement interval',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: selectedMi.isEmpty ? null : selectedMi,
                        items: prompt.allowedMeasurementIntervals
                            .map(
                              (e) => DropdownMenuItem<String>(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v == null) {
                            return;
                          }
                          setLocalState(() => selectedMi = v);
                        },
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
                      if (selectedMi.isEmpty) {
                        AppFlushbar.error(
                          'Select measurement interval.',
                          context: ctx,
                        );
                        return;
                      }
                      context.read<GeneralUserSelfTestDebugBloc>().add(
                        SubmitGeneralUserSetMeasurementInterval(
                          measurementInterval: selectedMi,
                        ),
                      );
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Send'),
                  ),
                ],
              );
            },
          );
        },
      );
      if (context.mounted) {
        context.read<GeneralUserSelfTestDebugBloc>().add(
          const ClearGeneralUserMeasurementIntervalPrompt(),
        );
      }
    } finally {
      _isMeasurementIntervalDialogOpen = false;
    }
  }

  Future<void> _showSetApnDialog(
    BuildContext context,
    SelfTestSetApnPrompt prompt,
  ) async {
    if (_isSetApnDialogOpen) {
      return;
    }
    _isSetApnDialogOpen = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => BlocProvider<GeneralUserSelfTestDebugBloc>.value(
          value: context.read<GeneralUserSelfTestDebugBloc>(),
          child: _SetApnAlertDialog(prompt: prompt),
        ),
      );
      if (context.mounted) {
        context.read<GeneralUserSelfTestDebugBloc>().add(
          const ClearGeneralUserSetApnPrompt(),
        );
      }
    } finally {
      _isSetApnDialogOpen = false;
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

  Future<void> _showParameterizedCommandDialog(
    BuildContext context,
    SelfTestParameterizedCommandPrompt prompt,
  ) async {
    if (_isParameterizedCommandDialogOpen) {
      return;
    }
    _isParameterizedCommandDialogOpen = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return BlocProvider<GeneralUserSelfTestDebugBloc>.value(
            value: context.read<GeneralUserSelfTestDebugBloc>(),
            child: _ParameterizedServerCommandDialog(prompt: prompt),
          );
        },
      );
    } finally {
      _isParameterizedCommandDialogOpen = false;
    }
    if (!context.mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      context.read<GeneralUserSelfTestDebugBloc>().add(
        const ClearGeneralUserParameterizedCommandPrompt(),
      );
    });
  }

  Future<void> _showSetAllGeneralParametersDialog(
    BuildContext context,
    SelfTestSetAllGeneralParametersPrompt prompt,
  ) async {
    if (_isSetAllGeneralParametersDialogOpen) {
      return;
    }
    _isSetAllGeneralParametersDialogOpen = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return BlocProvider<GeneralUserSelfTestDebugBloc>.value(
            value: context.read<GeneralUserSelfTestDebugBloc>(),
            child: _SetAllGeneralParametersDialog(prompt: prompt),
          );
        },
      );
    } finally {
      _isSetAllGeneralParametersDialogOpen = false;
    }
    if (!context.mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      context.read<GeneralUserSelfTestDebugBloc>().add(
        SubmitGeneralUserParameterizedCommand(
          commandId: prompt.commandId,
          value: GeneralUserSelfTestDebugBloc
              .setAllGeneralParametersClearPromptMarker,
        ),
      );
    });
  }

  Future<void> _showSetAllServerParametersDialog(
    BuildContext context,
    SelfTestSetAllServerParametersPrompt prompt,
  ) async {
    if (_isSetAllServerParametersDialogOpen) {
      return;
    }
    _isSetAllServerParametersDialogOpen = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return BlocProvider<GeneralUserSelfTestDebugBloc>.value(
            value: context.read<GeneralUserSelfTestDebugBloc>(),
            child: _SetAllServerParametersDialog(prompt: prompt),
          );
        },
      );
    } finally {
      _isSetAllServerParametersDialogOpen = false;
    }
    if (!context.mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      context.read<GeneralUserSelfTestDebugBloc>().add(
        SubmitGeneralUserParameterizedCommand(
          commandId: prompt.commandId,
          value: GeneralUserSelfTestDebugBloc
              .setAllServerParametersClearPromptMarker,
        ),
      );
    });
  }

  Future<void> _showRestoreServerParametersDialog(
    BuildContext context,
    SelfTestRestoreServerParametersPrompt prompt,
  ) async {
    if (_isRestoreServerParametersDialogOpen) {
      return;
    }
    _isRestoreServerParametersDialogOpen = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return BlocProvider<GeneralUserSelfTestDebugBloc>.value(
            value: context.read<GeneralUserSelfTestDebugBloc>(),
            child: _RestoreServerParametersDialog(prompt: prompt),
          );
        },
      );
    } finally {
      _isRestoreServerParametersDialogOpen = false;
    }
    if (!context.mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      context.read<GeneralUserSelfTestDebugBloc>().add(
        const ClearGeneralUserRestoreServerParametersPrompt(),
      );
    });
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
                  c.transmissionTimePrompt != null &&
                  c.transmissionTimePrompt != p.transmissionTimePrompt,
              listener: (context, state) {
                final prompt = state.transmissionTimePrompt;
                if (prompt == null || _isTransmissionTimeDialogOpen) {
                  return;
                }
                _showTransmissionTimeDialog(context, prompt);
              },
            ),
            BlocListener<
              GeneralUserSelfTestDebugBloc,
              GeneralUserSelfTestDebugState
            >(
              listenWhen: (p, c) =>
                  c.transmissionIntervalPrompt != null &&
                  c.transmissionIntervalPrompt != p.transmissionIntervalPrompt,
              listener: (context, state) {
                final prompt = state.transmissionIntervalPrompt;
                if (prompt == null || _isTransmissionIntervalDialogOpen) {
                  return;
                }
                _showTransmissionIntervalDialog(context, prompt);
              },
            ),
            BlocListener<
              GeneralUserSelfTestDebugBloc,
              GeneralUserSelfTestDebugState
            >(
              listenWhen: (p, c) =>
                  c.measurementIntervalPrompt != null &&
                  c.measurementIntervalPrompt != p.measurementIntervalPrompt,
              listener: (context, state) {
                final prompt = state.measurementIntervalPrompt;
                if (prompt == null || _isMeasurementIntervalDialogOpen) {
                  return;
                }
                _showMeasurementIntervalDialog(context, prompt);
              },
            ),
            BlocListener<
              GeneralUserSelfTestDebugBloc,
              GeneralUserSelfTestDebugState
            >(
              listenWhen: (p, c) =>
                  c.setApnPrompt != null && c.setApnPrompt != p.setApnPrompt,
              listener: (context, state) {
                final prompt = state.setApnPrompt;
                if (prompt == null || _isSetApnDialogOpen) {
                  return;
                }
                _showSetApnDialog(context, prompt);
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
                  c.stationNamePrompt != null &&
                  c.stationNamePrompt != p.stationNamePrompt,
              listener: (context, state) {
                final prompt = state.stationNamePrompt;
                if (prompt == null) {
                  return;
                }
                if (_isSetStationNameDialogOpen) {
                  return;
                }
                _showSetStationNameDialog(context, prompt);
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
                  c.parameterizedCommandPrompt != null &&
                  c.parameterizedCommandPrompt != p.parameterizedCommandPrompt,
              listener: (context, state) {
                final prompt = state.parameterizedCommandPrompt;
                if (prompt == null || _isParameterizedCommandDialogOpen) {
                  return;
                }
                _showParameterizedCommandDialog(context, prompt);
              },
            ),
            BlocListener<
              GeneralUserSelfTestDebugBloc,
              GeneralUserSelfTestDebugState
            >(
              listenWhen: (p, c) =>
                  c.setAllGeneralParametersPrompt != null &&
                  c.setAllGeneralParametersPrompt !=
                      p.setAllGeneralParametersPrompt,
              listener: (context, state) {
                final prompt = state.setAllGeneralParametersPrompt;
                if (prompt == null || _isSetAllGeneralParametersDialogOpen) {
                  return;
                }
                _showSetAllGeneralParametersDialog(context, prompt);
              },
            ),
            BlocListener<
              GeneralUserSelfTestDebugBloc,
              GeneralUserSelfTestDebugState
            >(
              listenWhen: (p, c) =>
                  c.setAllServerParametersPrompt != null &&
                  c.setAllServerParametersPrompt !=
                      p.setAllServerParametersPrompt,
              listener: (context, state) {
                final prompt = state.setAllServerParametersPrompt;
                if (prompt == null || _isSetAllServerParametersDialogOpen) {
                  return;
                }
                _showSetAllServerParametersDialog(context, prompt);
              },
            ),
            BlocListener<
              GeneralUserSelfTestDebugBloc,
              GeneralUserSelfTestDebugState
            >(
              listenWhen: (p, c) =>
                  c.restoreServerParametersPrompt != null &&
                  c.restoreServerParametersPrompt !=
                      p.restoreServerParametersPrompt,
              listener: (context, state) {
                final prompt = state.restoreServerParametersPrompt;
                if (prompt == null || _isRestoreServerParametersDialogOpen) {
                  return;
                }
                _showRestoreServerParametersDialog(context, prompt);
              },
            ),
            BlocListener<
              GeneralUserSelfTestDebugBloc,
              GeneralUserSelfTestDebugState
            >(
              listenWhen: (p, c) =>
                  c.status == GeneralUserSelfTestDebugStatus.running &&
                  p.status != GeneralUserSelfTestDebugStatus.running,
              listener: (context, state) {
                _presentBleCommandProgressOverlay(context);
              },
            ),
            BlocListener<
              GeneralUserSelfTestDebugBloc,
              GeneralUserSelfTestDebugState
            >(
              listenWhen: (p, c) =>
                  p.status == GeneralUserSelfTestDebugStatus.running &&
                  c.status != GeneralUserSelfTestDebugStatus.running,
              listener: (context, state) {
                _removeBleCommandProgressOverlay();
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
                    final helpSectionTitle = snap.hideResponseLine
                        ? 'Summary'
                        : 'Description';
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
                                helpSectionTitle,
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
                child: BlocBuilder<GeneralUserSelfTestDebugBloc, GeneralUserSelfTestDebugState>(
                  builder: (context, state) {
                    if (state.status ==
                            GeneralUserSelfTestDebugStatus.loading ||
                        state.status ==
                            GeneralUserSelfTestDebugStatus.initial) {
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

                    final filteredIndices = _filterCommandIndices(
                      state.commands,
                      _commandSearchController.text,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                          child: TextField(
                            controller: _commandSearchController,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Search commands',
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: Color(0xFF8A9095),
                              ),
                              suffixIcon: _commandSearchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Clear',
                                      icon: const Icon(Icons.clear_rounded),
                                      color: const Color(0xFF8A9095),
                                      onPressed: () {
                                        _commandSearchController.clear();
                                        setState(() {});
                                      },
                                    ),
                              filled: true,
                              fillColor: const Color(0xFFF2F2F2),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        Expanded(
                          child: filteredIndices.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text(
                                      'No commands match your search.',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: const Color(0xFF5C6368),
                                          ),
                                    ),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: () async {
                                    final bloc = context
                                        .read<GeneralUserSelfTestDebugBloc>();
                                    final waitLoaded = bloc.stream.firstWhere(
                                      (GeneralUserSelfTestDebugState s) =>
                                          s.status ==
                                              GeneralUserSelfTestDebugStatus
                                                  .loaded ||
                                          s.status ==
                                              GeneralUserSelfTestDebugStatus
                                                  .error,
                                    );
                                    bloc.add(
                                      const LoadGeneralUserSelfTestDebug(),
                                    );
                                    await waitLoaded;
                                  },
                                  child: ListView.separated(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      12,
                                      16,
                                      16,
                                    ),
                                    itemCount: filteredIndices.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, listIndex) {
                                      final commandIndex =
                                          filteredIndices[listIndex];
                                      final command =
                                          state.commands[commandIndex];
                                      final running =
                                          state.runningCommandIndex ==
                                              commandIndex &&
                                          state.status ==
                                              GeneralUserSelfTestDebugStatus
                                                  .running;
                                      return _ActionTile(
                                        title:
                                            '${commandIndex + 1}-${command.testName}',
                                        subtitle:
                                            command
                                                .requestCommandDescription
                                                .isNotEmpty
                                            ? command.requestCommandDescription
                                            : command.requestCommand,
                                        running: false,
                                        onTap: running
                                            ? null
                                            : () {
                                                context
                                                    .read<
                                                      GeneralUserSelfTestDebugBloc
                                                    >()
                                                    .add(
                                                      RunGeneralUserSelfTestDebugAction(
                                                        commandIndex,
                                                      ),
                                                    );
                                              },
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ],
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

/// Content for [_GeneralUserSelfTestDebugPageState._presentBleCommandProgressOverlay].
class _BleCommandProgressDialog extends StatelessWidget {
  const _BleCommandProgressDialog({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme,
      child: PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const CircularProgressIndicator(color: Color(0xFF2A2F34)),
              const SizedBox(height: 24),
              Text(
                'Process running',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D2329),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait ...',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6A7178),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Owns [TextEditingController] lifetime so it is not disposed while the route is still tearing down.
class _SetApnAlertDialog extends StatefulWidget {
  const _SetApnAlertDialog({required this.prompt});

  final SelfTestSetApnPrompt prompt;

  @override
  State<_SetApnAlertDialog> createState() => _SetApnAlertDialogState();
}

class _SetApnAlertDialogState extends State<_SetApnAlertDialog> {
  late final TextEditingController _apnController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _para2 = 0;
  int _para3 = 1;

  SelfTestSetApnPrompt get _prompt => widget.prompt;

  @override
  void initState() {
    super.initState();
    _apnController = TextEditingController();
  }

  @override
  void dispose() {
    _apnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hint = _prompt.catalogHelpText.trim();
    return AlertDialog(
      title: Text(_prompt.testName),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '?11 — Type the APN name for Para 1 (max 31 chars). Only what you enter here is sent, like ?11,jionet,0,2,#.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6A7178)),
            ),
            if (_prompt.initialSim1Apn.isNotEmpty ||
                _prompt.initialSim2Apn.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                [
                  if (_prompt.initialSim1Apn.isNotEmpty)
                    'Read-only (SIM1 on device): ${_prompt.initialSim1Apn}',
                  if (_prompt.initialSim2Apn.isNotEmpty)
                    'Read-only (SIM2 on device): ${_prompt.initialSim2Apn}',
                ].join('\n'),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6A7178)),
              ),
            ],
            if (hint.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                hint,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF2A2F34)),
              ),
            ],
            if (_prompt.prefetchWarning != null &&
                _prompt.prefetchWarning!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _prompt.prefetchWarning!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFFBF360C)),
              ),
            ],
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _apnController,
                    maxLength: 31,
                    validator: _validateSelfTestApn31,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      labelText: 'APN name (Para 1)',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'SIM operator (Para 2)',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _para2,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('0 — Vodafone')),
                      DropdownMenuItem(value: 1, child: Text('1 — Other SIM')),
                    ],
                    onChanged: (v) {
                      if (v == null) {
                        return;
                      }
                      setState(() => _para2 = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'APN slot (Para 3)',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _para3,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 — SIM1 APN')),
                      DropdownMenuItem(value: 2, child: Text('2 — SIM2 APN')),
                    ],
                    onChanged: (v) {
                      if (v == null) {
                        return;
                      }
                      setState(() {
                        _para3 = v;
                        if (_apnController.text.trim().isEmpty) {
                          _apnController.text = v == 1
                              ? _prompt.initialSim1Apn
                              : _prompt.initialSim2Apn;
                        }
                      });
                    },
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
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            if (!(_formKey.currentState?.validate() ?? false)) {
              return;
            }
            final bloc = context.read<GeneralUserSelfTestDebugBloc>();
            final apnName = _apnController.text.trim();
            final vodafoneOrOther = _para2;
            final simSlot = _para3;
            Navigator.of(context).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bloc.add(
                SubmitGeneralUserSetApn(
                  apnName: apnName,
                  vodafoneOrOther: vodafoneOrOther,
                  simSlot: simSlot,
                ),
              );
            });
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}

class _ParameterizedServerCommandDialog extends StatefulWidget {
  const _ParameterizedServerCommandDialog({required this.prompt});

  final SelfTestParameterizedCommandPrompt prompt;

  @override
  State<_ParameterizedServerCommandDialog> createState() =>
      _ParameterizedServerCommandDialogState();
}

class _ParameterizedServerCommandDialogState
    extends State<_ParameterizedServerCommandDialog> {
  late final TextEditingController _textController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _redundancy = 0;
  int _httpServerIndex = 0;
  bool _hidePasswordCharacters = true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get _isPasswordField =>
      _ftpPasswordCatalogIds.contains(widget.prompt.commandId);

  @override
  Widget build(BuildContext context) {
    final p = widget.prompt;
    final header = <Widget>[];

    if (p.requestHelpText.trim().isNotEmpty) {
      header.add(
        SelectableText(
          p.requestHelpText.trim(),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6A7178)),
        ),
      );
      header.add(const SizedBox(height: 12));
    }

    late final Widget field;
    switch (p.fieldKind) {
      case SelfTestParameterizedCommandFieldKind.ftpField20:
        field = TextFormField(
          controller: _textController,
          maxLength: 20,
          obscureText: _isPasswordField && _hidePasswordCharacters,
          validator: _validateSelfTestParameterizedFtp20,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: _isPasswordField ? 'Password' : 'Value',
            helperText:
                '1–20 printable characters. Shorter values are padded when sent.',
            border: const OutlineInputBorder(),
            counterText: '',
            suffixIcon: _isPasswordField
                ? IconButton(
                    tooltip: _hidePasswordCharacters
                        ? 'Show password'
                        : 'Hide password',
                    onPressed: () {
                      setState(() {
                        _hidePasswordCharacters = !_hidePasswordCharacters;
                      });
                    },
                    icon: Icon(
                      _hidePasswordCharacters
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  )
                : null,
          ),
        );
        break;
      case SelfTestParameterizedCommandFieldKind.portFiveDigits:
        field = TextFormField(
          controller: _textController,
          keyboardType: TextInputType.number,
          maxLength: 5,
          validator: _validateSelfTestParameterizedPort,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Port',
            helperText: '0–65535 (sent as 5 digits with leading zeros).',
            border: OutlineInputBorder(),
            counterText: '',
          ),
        );
        break;
      case SelfTestParameterizedCommandFieldKind.smsCellPlus91:
        field = TextFormField(
          controller: _textController,
          keyboardType: TextInputType.phone,
          validator: _validateSelfTestParameterizedSmsCell,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Mobile number',
            helperText: '10 digits, or +91 and 10 digits.',
            border: OutlineInputBorder(),
          ),
        );
        break;
      case SelfTestParameterizedCommandFieldKind.txRedundancy01:
        field = RadioGroup<int>(
          groupValue: _redundancy,
          onChanged: (v) {
            if (v != null) {
              setState(() => _redundancy = v);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<int>(
                contentPadding: EdgeInsets.zero,
                value: 0,
                title: const Text('0 — GSM and GPRS'),
              ),
              RadioListTile<int>(
                contentPadding: EdgeInsets.zero,
                value: 1,
                title: const Text('1 — GSM if GPRS fail'),
              ),
            ],
          ),
        );
        break;
      case SelfTestParameterizedCommandFieldKind.rtcHttpWebsite128:
        field = TextFormField(
          controller: _textController,
          maxLength: 128,
          validator: _validateSelfTestPrintableAsciiMax128NoComma,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'HTTP website address',
            helperText:
                'Max 128 printable ASCII chars. Catalog adds a trailing space when shorter than 40.',
            border: OutlineInputBorder(),
            counterText: '',
          ),
        );
        break;
      case SelfTestParameterizedCommandFieldKind.rtcHttpKey15:
        field = TextFormField(
          controller: _textController,
          maxLength: 15,
          validator: _validateSelfTestPrintableAsciiMax15NoComma,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'RTC server key',
            helperText:
                'Max 15 printable ASCII chars. Catalog adds a trailing space when shorter than 40.',
            border: OutlineInputBorder(),
            counterText: '',
          ),
        );
        break;
      case SelfTestParameterizedCommandFieldKind.primaryHttpWebsiteIndex128:
        field = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'HTTP server number (N)',
                border: OutlineInputBorder(),
              ),
              initialValue: _httpServerIndex,
              items: List<DropdownMenuItem<int>>.generate(
                10,
                (i) => DropdownMenuItem<int>(value: i, child: Text('$i')),
              ),
              onChanged: (v) {
                if (v == null) {
                  return;
                }
                setState(() => _httpServerIndex = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _textController,
              maxLength: 128,
              validator: _validateSelfTestPrintableAsciiMax128NoComma,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'HTTP website address',
                helperText:
                    'Max 128 printable ASCII. Catalog adds a trailing space when shorter than 128.',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
          ],
        );
        break;
      case SelfTestParameterizedCommandFieldKind
          .secondaryHttpWebsiteIndex0to3And128:
        field = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'HTTP server number (N)',
                border: OutlineInputBorder(),
              ),
              initialValue: _httpServerIndex.clamp(0, 3),
              items: const [
                DropdownMenuItem(value: 0, child: Text('0')),
                DropdownMenuItem(value: 1, child: Text('1')),
                DropdownMenuItem(value: 2, child: Text('2')),
                DropdownMenuItem(value: 3, child: Text('3')),
              ],
              onChanged: (v) {
                if (v == null) {
                  return;
                }
                setState(() => _httpServerIndex = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _textController,
              maxLength: 128,
              validator: _validateSelfTestPrintableAsciiMax128NoComma,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'HTTP website address',
                helperText:
                    'Max 128 printable ASCII. Catalog adds a trailing space when shorter than 128.',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
          ],
        );
        break;
      case SelfTestParameterizedCommandFieldKind
          .thirdHttpWebsiteIndex0to3And128Trailing40:
        field = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'HTTP server number (N)',
                border: OutlineInputBorder(),
              ),
              initialValue: _httpServerIndex.clamp(0, 3),
              items: const [
                DropdownMenuItem(value: 0, child: Text('0')),
                DropdownMenuItem(value: 1, child: Text('1')),
                DropdownMenuItem(value: 2, child: Text('2')),
                DropdownMenuItem(value: 3, child: Text('3')),
              ],
              onChanged: (v) {
                if (v == null) {
                  return;
                }
                setState(() => _httpServerIndex = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _textController,
              maxLength: 128,
              validator: _validateSelfTestPrintableAsciiMax128NoComma,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'HTTP website address',
                helperText:
                    'Max 128 printable ASCII. Catalog adds a trailing space when shorter than 40.',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
          ],
        );
        break;
      case SelfTestParameterizedCommandFieldKind
          .factoryHttpWebsiteIndex0to3And128:
        field = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'HTTP server number (N)',
                border: OutlineInputBorder(),
              ),
              initialValue: _httpServerIndex.clamp(0, 3),
              items: const [
                DropdownMenuItem(value: 0, child: Text('0')),
                DropdownMenuItem(value: 1, child: Text('1')),
                DropdownMenuItem(value: 2, child: Text('2')),
                DropdownMenuItem(value: 3, child: Text('3')),
              ],
              onChanged: (v) {
                if (v == null) {
                  return;
                }
                setState(() => _httpServerIndex = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _textController,
              maxLength: 128,
              validator: _validateSelfTestPrintableAsciiMax128NoComma,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'HTTP website address',
                helperText:
                    'Max 128 printable ASCII. Catalog adds a trailing space when shorter than 128.',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
          ],
        );
        break;
      case SelfTestParameterizedCommandFieldKind.batteryVoltageIndex00to11:
        field = TextFormField(
          controller: _textController,
          keyboardType: TextInputType.number,
          maxLength: 2,
          validator: _validateSelfTestBatteryVoltageIndex,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Index (xx)',
            helperText: '00 to 11 (sent as two digits, e.g. 00, 05, 11).',
            border: OutlineInputBorder(),
            counterText: '',
          ),
        );
        break;
    }

    final isBatteryVoltage =
        p.fieldKind ==
        SelfTestParameterizedCommandFieldKind.batteryVoltageIndex00to11;

    return AlertDialog(
      title: Text(p.testName),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...header,
            Form(key: _formKey, child: field),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            if (p.fieldKind !=
                SelfTestParameterizedCommandFieldKind.txRedundancy01) {
              if (!(_formKey.currentState?.validate() ?? false)) {
                return;
              }
            }
            late final String value;
            if (p.fieldKind ==
                SelfTestParameterizedCommandFieldKind.txRedundancy01) {
              value = '$_redundancy';
            } else if (p.fieldKind ==
                    SelfTestParameterizedCommandFieldKind
                        .primaryHttpWebsiteIndex128 ||
                p.fieldKind ==
                    SelfTestParameterizedCommandFieldKind
                        .secondaryHttpWebsiteIndex0to3And128 ||
                p.fieldKind ==
                    SelfTestParameterizedCommandFieldKind
                        .thirdHttpWebsiteIndex0to3And128Trailing40 ||
                p.fieldKind ==
                    SelfTestParameterizedCommandFieldKind
                        .factoryHttpWebsiteIndex0to3And128) {
              value = jsonEncode({
                'n': _httpServerIndex,
                'v': _textController.text.trim(),
              });
            } else {
              value = _textController.text;
            }
            context.read<GeneralUserSelfTestDebugBloc>().add(
              SubmitGeneralUserParameterizedCommand(
                commandId: p.commandId,
                value: value,
              ),
            );
            Navigator.of(context).pop();
          },
          child: Text(isBatteryVoltage ? 'Send' : 'Update'),
        ),
      ],
    );
  }
}

class _SetAllGeneralParametersDialog extends StatefulWidget {
  const _SetAllGeneralParametersDialog({required this.prompt});

  final SelfTestSetAllGeneralParametersPrompt prompt;

  @override
  State<_SetAllGeneralParametersDialog> createState() =>
      _SetAllGeneralParametersDialogState();
}

class _SetAllGeneralParametersDialogState
    extends State<_SetAllGeneralParametersDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _stationId;
  late final TextEditingController _stationName;
  late final TextEditingController _txInterval;
  late final TextEditingController _measurementInterval;
  late final TextEditingController _apn;
  late final TextEditingController _fastSms;
  late final TextEditingController _adminCell1;
  late final TextEditingController _adminCell2;
  late final TextEditingController _measurementStartTime;

  @override
  void initState() {
    super.initState();
    final d = widget.prompt.initial;
    _stationId = TextEditingController(text: d.stationId);
    _stationName = TextEditingController(text: d.stationName);
    _txInterval = TextEditingController(text: d.txInterval);
    _measurementInterval = TextEditingController(text: d.measurementInterval);
    _apn = TextEditingController(text: d.apn);
    _fastSms = TextEditingController(text: d.fastSmsCheck);
    _adminCell1 = TextEditingController(text: d.adminCell1);
    _adminCell2 = TextEditingController(text: d.adminCell2);
    _measurementStartTime = TextEditingController(text: d.measurementStartTime);
  }

  @override
  void dispose() {
    _stationId.dispose();
    _stationName.dispose();
    _txInterval.dispose();
    _measurementInterval.dispose();
    _apn.dispose();
    _fastSms.dispose();
    _adminCell1.dispose();
    _adminCell2.dispose();
    _measurementStartTime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.prompt;
    final hintStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6A7178));

    final header = <Widget>[];
    final warn = p.prefetchWarning?.trim();
    if (warn != null && warn.isNotEmpty) {
      header.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            warn,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFFBF360C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    final cat = p.catalogHelpText.trim();
    if (cat.isNotEmpty) {
      header.addAll([
        SelectableText(cat, style: hintStyle),
        const SizedBox(height: 8),
        Text(
          'Values are padded on send (station id 8 chars, name 16, APN 31).',
          style: hintStyle,
        ),
        const SizedBox(height: 16),
      ]);
    }

    return AlertDialog(
      title: Text(p.testName),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                ...header,
                TextFormField(
                  controller: _stationId,
                  maxLength: 8,
                  validator: _validateSelfTestStationIdSetAllGeneral,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Station id',
                    helperText: 'Up to 8 characters',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stationName,
                  maxLength: 16,
                  validator: _validateSelfTestStationNameSetAllGeneral,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Station name',
                    helperText: 'Up to 16 characters',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _txInterval,
                  validator: (v) => _validateSelfTestHhMmSs('Tx interval', v),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Tx interval',
                    helperText: 'HH:MM:SS (24-hour)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _measurementInterval,
                  validator: (v) =>
                      _validateSelfTestHhMmSs('Measurement interval', v),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Measurement interval',
                    helperText: 'HH:MM:SS (24-hour)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _apn,
                  maxLength: 31,
                  validator: _validateSelfTestApnSetAllGeneral,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'APN',
                    helperText: 'Up to 31 characters',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fastSms,
                  maxLength: 1,
                  keyboardType: TextInputType.number,
                  validator: _validateSelfTestFastSmsSetAllGeneral,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Fast SMS check',
                    helperText: '0 or 1',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _adminCell1,
                  keyboardType: TextInputType.phone,
                  validator: _validateSelfTestParameterizedSmsCell,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Admin cell no. 1',
                    helperText: '10 digits or +91 and 10 digits',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _adminCell2,
                  keyboardType: TextInputType.phone,
                  validator: _validateSelfTestParameterizedSmsCell,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Admin cell no. 2',
                    helperText: '10 digits or +91 and 10 digits',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _measurementStartTime,
                  validator: (v) =>
                      _validateSelfTestHhMmSs('Measurement start time', v),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Measurement start time',
                    helperText: 'HH:MM:SS (24-hour)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            if (!(_formKey.currentState?.validate() ?? false)) {
              return;
            }
            context.read<GeneralUserSelfTestDebugBloc>().add(
              SubmitGeneralUserParameterizedCommand(
                commandId: widget.prompt.commandId,
                value:
                    '${GeneralUserSelfTestDebugBloc.setAllGeneralParametersPayloadPrefix}'
                    '${jsonEncode(<String, String>{'stationId': _stationId.text, 'stationName': _stationName.text, 'txInterval': _txInterval.text, 'measurementInterval': _measurementInterval.text, 'apn': _apn.text, 'fastSmsCheck': _fastSms.text, 'adminCell1': _adminCell1.text, 'adminCell2': _adminCell2.text, 'measurementStartTime': _measurementStartTime.text})}',
              ),
            );
            Navigator.of(context).pop();
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}

class _SetAllServerParametersDialog extends StatefulWidget {
  const _SetAllServerParametersDialog({required this.prompt});

  final SelfTestSetAllServerParametersPrompt prompt;

  @override
  State<_SetAllServerParametersDialog> createState() =>
      _SetAllServerParametersDialogState();
}

class _SetAllServerParametersDialogState
    extends State<_SetAllServerParametersDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _stationId;
  late final TextEditingController _ftpAddress;
  late final TextEditingController _ftpPort;
  late final TextEditingController _ftpPath;
  late final TextEditingController _ftpUsername;
  late final TextEditingController _ftpPassword;
  late final TextEditingController _cellNo;
  int _txRedundancy = 0;
  bool _hidePasswordCharacters = true;

  @override
  void initState() {
    super.initState();
    final d = widget.prompt.initial;
    _stationId = TextEditingController(text: d.stationId);
    _ftpAddress = TextEditingController(text: d.ftpAddress);
    _ftpPort = TextEditingController(text: d.ftpPort);
    _ftpPath = TextEditingController(text: d.ftpPath);
    _ftpUsername = TextEditingController(text: d.ftpUsername);
    _ftpPassword = TextEditingController(text: d.ftpPassword);
    _cellNo = TextEditingController(text: d.cellNo);
    _txRedundancy = d.txRedundancy == 1 ? 1 : 0;
  }

  @override
  void dispose() {
    _stationId.dispose();
    _ftpAddress.dispose();
    _ftpPort.dispose();
    _ftpPath.dispose();
    _ftpUsername.dispose();
    _ftpPassword.dispose();
    _cellNo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.prompt;
    final hintStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6A7178));

    final header = <Widget>[];
    final warn = p.prefetchWarning?.trim();
    if (warn != null && warn.isNotEmpty) {
      header.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            warn,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFFBF360C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    final cat = p.catalogHelpText.trim();
    if (cat.isNotEmpty) {
      header.addAll([
        SelectableText(cat, style: hintStyle),
        const SizedBox(height: 8),
        Text(
          'FTP fields are sent as fixed 20 chars. Port is sent as 5 digits.',
          style: hintStyle,
        ),
        const SizedBox(height: 16),
      ]);
    }

    return AlertDialog(
      title: Text(p.testName),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                ...header,
                TextFormField(
                  controller: _stationId,
                  maxLength: 8,
                  validator: _validateSelfTestSetAllServerStationId,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Station id',
                    helperText: 'Up to 8 characters',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ftpAddress,
                  maxLength: 20,
                  validator: _validateSelfTestParameterizedFtp20,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'FTP server address',
                    helperText: '1–20 printable ASCII characters',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ftpPort,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  validator: _validateSelfTestParameterizedPort,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'FTP port',
                    helperText: '0–65535 (sent as 5 digits)',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ftpPath,
                  maxLength: 20,
                  validator: _validateSelfTestParameterizedFtp20,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'FTP path',
                    helperText: '1–20 printable ASCII characters',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ftpUsername,
                  maxLength: 20,
                  validator: _validateSelfTestParameterizedFtp20,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'FTP username',
                    helperText: '1–20 printable ASCII characters',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ftpPassword,
                  obscureText: _hidePasswordCharacters,
                  maxLength: 20,
                  validator: _validateSelfTestParameterizedFtp20,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'FTP password',
                    helperText: '1–20 printable ASCII characters',
                    border: const OutlineInputBorder(),
                    counterText: '',
                    suffixIcon: IconButton(
                      tooltip: _hidePasswordCharacters
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: () {
                        setState(() {
                          _hidePasswordCharacters = !_hidePasswordCharacters;
                        });
                      },
                      icon: Icon(
                        _hidePasswordCharacters
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cellNo,
                  keyboardType: TextInputType.phone,
                  validator: _validateSelfTestParameterizedSmsCell,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Cell no.',
                    helperText: '10 digits, or +91 and 10 digits',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'TX redundancy (R)',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _txRedundancy,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('0 — Disable')),
                    DropdownMenuItem(value: 1, child: Text('1 — Enable')),
                  ],
                  onChanged: (v) {
                    if (v == null) {
                      return;
                    }
                    setState(() => _txRedundancy = v);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            if (!(_formKey.currentState?.validate() ?? false)) {
              return;
            }
            context.read<GeneralUserSelfTestDebugBloc>().add(
              SubmitGeneralUserParameterizedCommand(
                commandId: widget.prompt.commandId,
                value:
                    '${GeneralUserSelfTestDebugBloc.setAllServerParametersPayloadPrefix}'
                    '${jsonEncode(<String, String>{'stationId': _stationId.text, 'ftpAddress': _ftpAddress.text, 'ftpPort': _ftpPort.text, 'ftpPath': _ftpPath.text, 'ftpUsername': _ftpUsername.text, 'ftpPassword': _ftpPassword.text, 'cellNo': _cellNo.text, 'txRedundancy': '$_txRedundancy'})}',
              ),
            );
            Navigator.of(context).pop();
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}

class _RestoreServerParametersDialog extends StatelessWidget {
  const _RestoreServerParametersDialog({required this.prompt});

  final SelfTestRestoreServerParametersPrompt prompt;

  @override
  Widget build(BuildContext context) {
    final hint = prompt.catalogHelpText.trim();
    return AlertDialog(
      title: Text(prompt.testName),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This will send the restore command to the device for this server profile.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6A7178)),
            ),
            if (hint.isNotEmpty) ...[
              const SizedBox(height: 8),
              SelectableText(
                hint,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF2A2F34)),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            context.read<GeneralUserSelfTestDebugBloc>().add(
              SubmitGeneralUserRestoreServerParameters(
                commandId: prompt.commandId,
              ),
            );
            Navigator.of(context).pop();
          },
          child: const Text('Restore'),
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
