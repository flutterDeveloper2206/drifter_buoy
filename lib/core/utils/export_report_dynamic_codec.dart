import 'dart:convert';
import 'dart:math' show min;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute, debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' show PdfBaseCache;

import 'package:drifter_buoy/core/constants/app_constants.dart';

/// Leading / trailing brand graphics for PDF header (declared under `flutter.assets`).
const String _kPdfLeadingLogoAsset = 'assets/icons/ic_logo.png';
const String _kPdfTrailingLogoAsset = 'assets/icons/azista_logo.png';

/// Bundled Unicode fonts (same files as `printing`’s Google Fonts URLs).
const String _kBundledNotoSansRegular = 'assets/google_fonts/NotoSans-Regular.ttf';
const String _kBundledNotoSansBold = 'assets/google_fonts/NotoSans-Bold.ttf';

/// Safety cap for the `pdf` package's `MultiPage` widget. The library defaults
/// to 20 pages and throws `TooManyPagesException` if exceeded. A very large
/// cap lets us export long reports without hitting that limit while still
/// providing a guardrail against runaway documents.
const int _kPdfMaxPages = 100000;

/// Split large tables into several `TableHelper` widgets so layout stays
/// bounded on mobile (one giant table often fails or OOMs).
const int kExportPdfTableRowChunkSize = 200;

/// PDF includes at most this many data rows; CSV is always full length.
/// Truncated PDFs show an on-document notice pointing users to CSV.
const int kExportPdfMaxDataRows = 10000;

/// Above this row count, the export screen may show an informational message
/// when the user starts a PDF export.
const int kExportPdfLargeRowWarningThreshold = 2000;

/// Unicode-capable fonts used for the report PDF when bundled assets are
/// missing or network fallback is needed.
const String _kNotoSansRegularUrl =
    'https://fonts.gstatic.com/s/notosans/v36/o-0mIpQlx3QUlC5A4PNB6Ryti20_6n1iPHjcz6L1SoM-jCpoiyD9A99d41P6zHtY.ttf';
const String _kNotoSansBoldUrl =
    'https://fonts.gstatic.com/s/notosans/v36/o-0mIpQlx3QUlC5A4PNB6Ryti20_6n1iPHjcz6L1SoM-jCpoiyAaBN9d41P6zHtY.ttf';

/// Stable column order: preserve API response key order.
///
/// We keep key order exactly as it appears in rows from the API:
/// - start with first row keys in order
/// - append unseen keys from later rows in encountered order
List<String> deriveReportColumnOrder(List<Map<String, String>> rows) {
  final keys = <String>[];
  final seen = <String>{};
  for (final row in rows) {
    for (final key in row.keys) {
      if (seen.add(key)) {
        keys.add(key);
      }
    }
  }
  return keys;
}

String buildDynamicCsv({
  required List<String> columnOrder,
  required List<Map<String, String>> rows,
}) {
  final buf = StringBuffer();
  void writeRow(List<String> cells) {
    buf.writeln(cells.map(_escapeCsvCell).join(','));
  }

  writeRow(columnOrder);
  for (final row in rows) {
    writeRow(columnOrder.map((k) => row[k] ?? '').toList());
  }
  return buf.toString();
}

String _escapeCsvCell(String raw) {
  if (raw.contains(',') || raw.contains('"') || raw.contains('\n')) {
    return '"${raw.replaceAll('"', '""')}"';
  }
  return raw;
}

