import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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

Future<Uint8List> buildDynamicPdf({
  required List<String> columnOrder,
  required List<Map<String, String>> rows,
  String? title,
}) async {
  final tableData = <List<String>>[
    for (final row in rows)
      columnOrder.map((k) => row[k] ?? '').toList(growable: false),
  ];

  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(28),
      build: (context) => [
        if (title != null && title.trim().isNotEmpty) ...[
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
        ],
        pw.TableHelper.fromTextArray(
          headers: columnOrder,
          data: tableData,
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 8,
          ),
          cellStyle: const pw.TextStyle(fontSize: 7),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          cellHeight: 16,
          cellAlignments: {
            for (var i = 0; i < columnOrder.length; i++)
              i: pw.Alignment.centerLeft,
          },
        ),
      ],
    ),
  );

  return Uint8List.fromList(await doc.save());
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
