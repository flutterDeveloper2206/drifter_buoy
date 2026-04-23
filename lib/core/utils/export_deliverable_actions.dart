import 'dart:io';

import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Saves or shares export bytes with platform quirks handled (iOS iPad share
/// anchor, temp file for [FlutterFileDialog], Android visibility).
class ExportDeliverableActions {
  ExportDeliverableActions._();

  static String sanitizeExportFileName(String name) {
    var s = name.trim();
    if (s.isEmpty) {
      s = 'export';
    }
    return s.replaceAll(RegExp(r'[<>:"/\\|?*\u0000-\u001f]'), '_');
  }

  static String _mimeForFileName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return 'application/pdf';
    }
    return 'text/csv';
  }

  /// Required on iPad for share sheet; safe fallback avoids engine assertions.
  static Rect sharePositionOrigin(BuildContext context) {
    try {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        return box.localToGlobal(Offset.zero) & box.size;
      }
    } catch (_) {}
    final size = MediaQuery.sizeOf(context);
    final center = Offset(size.width / 2, size.height / 2);
    return Rect.fromCenter(center: center, width: 1, height: 1);
  }

  static Future<File> _materializeTempFile({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final dir = await getTemporaryDirectory();
    final safe = sanitizeExportFileName(fileName);
    final f = File(
      '${dir.path}/export_${DateTime.now().millisecondsSinceEpoch}_$safe',
    );
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }

  /// Opens the system share sheet. Keeps temp file until OS cleans temp dir.
  static Future<void> share({
    required BuildContext context,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final origin = sharePositionOrigin(context);
    final temp = await _materializeTempFile(bytes: bytes, fileName: fileName);
    final mime = _mimeForFileName(fileName);
    final safeName = sanitizeExportFileName(fileName);
    try {
      await Share.shareXFiles(
        [
          XFile(
            temp.path,
            mimeType: mime,
            name: safeName,
          ),
        ],
        subject: safeName,
        sharePositionOrigin: origin,
      );
    } catch (e, st) {
      AppLogger.e('Export share failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Returns saved path when successful, `null` when user cancels.
  static Future<String?> saveToDevice({
    required Uint8List bytes,
    required String fileName,
  }) async {
    File? temp;
    try {
      temp = await _materializeTempFile(bytes: bytes, fileName: fileName);
      final mime = _mimeForFileName(fileName);
      final safeName = sanitizeExportFileName(fileName);

      String? path;
      try {
        path = await FlutterFileDialog.saveFile(
          params: SaveFileDialogParams(
            sourceFilePath: temp.path,
            fileName: safeName,
            mimeTypesFilter: [mime],
          ),
        );
      } catch (e1, st1) {
        AppLogger.w(
          'saveFile with mimeTypesFilter failed, retrying without filter',
          error: e1,
          stackTrace: st1,
        );
        path = await FlutterFileDialog.saveFile(
          params: SaveFileDialogParams(
            sourceFilePath: temp.path,
            fileName: safeName,
          ),
        );
      }

      if (path == null || path.isEmpty) {
        return null;
      }
      return path;
    } catch (e, st) {
      AppLogger.e('Export save failed', error: e, stackTrace: st);
      rethrow;
    } finally {
      if (temp != null) {
        try {
          await temp.delete();
        } catch (_) {}
      }
    }
  }

  /// Tries opening a saved export file in the platform app.
  /// Returns `true` if opened, `false` when unavailable/fails gracefully.
  static Future<bool> openSavedFile(String savedPath) async {
    try {
      final result = await OpenFilex.open(savedPath);
      if (result.type == ResultType.done) {
        return true;
      }
      AppLogger.w(
        'Open saved file failed: ${result.type.name} ${result.message}',
      );
      return false;
    } on MissingPluginException catch (e, st) {
      AppLogger.w(
        'open_filex plugin not available at runtime',
        error: e,
        stackTrace: st,
      );
      return false;
    } on PlatformException catch (e, st) {
      AppLogger.w('open_filex platform exception', error: e, stackTrace: st);
      return false;
    } catch (e, st) {
      AppLogger.w('open_filex unexpected error', error: e, stackTrace: st);
      return false;
    }
  }

  static String userFacingMessage(Object error) {
    if (error is PlatformException) {
      final c = error.code.toLowerCase();
      if (c.contains('cancel')) {
        return 'Export cancelled.';
      }
      final m = error.message;
      if (m != null && m.isNotEmpty) {
        return m;
      }
    }
    return 'Could not save the file. Try Share, or check Files / storage access.';
  }
}