/// Builds a multi-page PDF report.
///
/// Assets are loaded on the main isolate (required by [rootBundle]); the
/// actual document layout + serialization is offloaded to a background
/// isolate via [compute] so the UI stays responsive even for very large
/// reports.
Future<Uint8List> buildDynamicPdf({
  required List<String> columnOrder,
  required List<Map<String, String>> rows,
  String? title,
}) async {
  final generatedAt = DateTime.now();
  final generatedStamp =
      '${generatedAt.day.toString().padLeft(2, '0')}-'
      '${generatedAt.month.toString().padLeft(2, '0')}-'
      '${generatedAt.year} '
      '${generatedAt.hour.toString().padLeft(2, '0')}:'
      '${generatedAt.minute.toString().padLeft(2, '0')}';
  final reportTitle = (title == null || title.trim().isEmpty)
      ? '${AppConstants.appName} Report'
      : title.trim();
  final leadingLogoBytes = (await rootBundle.load(
    _kPdfLeadingLogoAsset,
  )).buffer.asUint8List();
  final trailingLogoBytes = (await rootBundle.load(
    _kPdfTrailingLogoAsset,
  )).buffer.asUint8List();

  final regularFontBytes = await _resolveUnicodeFontBytes(
    name: 'NotoSans-Regular',
    bundledAsset: _kBundledNotoSansRegular,
    url: _kNotoSansRegularUrl,
  );
  final boldFontBytes = await _resolveUnicodeFontBytes(
    name: 'NotoSans-Bold',
    bundledAsset: _kBundledNotoSansBold,
    url: _kNotoSansBoldUrl,
  );

  final totalSourceRows = rows.length;
  List<Map<String, String>> rowsForPdf = rows;
  String? pdfTruncationNote;
  if (rows.length > kExportPdfMaxDataRows) {
    rowsForPdf = rows.sublist(0, kExportPdfMaxDataRows);
    pdfTruncationNote =
        'Showing rows 1–$kExportPdfMaxDataRows of $totalSourceRows. '
        'Export as CSV for the complete dataset.';
  }

  final payload = _PdfBuildPayload(
    columnOrder: List<String>.from(columnOrder),
    rows: rowsForPdf
        .map((r) => Map<String, String>.from(r))
        .toList(growable: false),
    reportTitle: reportTitle,
    generatedStamp: generatedStamp,
    leadingLogoBytes: leadingLogoBytes,
    trailingLogoBytes: trailingLogoBytes,
    regularFontBytes: regularFontBytes,
    boldFontBytes: boldFontBytes,
    pdfTruncationNote: pdfTruncationNote,
  );

  return compute(_renderDynamicPdf, payload);
}

/// Prefer bundled TTF, then network via [PdfBaseCache].
Future<Uint8List?> _resolveUnicodeFontBytes({
  required String name,
  required String bundledAsset,
  required String url,
}) async {
  try {
    final data = await rootBundle.load(bundledAsset);
    return data.buffer.asUint8List();
  } catch (e) {
    debugPrint(
      'PDF export: bundled font not loaded ($bundledAsset): $e. Trying network.',
    );
  }
  try {
    return await PdfBaseCache.defaultCache.resolve(
      name: name,
      uri: Uri.parse(url),
    );
  } catch (error) {
    debugPrint(
      'PDF export: failed to load Unicode font "$name": $error. '
      'Falling back to Helvetica (ASCII only).',
    );
    return null;
  }
}

class _PdfBuildPayload {
  const _PdfBuildPayload({
    required this.columnOrder,
    required this.rows,
    required this.reportTitle,
    required this.generatedStamp,
    required this.leadingLogoBytes,
    required this.trailingLogoBytes,
    required this.regularFontBytes,
    required this.boldFontBytes,
    this.pdfTruncationNote,
  });

  final List<String> columnOrder;
  final List<Map<String, String>> rows;
  final String reportTitle;
  final String generatedStamp;
  final Uint8List leadingLogoBytes;
  final Uint8List trailingLogoBytes;
  final Uint8List? regularFontBytes;
  final Uint8List? boldFontBytes;
  final String? pdfTruncationNote;
}

Future<Uint8List> _renderDynamicPdf(_PdfBuildPayload p) async {
  final leadingLogoImage = pw.MemoryImage(p.leadingLogoBytes);
  final trailingLogoImage = pw.MemoryImage(p.trailingLogoBytes);

  pw.Font? baseFont;
  pw.Font? boldFont;
  if (p.regularFontBytes != null) {
    final b = p.regularFontBytes!;
    baseFont = pw.Font.ttf(
      ByteData.view(b.buffer, b.offsetInBytes, b.lengthInBytes),
    );
  }
  if (p.boldFontBytes != null) {
    final b = p.boldFontBytes!;
    boldFont = pw.Font.ttf(
      ByteData.view(b.buffer, b.offsetInBytes, b.lengthInBytes),
    );
  }
  boldFont ??= baseFont;

  final theme = baseFont == null
      ? null
      : pw.ThemeData.withFont(base: baseFont, bold: boldFont);

  final tableData = <List<String>>[
    for (final row in p.rows)
      p.columnOrder.map((k) => row[k] ?? '').toList(growable: false),
  ];

  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      maxPages: _kPdfMaxPages,
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.fromLTRB(28, 52, 28, 56),
      theme: theme,
      header: (pw.Context context) => pw.Container(
        width: double.infinity,
        decoration: pw.BoxDecoration(
          color: PdfColors.grey50,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          border: pw.Border.all(
            color: PdfColor.fromInt(0xFFCBD5E1),
            width: 1,
          ),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Container(
              height: 5,
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF1A2F4A),
                borderRadius: const pw.BorderRadius.only(
                  topLeft: pw.Radius.circular(3),
                  topRight: pw.Radius.circular(3),
                ),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                    color: PdfColor.fromInt(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Image(
                    leadingLogoImage,
                    width: 44,
                    height: 44,
                    fit: pw.BoxFit.contain,
                  ),
                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                      child: pw.Text(
                        p.reportTitle,
                        textAlign: pw.TextAlign.center,
                        maxLines: 1,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF1A2F4A),
                        ),
                      ),
                    ),
                  ),
                  pw.Image(
                    trailingLogoImage,
                    width: 88,
                    height: 40,
                    fit: pw.BoxFit.contain,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      footer: (pw.Context context) => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.only(top: 8),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            top: pw.BorderSide(color: PdfColors.grey400, width: 0.8),
          ),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated by Azista ${p.generatedStamp}',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.black),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.black),
            ),
          ],
        ),
      ),
      build: (context) => _pdfTableWidgets(p, tableData),
    ),
  );

  return Uint8List.fromList(await doc.save());
}

