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

/// List row subtitle: use request template when catalog description is empty or `NA`.
String _selfTestCommandListSubtitle(DrifterBuoyCommandModel command) {
  final desc = command.requestCommandDescription.trim();
  if (desc.isEmpty || desc.toUpperCase() == 'NA') {
    return command.requestCommand.trim();
  }
  return desc;
}

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

String? _validateSelfTestPrintableAsciiMax64NoComma(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter a value.';
  }
  final t = value.trim();
  if (t.contains(',')) {
    return 'Value cannot contain a comma.';
  }
  if (t.length > 64) {
    return 'Maximum 64 characters.';
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

String? _validateSelfTestDlCellNumber(int slot, String? value) {
  var s = value?.trim().replaceAll(RegExp(r'\s'), '') ?? '';
  if (s.isEmpty) {
    return 'Enter a number.';
  }
  if (slot == 1 || slot == 2) {
    if (s.startsWith('+91')) {
      final digits = s.substring(3);
      if (digits.length == 10 && RegExp(r'^[0-9]{10}$').hasMatch(digits)) {
        return null;
      }
      return 'Use +91 followed by 10 digits, or enter 13 digits only.';
    }
    if (s.length == 13 && RegExp(r'^[0-9]{13}$').hasMatch(s)) {
      return null;
    }
    return 'Use +91 and 10 digits, or a 13-digit number.';
  }
  if (s.startsWith('+91')) {
    return 'MSISDN must be 13 digits only (no +91).';
  }
  if (s.length == 13 && RegExp(r'^[0-9]{13}$').hasMatch(s)) {
    return null;
  }
  return 'Enter exactly 13 digits (no +91).';
}

String _dlCellSlotHelperText(int slot) {
  return switch (slot) {
    1 => 'D.L. cell no. 1 — +91 and 10 digits, or 13 digits.',
    2 => 'D.L. cell no. 2 — +91 and 10 digits, or 13 digits.',
    3 => 'MSISDN no. 1 — 13 digits only (no +91).',
    4 => 'MSISDN no. 2 — 13 digits only (no +91).',
    _ => '',
  };
}

String? _validateSelfTestPowerSwitchingValue(String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) {
    return 'Enter a value for N.';
  }
  if (!RegExp(r'^\d+$').hasMatch(t)) {
    return 'Use digits only (e.g. 20).';
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

String? _validateSelfTestGetSensorParameter83Number(String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) {
    return 'Enter a sensor number (00 to 99).';
  }
  final v = int.tryParse(t);
  if (v == null || v < 0 || v > 99) {
    return 'Sensor number must be between 00 and 99.';
  }
  return null;
}

/// `?86` value — sent exactly as entered; spaces, `+`, and `-` are preserved.
String? _validateSelfTestIndividualSensorParameterValue(String? value) {
  final t = value ?? '';
  if (t.isEmpty) {
    return 'Value is required.';
  }
  if (t.contains(',')) {
    return 'Value cannot contain a comma.';
  }
  return null;
}

String? _validateSelfTestSensorFieldNoComma(
  String label,
  String? value, {
  int? maxLength,
}) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) {
    return '$label is required.';
  }
  if (t.contains(',')) {
    return '$label cannot contain a comma.';
  }
  if (maxLength != null && t.length > maxLength) {
    return '$label: at most $maxLength characters.';
  }
  return null;
}

/// Outlined text field used in SET sensor (`?80` / `?82`) forms.
Widget _buildSelfTestSensorSetInputField({
  required TextEditingController controller,
  required String label,
  String? hint,
  String? helper,
  int? maxLength,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(color: Color(0xFF2A2F34), fontSize: 15),
      validator:
          validator ??
          ((v) => _validateSelfTestSensorFieldNoComma(
            label,
            v,
            maxLength: maxLength,
          )),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        filled: true,
        fillColor: Colors.white,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB0B8C0)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
        counterText: maxLength != null ? '' : null,
      ),
    ),
  );
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

String _selfTestEffectiveHhMmSsInitial(String current, String fallback) {
  final t = current.trim();
  if (_validateSelfTestHhMmSs('Time', t.isEmpty ? null : t) == null) {
    return t;
  }
  return fallback;
}

String? _validateSelfTestTransmissionIntervalHhMmSs(String? value) {
  final base = _validateSelfTestHhMmSs('Transmission interval', value);
  if (base != null) {
    return base;
  }
  final raw = value!.trim();
  final m = RegExp(r'^(\d{2}):(\d{2}):(\d{2})$').firstMatch(raw)!;
  final total =
      int.parse(m.group(1)!) * 3600 +
      int.parse(m.group(2)!) * 60 +
      int.parse(m.group(3)!);
  if (total < 10 * 60) {
    return 'Transmission interval must be at least 00:10:00.';
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
  bool _isFastSmsCheckDialogOpen = false;
  bool _isAdminSmsCellDialogOpen = false;
  bool _isTransmitterFrequencyDialogOpen = false;
  bool _isSetAttenuationDialogOpen = false;
  bool _isRadioSondeTransmitterIdDialogOpen = false;
  bool _isUhfSondeTxInTimeDialogOpen = false;
  bool _isTransmitterTestDialogOpen = false;
  bool _isCheckStatusDialogOpen = false;
  bool _isParameterizedCommandDialogOpen = false;
  bool _isSetSensorAllParametersDialogOpen = false;
  bool _isSetSensorsParametersDialogOpen = false;
  bool _isSetIndividualSensorParameterDialogOpen = false;
  bool _isSetAllGeneralParametersDialogOpen = false;
  bool _isSetAllServerParametersDialogOpen = false;
  bool _isRestoreDefaultParametersDialogOpen = false;
  bool _isRestoreServerParametersDialogOpen = false;
  bool _isResponseSnapshotDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _commandSearchController = TextEditingController();
  }

  @override
  void dispose() {
    _commandSearchController.dispose();
    super.dispose();
  }

  Future<void> _showBleResponseSnapshotDialog(
    BuildContext context,
    SelfTestBleResponseSnapshot snap,
  ) async {
    if (_isResponseSnapshotDialogOpen) {
      return;
    }
    _isResponseSnapshotDialogOpen = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
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
                      style: Theme.of(
                        ctx,
                      ).textTheme.compactSectionTitle(const Color(0xFF1D2329)),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      snap.responseLine,
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF2A2F34),
                      ),
                    ),
                  ],
                  if (snap.helpText.isNotEmpty) ...[
                    if (!snap.hideResponseLine) const SizedBox(height: 16),
                    Text(
                      helpSectionTitle,
                      style: Theme.of(
                        ctx,
                      ).textTheme.compactSectionTitle(const Color(0xFF1D2329)),
                    ),
                    const SizedBox(height: 8),
                    _BleKeyValueSummary(
                      text: snap.helpText,
                      valueStyle: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: descriptionColor,
                        fontWeight: snap.descriptionSuccess == null
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
    } finally {
      _isResponseSnapshotDialogOpen = false;
    }
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
                  final bloc = context.read<GeneralUserSelfTestDebugBloc>();
                  final stationId = draftStationId;
                  Navigator.of(ctx).pop();
                  _runAfterDialogRouteClosed(() {
                    bloc.add(SubmitGeneralUserSetStationId(stationId));
                  });
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
                  final bloc = context.read<GeneralUserSelfTestDebugBloc>();
                  final stationName = draftStationName.trim();
                  Navigator.of(ctx).pop();
                  _runAfterDialogRouteClosed(() {
                    bloc.add(SubmitGeneralUserSetStationName(stationName));
                  });
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
    SelfTestMeasurementTimePrompt prompt,
  ) async {
    if (_isMeasurementTimeDialogOpen) {
      return;
    }
    _isMeasurementTimeDialogOpen = true;
    var draftTime = '00:00:00';
    final formKey = GlobalKey<FormState>();

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text(prompt.testName),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '?61 — enter measurement start time as HH:MM:SS (e.g. 00:15:10).',
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6A7178),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: '00:00:00',
                      keyboardType: TextInputType.datetime,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (v) =>
                          _validateSelfTestHhMmSs('Measurement start time', v),
                      onChanged: (v) => draftTime = v,
                      decoration: const InputDecoration(
                        labelText: 'Measurement start time',
                        hintText: '00:00:00',
                        helperText: 'HH:MM:SS (24-hour)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
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
                  if (!(formKey.currentState?.validate() ?? false)) {
                    return;
                  }
                  final bloc = context.read<GeneralUserSelfTestDebugBloc>();
                  final time = draftTime.trim();
                  Navigator.of(ctx).pop();
                  _runAfterDialogRouteClosed(() {
                    bloc.add(SubmitGeneralUserMeasurementStartTime(time));
                  });
                },
                child: const Text('Send'),
              ),
            ],
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
    var draftTime = '00:00:00';
    final formKey = GlobalKey<FormState>();

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text(prompt.testName),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '?08 — enter transmission time as HH:MM:SS (e.g. 00:01:10).',
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6A7178),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: '00:00:00',
                      keyboardType: TextInputType.datetime,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (v) =>
                          _validateSelfTestHhMmSs('Transmission time', v),
                      onChanged: (v) => draftTime = v,
                      decoration: const InputDecoration(
                        labelText: 'Transmission time',
                        hintText: '00:00:00',
                        helperText: 'HH:MM:SS (24-hour)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
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
                  if (!(formKey.currentState?.validate() ?? false)) {
                    return;
                  }
                  final bloc = context.read<GeneralUserSelfTestDebugBloc>();
                  final time = draftTime.trim();
                  Navigator.of(ctx).pop();
                  _runAfterDialogRouteClosed(() {
                    bloc.add(SubmitGeneralUserSetTransmissionTime(time));
                  });
                },
                child: const Text('Send'),
              ),
            ],
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
    final initialInterval = _selfTestEffectiveHhMmSsInitial(
      prompt.currentTxInterval,
      '00:10:00',
    );
    var draftInterval = initialInterval;
    final formKey = GlobalKey<FormState>();

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          final hint = prompt.catalogHelpText.trim();
          return AlertDialog(
            title: Text(prompt.testName),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '?09 — enter transmission interval as HH:MM:SS (min 00:10:00).',
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
                    TextFormField(
                      initialValue: initialInterval,
                      keyboardType: TextInputType.datetime,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: _validateSelfTestTransmissionIntervalHhMmSs,
                      onChanged: (v) => draftInterval = v,
                      decoration: const InputDecoration(
                        labelText: 'Transmission interval',
                        hintText: '00:10:00',
                        helperText: 'HH:MM:SS (24-hour), minimum 00:10:00',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
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
                  if (!(formKey.currentState?.validate() ?? false)) {
                    return;
                  }
                  final bloc = context.read<GeneralUserSelfTestDebugBloc>();
                  final interval = draftInterval.trim();
                  Navigator.of(ctx).pop();
                  _runAfterDialogRouteClosed(() {
                    bloc.add(
                      SubmitGeneralUserSetTransmissionInterval(interval),
                    );
                  });
                },
                child: const Text('Send'),
              ),
            ],
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
    final initialInterval = _selfTestEffectiveHhMmSsInitial(
      prompt.currentMeasurementInterval,
      '00:10:00',
    );
    var draftInterval = initialInterval;
    final formKey = GlobalKey<FormState>();

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          final hint = prompt.catalogHelpText.trim();
          return AlertDialog(
            title: Text(prompt.testName),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '?10 — enter measurement interval as HH:MM:SS.',
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
                    TextFormField(
                      initialValue: initialInterval,
                      keyboardType: TextInputType.datetime,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (v) =>
                          _validateSelfTestHhMmSs('Measurement interval', v),
                      onChanged: (v) => draftInterval = v,
                      decoration: const InputDecoration(
                        labelText: 'Measurement interval',
                        hintText: '00:10:00',
                        helperText: 'HH:MM:SS (24-hour)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
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
                  if (!(formKey.currentState?.validate() ?? false)) {
                    return;
                  }
                  final bloc = context.read<GeneralUserSelfTestDebugBloc>();
                  final interval = draftInterval.trim();
                  Navigator.of(ctx).pop();
                  _runAfterDialogRouteClosed(() {
                    bloc.add(
                      SubmitGeneralUserSetMeasurementInterval(
                        measurementInterval: interval,
                      ),
                    );
                  });
                },
                child: const Text('Send'),
              ),
            ],
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

  Future<void> _showFastSmsCheckDialog(
    BuildContext context,
    SelfTestFastSmsCheckPrompt prompt,
  ) async {
    if (_isFastSmsCheckDialogOpen) {
      return;
    }
    _isFastSmsCheckDialogOpen = true;
    var enabled = prompt.enabled;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setLocalState) {
              final hint = prompt.catalogHelpText.trim();
              final warn = prompt.prefetchWarning?.trim();
              return AlertDialog(
                title: Text(prompt.testName),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (warn != null && warn.isNotEmpty) ...[
                        Text(
                          warn,
                          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFBF360C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (hint.isNotEmpty) ...[
                        SelectableText(
                          hint,
                          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6A7178),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        'N = 0 disable, N = 1 enable. Sends ?58,N,#',
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6A7178),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Fast SMS check'),
                        subtitle: Text(
                          enabled ? 'Enabled (1)' : 'Disabled (0)',
                        ),
                        value: enabled,
                        onChanged: (v) {
                          setLocalState(() => enabled = v);
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
                      final bloc = context.read<GeneralUserSelfTestDebugBloc>();
                      final fastSmsEnabled = enabled;
                      Navigator.of(ctx).pop();
                      _runAfterDialogRouteClosed(() {
                        bloc.add(
                          SubmitGeneralUserFastSmsCheck(
                            enabled: fastSmsEnabled,
                          ),
                        );
                      });
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
          const ClearGeneralUserFastSmsCheckPrompt(),
        );
      }
    } finally {
      _isFastSmsCheckDialogOpen = false;
    }
  }

  Future<void> _showAdminSmsCellDialog(
    BuildContext context,
    SelfTestAdminSmsCellPrompt prompt,
  ) async {
    if (_isAdminSmsCellDialogOpen) {
      return;
    }
    _isAdminSmsCellDialogOpen = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => BlocProvider<GeneralUserSelfTestDebugBloc>.value(
          value: context.read<GeneralUserSelfTestDebugBloc>(),
          child: _AdminSmsCellAlertDialog(prompt: prompt),
        ),
      );
      if (context.mounted) {
        context.read<GeneralUserSelfTestDebugBloc>().add(
          const ClearGeneralUserAdminSmsCellPrompt(),
        );
      }
    } finally {
      _isAdminSmsCellDialogOpen = false;
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
                        maxLength: 9,
                        keyboardType: TextInputType.number,
                        onChanged: (v) => draftFfff = v,
                        decoration: const InputDecoration(
                          labelText: 'Frequency (9 digits)',
                          border: OutlineInputBorder(),
                          hintText: '000402500',
                          helperText:
                              '402.0000–403.0000 MHz. Sent as nine digits.',
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
                      final bloc = context.read<GeneralUserSelfTestDebugBloc>();
                      final transmitterType = draftType;
                      final frequencyValue = draftFfff;
                      Navigator.of(ctx).pop();
                      _runAfterDialogRouteClosed(() {
                        bloc.add(
                          SubmitGeneralUserTransmitterFrequency(
                            transmitterType: transmitterType,
                            frequencyValue: frequencyValue,
                          ),
                        );
                      });
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
                      final bloc = context.read<GeneralUserSelfTestDebugBloc>();
                      final transmitterType = draftType;
                      final attenuationValue = draftXx;
                      Navigator.of(ctx).pop();
                      _runAfterDialogRouteClosed(() {
                        bloc.add(
                          SubmitGeneralUserSetAttenuation(
                            transmitterType: transmitterType,
                            attenuationValue: attenuationValue,
                          ),
                        );
                      });
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
                    'Enter 3-character transmitter station id',
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6A7178),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: currentId,
                    maxLength: 3,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (v) => draftId = v,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'XXX',
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
                  final bloc = context.read<GeneralUserSelfTestDebugBloc>();
                  final transmitterId = draftId;
                  Navigator.of(ctx).pop();
                  _runAfterDialogRouteClosed(() {
                    bloc.add(
                      SubmitGeneralUserRadioSondeTransmitterId(transmitterId),
                    );
                  });
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

  String _uhfSondeTxInTimeForField(
    SelfTestUhfSondeTxInTimePrompt prompt,
    int fieldN,
  ) {
    return switch (fieldN) {
      1 => prompt.uhfStartTime,
      2 => prompt.uhfIntervalTime,
      3 => prompt.sondeStartTime,
      4 => prompt.sondeIntervalTime,
      _ => '00:00:00',
    };
  }

  Future<void> _showUhfSondeTxInTimeDialog(
    BuildContext context,
    SelfTestUhfSondeTxInTimePrompt prompt,
  ) async {
    if (_isUhfSondeTxInTimeDialogOpen) {
      return;
    }
    _isUhfSondeTxInTimeDialogOpen = true;
    var draftN = 1;
    var draftTime = _uhfSondeTxInTimeForField(prompt, draftN);
    final formKey = GlobalKey<FormState>();

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setLocalState) {
              return AlertDialog(
                title: Text(prompt.testName),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (prompt.prefetchWarning != null) ...[
                          Text(
                            prompt.prefetchWarning!,
                            style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFB3261E),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          'N = 1 UHF start, 2 UHF interval, 3 Sonde start, 4 Sonde interval.',
                          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6A7178),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: draftN,
                          items: const [
                            DropdownMenuItem(
                              value: 1,
                              child: Text('1 — UHF Transmission Start Time'),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text('2 — UHF Interval Time'),
                            ),
                            DropdownMenuItem(
                              value: 3,
                              child: Text('3 — Sonde Transmission Start Time'),
                            ),
                            DropdownMenuItem(
                              value: 4,
                              child: Text('4 — Sonde Interval Time'),
                            ),
                          ],
                          onChanged: (v) {
                            setLocalState(() {
                              draftN = v ?? 1;
                              draftTime = _uhfSondeTxInTimeForField(
                                prompt,
                                draftN,
                              );
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Field (N)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: ValueKey<int>(draftN),
                          initialValue: draftTime,
                          keyboardType: TextInputType.datetime,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (v) =>
                              _validateSelfTestHhMmSs('Time', v),
                          onChanged: (v) => draftTime = v,
                          decoration: const InputDecoration(
                            labelText: 'Time (HH:MM:SS)',
                            hintText: '00:00:00',
                            helperText: '24-hour format',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
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
                      if (!(formKey.currentState?.validate() ?? false)) {
                        return;
                      }
                      final bloc = context.read<GeneralUserSelfTestDebugBloc>();
                      final fieldN = draftN;
                      final time = draftTime.trim();
                      Navigator.of(ctx).pop();
                      _runAfterDialogRouteClosed(() {
                        bloc.add(
                          SubmitGeneralUserUhfSondeTxInTime(
                            fieldN: fieldN,
                            timeValue: time,
                          ),
                        );
                      });
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
          const ClearGeneralUserUhfSondeTxInTimePrompt(),
        );
      }
    } finally {
      _isUhfSondeTxInTimeDialogOpen = false;
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
                      final bloc = context.read<GeneralUserSelfTestDebugBloc>();
                      final plainCarrierOn = selectedN == 0;
                      final modulationOn = selectedN == 1;
                      final prbsOn = selectedN == 2;
                      Navigator.of(ctx).pop();
                      _runAfterDialogRouteClosed(() {
                        bloc.add(
                          SubmitGeneralUserTransmitterTest(
                            plainCarrierOn: plainCarrierOn,
                            modulationOn: modulationOn,
                            prbsOn: prbsOn,
                          ),
                        );
                      });
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

  Future<void> _showSetSensorAllParametersDialog(
    BuildContext context,
    SelfTestSetSensorAllParametersPrompt prompt,
  ) async {
    if (_isSetSensorAllParametersDialogOpen) {
      return;
    }
    _isSetSensorAllParametersDialogOpen = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return BlocProvider<GeneralUserSelfTestDebugBloc>.value(
            value: context.read<GeneralUserSelfTestDebugBloc>(),
            child: _SetSensorAllParametersDialog(prompt: prompt),
          );
        },
      );
    } finally {
      _isSetSensorAllParametersDialogOpen = false;
    }
    if (!context.mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      context.read<GeneralUserSelfTestDebugBloc>().add(
        const ClearGeneralUserSetSensorAllParametersPrompt(),
      );
    });
  }

  Future<void> _showSetSensorsParametersDialog(
    BuildContext context,
    SelfTestSetSensorsParametersPrompt prompt,
  ) async {
    if (_isSetSensorsParametersDialogOpen) {
      return;
    }
    _isSetSensorsParametersDialogOpen = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return BlocProvider<GeneralUserSelfTestDebugBloc>.value(
            value: context.read<GeneralUserSelfTestDebugBloc>(),
            child: _SetSensorsParametersDialog(prompt: prompt),
          );
        },
      );
    } finally {
      _isSetSensorsParametersDialogOpen = false;
    }
    if (!context.mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      context.read<GeneralUserSelfTestDebugBloc>().add(
        const ClearGeneralUserSetSensorsParametersPrompt(),
      );
    });
  }

  Future<void> _showSetIndividualSensorParameterDialog(
    BuildContext context,
    SelfTestSetIndividualSensorParameterPrompt prompt,
  ) async {
    if (_isSetIndividualSensorParameterDialogOpen) {
      return;
    }
    _isSetIndividualSensorParameterDialogOpen = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return BlocProvider<GeneralUserSelfTestDebugBloc>.value(
            value: context.read<GeneralUserSelfTestDebugBloc>(),
            child: _SetIndividualSensorParameterDialog(prompt: prompt),
          );
        },
      );
    } finally {
      _isSetIndividualSensorParameterDialogOpen = false;
    }
    if (!context.mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      context.read<GeneralUserSelfTestDebugBloc>().add(
        const ClearGeneralUserSetIndividualSensorParameterPrompt(),
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

  Future<void> _showRestoreDefaultParametersDialog(
    BuildContext context,
    SelfTestRestoreDefaultParametersPrompt prompt,
  ) async {
    if (_isRestoreDefaultParametersDialogOpen) {
      return;
    }
    _isRestoreDefaultParametersDialogOpen = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return BlocProvider<GeneralUserSelfTestDebugBloc>.value(
            value: context.read<GeneralUserSelfTestDebugBloc>(),
            child: _RestoreDefaultParametersDialog(prompt: prompt),
          );
        },
      );
    } finally {
      _isRestoreDefaultParametersDialogOpen = false;
    }
    if (!context.mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      context.read<GeneralUserSelfTestDebugBloc>().add(
        const ClearGeneralUserRestoreDefaultParametersPrompt(),
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            MultiBlocListener(
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
                    _showMeasurementStartTimeDialog(context, prompt);
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
                      c.transmissionIntervalPrompt !=
                          p.transmissionIntervalPrompt,
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
                      c.measurementIntervalPrompt !=
                          p.measurementIntervalPrompt,
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
                      c.setApnPrompt != null &&
                      c.setApnPrompt != p.setApnPrompt,
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
                      c.fastSmsCheckPrompt != null &&
                      c.fastSmsCheckPrompt != p.fastSmsCheckPrompt,
                  listener: (context, state) {
                    final prompt = state.fastSmsCheckPrompt;
                    if (prompt == null || _isFastSmsCheckDialogOpen) {
                      return;
                    }
                    _showFastSmsCheckDialog(context, prompt);
                  },
                ),
                BlocListener<
                  GeneralUserSelfTestDebugBloc,
                  GeneralUserSelfTestDebugState
                >(
                  listenWhen: (p, c) =>
                      c.adminSmsCellPrompt != null &&
                      c.adminSmsCellPrompt != p.adminSmsCellPrompt,
                  listener: (context, state) {
                    final prompt = state.adminSmsCellPrompt;
                    if (prompt == null || _isAdminSmsCellDialogOpen) {
                      return;
                    }
                    _showAdminSmsCellDialog(context, prompt);
                  },
                ),
                BlocListener<
                  GeneralUserSelfTestDebugBloc,
                  GeneralUserSelfTestDebugState
                >(
                  listenWhen: (p, c) =>
                      c.transmitterFrequencyPrompt != null &&
                      c.transmitterFrequencyPrompt !=
                          p.transmitterFrequencyPrompt,
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
                    if (prompt == null ||
                        _isRadioSondeTransmitterIdDialogOpen) {
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
                      c.uhfSondeTxInTimePrompt != null &&
                      c.uhfSondeTxInTimePrompt != p.uhfSondeTxInTimePrompt,
                  listener: (context, state) {
                    final prompt = state.uhfSondeTxInTimePrompt;
                    if (prompt == null || _isUhfSondeTxInTimeDialogOpen) {
                      return;
                    }
                    _showUhfSondeTxInTimeDialog(context, prompt);
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
                      c.parameterizedCommandPrompt !=
                          p.parameterizedCommandPrompt,
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
                      c.setSensorAllParametersPrompt != null &&
                      c.setSensorAllParametersPrompt !=
                          p.setSensorAllParametersPrompt,
                  listener: (context, state) {
                    final prompt = state.setSensorAllParametersPrompt;
                    if (prompt == null || _isSetSensorAllParametersDialogOpen) {
                      return;
                    }
                    _showSetSensorAllParametersDialog(context, prompt);
                  },
                ),
                BlocListener<
                  GeneralUserSelfTestDebugBloc,
                  GeneralUserSelfTestDebugState
                >(
                  listenWhen: (p, c) =>
                      c.setSensorsParametersPrompt != null &&
                      c.setSensorsParametersPrompt !=
                          p.setSensorsParametersPrompt,
                  listener: (context, state) {
                    final prompt = state.setSensorsParametersPrompt;
                    if (prompt == null || _isSetSensorsParametersDialogOpen) {
                      return;
                    }
                    _showSetSensorsParametersDialog(context, prompt);
                  },
                ),
                BlocListener<
                  GeneralUserSelfTestDebugBloc,
                  GeneralUserSelfTestDebugState
                >(
                  listenWhen: (p, c) =>
                      c.setIndividualSensorParameterPrompt != null &&
                      c.setIndividualSensorParameterPrompt !=
                          p.setIndividualSensorParameterPrompt,
                  listener: (context, state) {
                    final prompt = state.setIndividualSensorParameterPrompt;
                    if (prompt == null ||
                        _isSetIndividualSensorParameterDialogOpen) {
                      return;
                    }
                    _showSetIndividualSensorParameterDialog(context, prompt);
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
                    if (prompt == null ||
                        _isSetAllGeneralParametersDialogOpen) {
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
                      c.restoreDefaultParametersPrompt != null &&
                      c.restoreDefaultParametersPrompt !=
                          p.restoreDefaultParametersPrompt,
                  listener: (context, state) {
                    final prompt = state.restoreDefaultParametersPrompt;
                    if (prompt == null ||
                        _isRestoreDefaultParametersDialogOpen) {
                      return;
                    }
                    _showRestoreDefaultParametersDialog(context, prompt);
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
                    if (prompt == null ||
                        _isRestoreServerParametersDialogOpen) {
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
                      c.lastSnapshot != null &&
                      c.lastSnapshot != p.lastSnapshot,
                  listener: (context, state) {
                    final snap = state.lastSnapshot;
                    if (snap == null) {
                      return;
                    }
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!context.mounted) {
                        return;
                      }
                      _showBleResponseSnapshotDialog(context, snap);
                    });
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
                                  suffixIcon:
                                      _commandSearchController.text.isEmpty
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
                                            .read<
                                              GeneralUserSelfTestDebugBloc
                                            >();
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
                                                _selfTestCommandListSubtitle(
                                                  command,
                                                ),
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
            BlocBuilder<
              GeneralUserSelfTestDebugBloc,
              GeneralUserSelfTestDebugState
            >(
              buildWhen: (p, c) => p.status != c.status,
              builder: (context, state) {
                if (state.status != GeneralUserSelfTestDebugStatus.running) {
                  return const SizedBox.shrink();
                }
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ModalBarrier(
                      dismissible: false,
                      color: Colors.black54,
                      semanticsLabel: MaterialLocalizations.of(
                        context,
                      ).modalBarrierDismissLabel,
                    ),
                    Center(
                      child: _BleCommandProgressDialog(
                        theme: Theme.of(context),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen blocking card while a BLE command is in progress.
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

/// Runs [action] after the dialog route has closed so parent rebuilds do not
/// touch fields still animating out.
void _runAfterDialogRouteClosed(void Function() action) {
  WidgetsBinding.instance.addPostFrameCallback((_) => action());
}

/// Owns [TextEditingController] lifetime so it is not disposed while the route is still tearing down.
class _AdminSmsCellAlertDialog extends StatefulWidget {
  const _AdminSmsCellAlertDialog({required this.prompt});

  final SelfTestAdminSmsCellPrompt prompt;

  @override
  State<_AdminSmsCellAlertDialog> createState() =>
      _AdminSmsCellAlertDialogState();
}

class _AdminSmsCellAlertDialogState extends State<_AdminSmsCellAlertDialog> {
  late final TextEditingController _mobileController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _mobileController = TextEditingController(
      text: widget.prompt.initialMobileNumber,
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prompt = widget.prompt;
    final hint = prompt.catalogHelpText.trim();
    final warn = prompt.prefetchWarning?.trim();
    return AlertDialog(
      title: Text(prompt.testName),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (warn != null && warn.isNotEmpty) ...[
                Text(
                  warn,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFBF360C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (hint.isNotEmpty) ...[
                SelectableText(
                  hint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6A7178),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                validator: _validateSelfTestParameterizedSmsCell,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                  labelText: 'Mobile number',
                  helperText: '10 digits, or +91 and 10 digits',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
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
            final bloc = context.read<GeneralUserSelfTestDebugBloc>();
            final commandId = prompt.commandId;
            final mobileNumber = _mobileController.text;
            Navigator.of(context).pop();
            _runAfterDialogRouteClosed(() {
              bloc.add(
                SubmitGeneralUserAdminSmsCell(
                  commandId: commandId,
                  mobileNumber: mobileNumber,
                ),
              );
            });
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}

/// Renders `Key: Value` summary lines as aligned rows (BLE response popups).
class _BleKeyValueSummary extends StatelessWidget {
  const _BleKeyValueSummary({required this.text, this.valueStyle});

  final String text;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyStyle = theme.textTheme.bodySmall?.copyWith(
      color: const Color(0xFF5C6368),
      fontWeight: FontWeight.w600,
    );
    final defaultValueStyle = theme.textTheme.bodySmall?.copyWith(
      color: const Color(0xFF2A2F34),
    );
    final valueStyleResolved = valueStyle ?? defaultValueStyle;
    const errorValueColor = Color(0xFFB3261E);

    TextStyle rowValueStyle(String value) {
      if (value.contains('— Error')) {
        return (defaultValueStyle ?? const TextStyle()).copyWith(
          color: errorValueColor,
          fontWeight: FontWeight.w600,
        );
      }
      return valueStyleResolved ?? defaultValueStyle!;
    }

    String? heading;
    final entries = <MapEntry<String, String>>[];
    for (final rawLine in text.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        continue;
      }
      final colon = line.indexOf(': ');
      if (colon > 0) {
        entries.add(
          MapEntry(line.substring(0, colon), line.substring(colon + 2)),
        );
      } else if (entries.isEmpty) {
        heading = line;
      }
    }

    if (entries.isEmpty) {
      return SelectableText(text, style: valueStyleResolved);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (heading != null) ...[
          SelectableText(heading, style: defaultValueStyle),
          const SizedBox(height: 12),
        ],
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 132,
                child: SelectableText('${entries[i].key}:', style: keyStyle),
              ),
              Expanded(
                child: SelectableText(
                  entries[i].value,
                  style: rowValueStyle(entries[i].value),
                ),
              ),
            ],
          ),
        ],
      ],
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
            _runAfterDialogRouteClosed(() {
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

const _httpWebsiteFieldHint =
    '1 = HTTP server URL, 2 = HTTP server key, 3 = HTTP data';

bool _isHttpWebsiteAddressFieldKind(
  SelfTestParameterizedCommandFieldKind kind,
) {
  return kind ==
          SelfTestParameterizedCommandFieldKind.primaryHttpWebsiteIndex128 ||
      kind ==
          SelfTestParameterizedCommandFieldKind
              .secondaryHttpWebsiteIndex0to3And128 ||
      kind ==
          SelfTestParameterizedCommandFieldKind
              .thirdHttpWebsiteIndex0to3And128Trailing40 ||
      kind ==
          SelfTestParameterizedCommandFieldKind
              .factoryHttpWebsiteIndex0to3And128;
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
    if (widget.prompt.fieldKind ==
        SelfTestParameterizedCommandFieldKind.setHttpPortIndex1to4FiveDigits) {
      _httpServerIndex = 0;
    } else if (widget.prompt.fieldKind ==
        SelfTestParameterizedCommandFieldKind.setHttpPasswordIndex1to4And64) {
      _httpServerIndex = 1;
    } else if (widget.prompt.fieldKind ==
            SelfTestParameterizedCommandFieldKind
                .httpServerUsernameIndex1to4And64 ||
        widget.prompt.fieldKind ==
            SelfTestParameterizedCommandFieldKind.dlCellNumberIndex1to4) {
      _httpServerIndex = 1;
    } else if (_isHttpWebsiteAddressFieldKind(widget.prompt.fieldKind)) {
      _httpServerIndex = 1;
    }
  }

  Widget _buildHttpWebsiteAddressFields({required String addressHelperText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: 'HTTP field',
            helperText: _httpWebsiteFieldHint,
            helperMaxLines: 2,
            border: OutlineInputBorder(),
          ),
          initialValue: _httpServerIndex.clamp(1, 3),
          items: const [
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
          decoration: InputDecoration(
            labelText: 'HTTP website address',
            helperText: addressHelperText,
            helperMaxLines: 2,
            border: const OutlineInputBorder(),
            counterText: '',
          ),
        ),
      ],
    );
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

    final reqTemplate = p.requestCommand.trim();
    if (reqTemplate.isNotEmpty) {
      header.add(
        SelectableText(
          'Command: $reqTemplate',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: const Color(0xFF2A2F34)),
        ),
      );
      header.add(const SizedBox(height: 8));
    }

    final help = p.requestHelpText.trim();
    if (help.isNotEmpty && help.toUpperCase() != 'NA') {
      header.add(
        SelectableText(
          help,
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
      case SelfTestParameterizedCommandFieldKind.setHttpPasswordIndex1to4And64:
        final httpPasswordSlot = _httpServerIndex.clamp(1, 4);
        field = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Server number (N)',
                border: OutlineInputBorder(),
              ),
              initialValue: httpPasswordSlot,
              items: const [
                DropdownMenuItem(value: 1, child: Text('1')),
                DropdownMenuItem(value: 2, child: Text('2')),
                DropdownMenuItem(value: 3, child: Text('3')),
                DropdownMenuItem(value: 4, child: Text('4')),
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
              maxLength: 64,
              obscureText: _hidePasswordCharacters,
              validator: _validateSelfTestPrintableAsciiMax64NoComma,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: 'HTTP password',
                helperText:
                    'Max 64 printable ASCII chars. Sends ?97,$httpPasswordSlot,password,#',
                border: const OutlineInputBorder(),
                counterText: '',
                suffixIcon: IconButton(
                  icon: Icon(
                    _hidePasswordCharacters
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(
                      () => _hidePasswordCharacters = !_hidePasswordCharacters,
                    );
                  },
                ),
              ),
            ),
          ],
        );
        break;
      case SelfTestParameterizedCommandFieldKind.setHttpPortIndex1to4FiveDigits:
        final httpPortSlot = _httpServerIndex.clamp(0, 3);
        field = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Server number (N)',
                border: OutlineInputBorder(),
              ),
              initialValue: httpPortSlot,
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
              keyboardType: TextInputType.number,
              maxLength: 5,
              validator: _validateSelfTestParameterizedPort,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: 'HTTP port (PPPPP)',
                helperText:
                    '0–65535. Sends ?98,$httpPortSlot,PPPPP,# (e.g. ?98,$httpPortSlot,11111,#).',
                border: const OutlineInputBorder(),
                counterText: '',
              ),
            ),
          ],
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
      case SelfTestParameterizedCommandFieldKind.testModeValue01:
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
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: 0,
                title: const Text('0'),
              ),
              RadioListTile<int>(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: 1,
                title: const Text('1'),
              ),
            ],
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
        field = _buildHttpWebsiteAddressFields(
          addressHelperText:
              'Max 128 printable ASCII. Catalog adds a trailing space when shorter than 128.',
        );
        break;
      case SelfTestParameterizedCommandFieldKind
          .secondaryHttpWebsiteIndex0to3And128:
        field = _buildHttpWebsiteAddressFields(
          addressHelperText:
              'Max 128 printable ASCII. Catalog adds a trailing space when shorter than 128.',
        );
        break;
      case SelfTestParameterizedCommandFieldKind
          .thirdHttpWebsiteIndex0to3And128Trailing40:
        field = _buildHttpWebsiteAddressFields(
          addressHelperText:
              'Max 128 printable ASCII. Catalog adds a trailing space when shorter than 40.',
        );
        break;
      case SelfTestParameterizedCommandFieldKind
          .factoryHttpWebsiteIndex0to3And128:
        field = _buildHttpWebsiteAddressFields(
          addressHelperText:
              'Max 128 printable ASCII. Catalog adds a trailing space when shorter than 128.',
        );
        break;
      case SelfTestParameterizedCommandFieldKind
          .httpServerUsernameIndex1to4And64:
        field = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'HTTP server number (N)',
                border: OutlineInputBorder(),
              ),
              initialValue: _httpServerIndex.clamp(1, 4),
              items: const [
                DropdownMenuItem(value: 1, child: Text('1')),
                DropdownMenuItem(value: 2, child: Text('2')),
                DropdownMenuItem(value: 3, child: Text('3')),
                DropdownMenuItem(value: 4, child: Text('4')),
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
              maxLength: 64,
              validator: _validateSelfTestPrintableAsciiMax64NoComma,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'HTTP server username',
                helperText:
                    'Max 64 printable ASCII chars. Shorter values are padded with spaces when sent.',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
          ],
        );
        break;
      case SelfTestParameterizedCommandFieldKind.dlCellNumberIndex1to4:
        final dlSlot = _httpServerIndex.clamp(1, 4);
        field = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Slot (N)',
                border: OutlineInputBorder(),
              ),
              initialValue: dlSlot,
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 — D.L. cell no. 1')),
                DropdownMenuItem(value: 2, child: Text('2 — D.L. cell no. 2')),
                DropdownMenuItem(value: 3, child: Text('3 — MSISDN no. 1')),
                DropdownMenuItem(value: 4, child: Text('4 — MSISDN no. 2')),
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
              keyboardType: TextInputType.phone,
              maxLength: dlSlot <= 2 ? 13 : 13,
              validator: (v) => _validateSelfTestDlCellNumber(dlSlot, v),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: 'Cell / MSISDN number',
                helperText: _dlCellSlotHelperText(dlSlot),
                border: const OutlineInputBorder(),
                counterText: '',
              ),
            ),
          ],
        );
        break;
      case SelfTestParameterizedCommandFieldKind.powerSwitchingValueN:
        field = TextFormField(
          controller: _textController,
          keyboardType: TextInputType.number,
          validator: _validateSelfTestPowerSwitchingValue,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Power switching value (N)',
            helperText: 'Example: 20 sends ?76,20,#',
            border: OutlineInputBorder(),
          ),
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
      case SelfTestParameterizedCommandFieldKind
          .getSensorParameter83SensorNumber:
        field = TextFormField(
          controller: _textController,
          keyboardType: TextInputType.number,
          maxLength: 2,
          validator: _validateSelfTestGetSensorParameter83Number,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Sensor number',
            helperText: '00 to 99 (sent as two digits, e.g. 01 → ?83,01,#).',
            border: OutlineInputBorder(),
            counterText: '',
          ),
        );
        break;
    }

    final isBatteryVoltage =
        p.fieldKind ==
        SelfTestParameterizedCommandFieldKind.batteryVoltageIndex00to11;
    final isGetSensorParameter83 =
        p.fieldKind ==
        SelfTestParameterizedCommandFieldKind.getSensorParameter83SensorNumber;

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
                    SelfTestParameterizedCommandFieldKind.txRedundancy01 &&
                p.fieldKind !=
                    SelfTestParameterizedCommandFieldKind.testModeValue01) {
              if (!(_formKey.currentState?.validate() ?? false)) {
                return;
              }
            }
            late final String value;
            if (p.fieldKind ==
                    SelfTestParameterizedCommandFieldKind.txRedundancy01 ||
                p.fieldKind ==
                    SelfTestParameterizedCommandFieldKind.testModeValue01) {
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
                        .factoryHttpWebsiteIndex0to3And128 ||
                p.fieldKind ==
                    SelfTestParameterizedCommandFieldKind
                        .httpServerUsernameIndex1to4And64 ||
                p.fieldKind ==
                    SelfTestParameterizedCommandFieldKind
                        .dlCellNumberIndex1to4 ||
                p.fieldKind ==
                    SelfTestParameterizedCommandFieldKind
                        .setHttpPortIndex1to4FiveDigits ||
                p.fieldKind ==
                    SelfTestParameterizedCommandFieldKind
                        .setHttpPasswordIndex1to4And64) {
              value = jsonEncode({
                'n': _httpServerIndex,
                'v': _textController.text.trim(),
              });
            } else {
              value = _textController.text;
            }
            final bloc = context.read<GeneralUserSelfTestDebugBloc>();
            final commandId = p.commandId;
            final requestCommand = p.requestCommand;
            Navigator.of(context).pop();
            _runAfterDialogRouteClosed(() {
              bloc.add(
                SubmitGeneralUserParameterizedCommand(
                  commandId: commandId,
                  value: value,
                  requestCommand: requestCommand,
                ),
              );
            });
          },
          child: Text(
            isBatteryVoltage || isGetSensorParameter83 ? 'Send' : 'Update',
          ),
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
            final bloc = context.read<GeneralUserSelfTestDebugBloc>();
            final commandId = widget.prompt.commandId;
            final payload =
                '${GeneralUserSelfTestDebugBloc.setAllGeneralParametersPayloadPrefix}'
                '${jsonEncode(<String, String>{'stationId': _stationId.text, 'stationName': _stationName.text, 'txInterval': _txInterval.text, 'measurementInterval': _measurementInterval.text, 'apn': _apn.text, 'fastSmsCheck': _fastSms.text, 'adminCell1': _adminCell1.text, 'adminCell2': _adminCell2.text, 'measurementStartTime': _measurementStartTime.text})}';
            Navigator.of(context).pop();
            _runAfterDialogRouteClosed(() {
              bloc.add(
                SubmitGeneralUserParameterizedCommand(
                  commandId: commandId,
                  value: payload,
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
            final bloc = context.read<GeneralUserSelfTestDebugBloc>();
            final commandId = widget.prompt.commandId;
            final payload =
                '${GeneralUserSelfTestDebugBloc.setAllServerParametersPayloadPrefix}'
                '${jsonEncode(<String, String>{'stationId': _stationId.text, 'ftpAddress': _ftpAddress.text, 'ftpPort': _ftpPort.text, 'ftpPath': _ftpPath.text, 'ftpUsername': _ftpUsername.text, 'ftpPassword': _ftpPassword.text, 'cellNo': _cellNo.text, 'txRedundancy': '$_txRedundancy'})}';
            Navigator.of(context).pop();
            _runAfterDialogRouteClosed(() {
              bloc.add(
                SubmitGeneralUserParameterizedCommand(
                  commandId: commandId,
                  value: payload,
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

class _RestoreDefaultParametersDialog extends StatelessWidget {
  const _RestoreDefaultParametersDialog({required this.prompt});

  final SelfTestRestoreDefaultParametersPrompt prompt;

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
              'This will restore factory default general system parameters on the device.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6A7178)),
            ),
            const SizedBox(height: 8),
            SelectableText(
              'Command: ?03,,#',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF2A2F34)),
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
            final bloc = context.read<GeneralUserSelfTestDebugBloc>();
            final commandId = prompt.commandId;
            Navigator.of(context).pop();
            _runAfterDialogRouteClosed(() {
              bloc.add(
                SubmitGeneralUserRestoreDefaultParameters(commandId: commandId),
              );
            });
          },
          child: const Text('Restore parameters'),
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
            final bloc = context.read<GeneralUserSelfTestDebugBloc>();
            final commandId = prompt.commandId;
            Navigator.of(context).pop();
            _runAfterDialogRouteClosed(() {
              bloc.add(
                SubmitGeneralUserRestoreServerParameters(commandId: commandId),
              );
            });
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

class _SetSensorAllParametersDialog extends StatefulWidget {
  const _SetSensorAllParametersDialog({required this.prompt});

  final SelfTestSetSensorAllParametersPrompt prompt;

  @override
  State<_SetSensorAllParametersDialog> createState() =>
      _SetSensorAllParametersDialogState();
}

class _SetSensorAllParametersDialogState
    extends State<_SetSensorAllParametersDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _sensorNo;
  late final TextEditingController _channelNo;
  late final TextEditingController _fg;
  late final TextEditingController _factoryOff;
  late final TextEditingController _senG;
  late final TextEditingController _soff;
  late final TextEditingController _resolution;
  late final TextEditingController _senMin;
  late final TextEditingController _sensMax;
  late final TextEditingController _averagScheme;
  late final TextEditingController _vactor;
  late final TextEditingController _startTime;
  late final TextEditingController _interval;
  late final TextEditingController _totalSample;
  late final TextEditingController _mode;
  late final TextEditingController _txG;
  late final TextEditingController _txO;

  @override
  void initState() {
    super.initState();
    final d = widget.prompt.initial;
    _sensorNo = TextEditingController(text: d.sensorNo);
    _channelNo = TextEditingController(text: d.channelNo);
    _fg = TextEditingController(text: d.fg);
    _factoryOff = TextEditingController(text: d.factoryOff);
    _senG = TextEditingController(text: d.senG);
    _soff = TextEditingController(text: d.soff);
    _resolution = TextEditingController(text: d.resolution);
    _senMin = TextEditingController(text: d.senMin);
    _sensMax = TextEditingController(text: d.sensMax);
    _averagScheme = TextEditingController(text: d.averagScheme);
    _vactor = TextEditingController(text: d.vactor);
    _startTime = TextEditingController(text: d.startTime);
    _interval = TextEditingController(text: d.interval);
    _totalSample = TextEditingController(text: d.totalSample);
    _mode = TextEditingController(text: d.mode);
    _txG = TextEditingController(text: d.txG);
    _txO = TextEditingController(text: d.txO);
  }

  @override
  void dispose() {
    _sensorNo.dispose();
    _channelNo.dispose();
    _fg.dispose();
    _factoryOff.dispose();
    _senG.dispose();
    _soff.dispose();
    _resolution.dispose();
    _senMin.dispose();
    _sensMax.dispose();
    _averagScheme.dispose();
    _vactor.dispose();
    _startTime.dispose();
    _interval.dispose();
    _totalSample.dispose();
    _mode.dispose();
    _txG.dispose();
    _txO.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.72;
    return AlertDialog(
      title: Text(widget.prompt.testName),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480, maxHeight: maxH),
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter all parameters below. Command is sent as ?80,...,# '
                    '(BLE writes in chunks).',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6A7178),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSelfTestSensorSetInputField(
                    controller: _sensorNo,
                    label: 'Sensor no',
                    hint: '01',
                    maxLength: 2,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _channelNo,
                    label: 'Channel no',
                    hint: '20',
                    maxLength: 2,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _fg,
                    label: 'F.G',
                    hint: '00003.81475',
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _factoryOff,
                    label: 'Factory off',
                    hint: '+00000.00000',
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _senG,
                    label: 'senG',
                    hint: '+00001.00000',
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _soff,
                    label: 'S.off',
                    hint: '+00000.00000',
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _resolution,
                    label: 'Resolution',
                    hint: '00000.00100',
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _senMin,
                    label: 'Sen Min',
                    hint: '-00040.00000',
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _sensMax,
                    label: 'Sens Max',
                    hint: '+00060.00000',
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _averagScheme,
                    label: 'Averag Scheme',
                    hint: '0',
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _vactor,
                    label: 'Vactor',
                    hint: '00',
                    maxLength: 2,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _startTime,
                    label: 'Start time',
                    hint: '00:59:07',
                    helper: 'HH:MM:SS',
                    validator: (v) => _validateSelfTestHhMmSs('Start time', v),
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _interval,
                    label: 'Interval',
                    hint: '01:00:00',
                    helper: 'HH:MM:SS',
                    validator: (v) => _validateSelfTestHhMmSs('Interval', v),
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _totalSample,
                    label: 'Total sample',
                    hint: '01',
                    maxLength: 2,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _mode,
                    label: 'Mode',
                    hint: '1',
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _txG,
                    label: 'Tx.G',
                    hint: '+00010.00000',
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _txO,
                    label: 'Tx.O',
                    hint: '+00400.00000',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            if (!(_formKey.currentState?.validate() ?? false)) {
              return;
            }
            final bloc = context.read<GeneralUserSelfTestDebugBloc>();
            final draft = SelfTestSetSensorAllParametersDraft(
              sensorNo: _sensorNo.text,
              channelNo: _channelNo.text,
              fg: _fg.text,
              factoryOff: _factoryOff.text,
              senG: _senG.text,
              soff: _soff.text,
              resolution: _resolution.text,
              senMin: _senMin.text,
              sensMax: _sensMax.text,
              averagScheme: _averagScheme.text,
              vactor: _vactor.text,
              startTime: _startTime.text,
              interval: _interval.text,
              totalSample: _totalSample.text,
              mode: _mode.text,
              txG: _txG.text,
              txO: _txO.text,
            );
            Navigator.of(context).pop();
            _runAfterDialogRouteClosed(() {
              bloc.add(SubmitGeneralUserSetSensorAllParameters(draft));
            });
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}

class _SetSensorsParametersDialog extends StatefulWidget {
  const _SetSensorsParametersDialog({required this.prompt});

  final SelfTestSetSensorsParametersPrompt prompt;

  @override
  State<_SetSensorsParametersDialog> createState() =>
      _SetSensorsParametersDialogState();
}

class _SetSensorsParametersDialogState
    extends State<_SetSensorsParametersDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _sensorNo;
  late final TextEditingController _unit;
  late final TextEditingController _senSelStatus;
  late final TextEditingController _baudRate;
  late final TextEditingController _reqLen;
  late final TextEditingController _startChar;
  late final TextEditingController _fp;
  late final TextEditingController _lp;
  late final TextEditingController _respLen;
  late final TextEditingController _relayNo;
  late final TextEditingController _periodicSmpl;
  late final TextEditingController _derievedPara;
  late final TextEditingController _requestString;
  late final TextEditingController _sensorName;
  late final TextEditingController _id;
  late final TextEditingController _model;
  late final TextEditingController _rstcnt;
  late final TextEditingController _datum;
  late final TextEditingController _decLen;
  late final TextEditingController _fracLen;
  late final TextEditingController _maxThreshold;
  late final TextEditingController _minThreshold;

  @override
  void initState() {
    super.initState();
    final d = widget.prompt.initial;
    _sensorNo = TextEditingController(text: d.sensorNo);
    _unit = TextEditingController(text: d.unit);
    _senSelStatus = TextEditingController(text: d.senSelStatus);
    _baudRate = TextEditingController(text: d.baudRate);
    _reqLen = TextEditingController(text: d.reqLen);
    _startChar = TextEditingController(text: d.startChar);
    _fp = TextEditingController(text: d.fp);
    _lp = TextEditingController(text: d.lp);
    _respLen = TextEditingController(text: d.respLen);
    _relayNo = TextEditingController(text: d.relayNo);
    _periodicSmpl = TextEditingController(text: d.periodicSmpl);
    _derievedPara = TextEditingController(text: d.derievedPara);
    _requestString = TextEditingController(text: d.requestString);
    _sensorName = TextEditingController(text: d.sensorName);
    _id = TextEditingController(text: d.id);
    _model = TextEditingController(text: d.model);
    _rstcnt = TextEditingController(text: d.rstcnt);
    _datum = TextEditingController(text: d.datum);
    _decLen = TextEditingController(text: d.decLen);
    _fracLen = TextEditingController(text: d.fracLen);
    _maxThreshold = TextEditingController(text: d.maxThreshold);
    _minThreshold = TextEditingController(text: d.minThreshold);
  }

  @override
  void dispose() {
    _sensorNo.dispose();
    _unit.dispose();
    _senSelStatus.dispose();
    _baudRate.dispose();
    _reqLen.dispose();
    _startChar.dispose();
    _fp.dispose();
    _lp.dispose();
    _respLen.dispose();
    _relayNo.dispose();
    _periodicSmpl.dispose();
    _derievedPara.dispose();
    _requestString.dispose();
    _sensorName.dispose();
    _id.dispose();
    _model.dispose();
    _rstcnt.dispose();
    _datum.dispose();
    _decLen.dispose();
    _fracLen.dispose();
    _maxThreshold.dispose();
    _minThreshold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.72;
    return AlertDialog(
      title: Text(widget.prompt.testName),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480, maxHeight: maxH),
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter all parameters below. Command is sent as ?82,...,# '
                    '(RequestString 17 chars, Sensor name 16 chars, padded; BLE chunks).',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6A7178),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSelfTestSensorSetInputField(
                    controller: _sensorNo,
                    label: 'Sensor no',
                    hint: '00',
                    maxLength: 2,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _unit,
                    label: 'Unit',
                    hint: '02',
                    maxLength: 2,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _senSelStatus,
                    label: 'SenSelStatus',
                    hint: '0',
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _baudRate,
                    label: 'BaudRate',
                    hint: '5',
                    maxLength: 2,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _reqLen,
                    label: 'ReqLen',
                    hint: '11',
                    maxLength: 2,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _startChar,
                    label: 'Start Char',
                    hint: '<',
                    maxLength: 1,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _fp,
                    label: 'Fp',
                    hint: '09',
                    maxLength: 2,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _lp,
                    label: 'Lp',
                    hint: '13',
                    maxLength: 2,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _respLen,
                    label: 'Resp Len',
                    hint: '22',
                    maxLength: 2,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _relayNo,
                    label: 'RelayNo',
                    hint: '2',
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _periodicSmpl,
                    label: 'PeriodicSmpl',
                    hint: '0',
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _derievedPara,
                    label: 'DerievedPara',
                    hint: '0',
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _requestString,
                    label: 'RequestString',
                    hint: '12345678912345678',
                    maxLength: 17,
                    helper: '17 characters',
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _sensorName,
                    label: 'Sensor name',
                    hint: '1234567891234567',
                    maxLength: 16,
                    helper: '16 characters',
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _id,
                    label: 'id',
                    hint: '01',
                    maxLength: 2,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _model,
                    label: 'model',
                    hint: '20',
                    maxLength: 2,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _rstcnt,
                    label: 'rstcnt',
                    hint: '0',
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _datum,
                    label: 'datum',
                    hint: '0000',
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _decLen,
                    label: 'dec_len',
                    hint: '8',
                    maxLength: 2,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _fracLen,
                    label: 'frac_len',
                    hint: '6',
                    maxLength: 2,
                    keyboardType: TextInputType.number,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _maxThreshold,
                    label: 'max_threshold',
                    hint: '+00000.00000',
                    maxLength: 13,
                  ),
                  _buildSelfTestSensorSetInputField(
                    controller: _minThreshold,
                    label: 'min_threshold',
                    hint: '+00000.00000',
                    maxLength: 13,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            if (!(_formKey.currentState?.validate() ?? false)) {
              return;
            }
            final bloc = context.read<GeneralUserSelfTestDebugBloc>();
            final draft = SelfTestSetSensorsParametersDraft(
              sensorNo: _sensorNo.text,
              unit: _unit.text,
              senSelStatus: _senSelStatus.text,
              baudRate: _baudRate.text,
              reqLen: _reqLen.text,
              startChar: _startChar.text,
              fp: _fp.text,
              lp: _lp.text,
              respLen: _respLen.text,
              relayNo: _relayNo.text,
              periodicSmpl: _periodicSmpl.text,
              derievedPara: _derievedPara.text,
              requestString: _requestString.text,
              sensorName: _sensorName.text,
              id: _id.text,
              model: _model.text,
              rstcnt: _rstcnt.text,
              datum: _datum.text,
              decLen: _decLen.text,
              fracLen: _fracLen.text,
              maxThreshold: _maxThreshold.text,
              minThreshold: _minThreshold.text,
            );
            Navigator.of(context).pop();
            _runAfterDialogRouteClosed(() {
              bloc.add(SubmitGeneralUserSetSensorsParameters(draft));
            });
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}

const String _setIndividualSensorParameterParaHelp =
    'Sheet 1 (GET ?81): 1=F.G, 2=Factory off, 3=senG, 4=S.off, 5=Resolution, '
    '6=Sen Min, 7=Sens Max, 8=Averag Scheme, 9=Vactor, 10=Start time, '
    '11=Interval, 12=Total sample, 13=Mode, 14=Tx.G, 15=Tx.O. '
    'Sheet 2 (GET ?83): 1=Unit, 2=SenSelStatus, 3=BaudRate, … (23 fields).';

class _SetIndividualSensorParameterDialog extends StatefulWidget {
  const _SetIndividualSensorParameterDialog({required this.prompt});

  final SelfTestSetIndividualSensorParameterPrompt prompt;

  @override
  State<_SetIndividualSensorParameterDialog> createState() =>
      _SetIndividualSensorParameterDialogState();
}

class _SetIndividualSensorParameterDialogState
    extends State<_SetIndividualSensorParameterDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _sensorNo;
  late final TextEditingController _paraNo;
  late final TextEditingController _value;

  @override
  void initState() {
    super.initState();
    _sensorNo = TextEditingController(text: widget.prompt.initial.sensorNo);
    _paraNo = TextEditingController(text: widget.prompt.initial.paraNo);
    _value = TextEditingController(text: widget.prompt.initial.value);
  }

  @override
  void dispose() {
    _sensorNo.dispose();
    _paraNo.dispose();
    _value.dispose();
    super.dispose();
  }

  String? _validateSensorNo(String? raw) {
    final t = raw?.trim() ?? '';
    if (t.isEmpty) {
      return 'Sensor no is required.';
    }
    final v = int.tryParse(t);
    if (v == null || v < 0 || v > 99) {
      return 'Sensor no must be 00–99.';
    }
    return null;
  }

  String? _validateParaNo(String? raw) {
    final t = raw?.trim() ?? '';
    if (t.isEmpty) {
      return 'Para no is required.';
    }
    final v = int.tryParse(t);
    if (v == null || v < 0 || v > 34) {
      return 'Para no must be 00–34.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final catalogHelp = widget.prompt.catalogHelpText.trim();
    return AlertDialog(
      title: Text(widget.prompt.testName),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (catalogHelp.isNotEmpty && catalogHelp.toUpperCase() != 'NA')
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    catalogHelp,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF70757A),
                    ),
                  ),
                ),
              _buildSelfTestSensorSetInputField(
                controller: _sensorNo,
                label: 'Sensor no',
                hint: '01',
                helper: 'Two digits, 00–99',
                keyboardType: TextInputType.number,
                validator: _validateSensorNo,
              ),
              _buildSelfTestSensorSetInputField(
                controller: _paraNo,
                label: 'Para no',
                hint: '01',
                helper: '00–34. $_setIndividualSensorParameterParaHelp',
                keyboardType: TextInputType.number,
                validator: _validateParaNo,
              ),
              _buildSelfTestSensorSetInputField(
                controller: _value,
                label: 'Value',
                hint: '',
                helper:
                    'Sent exactly as entered (spaces, +, -). No comma allowed.',
                validator: _validateSelfTestIndividualSensorParameterValue,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            if (!(_formKey.currentState?.validate() ?? false)) {
              return;
            }
            final bloc = context.read<GeneralUserSelfTestDebugBloc>();
            final draft = SelfTestSetIndividualSensorParameterDraft(
              sensorNo: _sensorNo.text,
              paraNo: _paraNo.text,
              value: _value.text,
            );
            Navigator.of(context).pop();
            _runAfterDialogRouteClosed(() {
              bloc.add(SubmitGeneralUserSetIndividualSensorParameter(draft));
            });
          },
          child: const Text('Send'),
        ),
      ],
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