List<pw.Widget> _pdfTableWidgets(
  _PdfBuildPayload p,
  List<List<String>> tableData,
) {
  final widgets = <pw.Widget>[];
  final note = p.pdfTruncationNote;
  if (note != null && note.isNotEmpty) {
    widgets.add(
      pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 10),
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColors.amber50,
          border: pw.Border.all(color: PdfColors.amber700, width: 0.9),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        width: double.infinity,
        child: pw.Text(
          note,
          style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.black),
        ),
      ),
    );
  }

  pw.Widget tableForSlice(List<List<String>> slice) => pw.TableHelper.fromTextArray(
    headers: p.columnOrder,
    data: slice,
    headerStyle: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 8,
    ),
    cellStyle: const pw.TextStyle(fontSize: 7),
    headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
    cellHeight: 16,
    cellAlignments: {
      for (var i = 0; i < p.columnOrder.length; i++)
        i: pw.Alignment.centerLeft,
    },
  );

  if (tableData.isEmpty) {
    widgets.add(tableForSlice(const []));
    return widgets;
  }

  const chunk = kExportPdfTableRowChunkSize;
  for (var start = 0; start < tableData.length; start += chunk) {
    if (start > 0) {
      widgets.add(pw.SizedBox(height: 12));
    }
    final end = min(start + chunk, tableData.length);
    widgets.add(tableForSlice(tableData.sublist(start, end)));
  }
  return widgets;
}

Uint8List encodeCsvToUtf8Bytes(String csv) {
  return Uint8List.fromList(utf8.encode(csv));
}

String exportReportFileName({
  required String buoyId,
  required String reportType,
  required String fromDate,
  required String toDate,
  required bool csv,
}) {
  final safeId = buoyId.replaceAll(RegExp(r'[^\w\-]+'), '_');
  final safeType = reportType.replaceAll(RegExp(r'[^\w\-]+'), '');
  final from = _formatFileDateFromApiDate(fromDate);
  final to = _formatFileDateFromApiDate(toDate);
  final ext = csv ? 'csv' : 'pdf';
  return '${safeId}_${safeType}_${from}_$to.$ext';
}

String exportMultiBuoyDataReportFileName({
  required String buoyId,
  required String reportType,
  required String fromDate,
  required String toDate,
  required bool csv,
}) {
  final safeId = buoyId.replaceAll(RegExp(r'[^\w\-]+'), '_');
  final safeType = reportType.replaceAll(RegExp(r'[^\w\-]+'), '');
  final from = _formatFileDateFromApiDate(fromDate);
  final to = _formatFileDateFromApiDate(toDate);
  final ext = csv ? 'csv' : 'pdf';
  return '${safeId}_${safeType}_${from}_$to.$ext';
}

String _formatFileDateFromApiDate(String apiDate) {
  // Input from APIs/events is usually DD-Mon-YYYY.
  final s = apiDate.trim();
  final parts = s.split('-');
  if (parts.length != 3) {
    return s.replaceAll('/', '-');
  }
  final day = parts[0].padLeft(2, '0');
  final monRaw = parts[1].toLowerCase();
  final year = parts[2];
  const monthMap = <String, String>{
    'jan': '01',
    'feb': '02',
    'mar': '03',
    'apr': '04',
    'may': '05',
    'jun': '06',
    'jul': '07',
    'aug': '08',
    'sep': '09',
    'oct': '10',
    'nov': '11',
    'dec': '12',
  };
  final month = monthMap[monRaw] ?? monRaw.padLeft(2, '0');
  return '$day-$month-$year';
}
