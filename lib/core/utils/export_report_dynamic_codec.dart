import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Stable column order: union of keys, sorted alphabetically.
List<String> deriveReportColumnOrder(List<Map<String, String>> rows) {
  final keys = <String>{};
  for (final row in rows) {
    keys.addAll(row.keys);
  }
  final list = keys.toList()..sort();
  return list;
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
  required String title,
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
        pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headers: columnOrder,
          data: tableData,
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
          cellStyle: const pw.TextStyle(fontSize: 7),
          headerDecoration: const pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
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
  required String fromDate,
  required String toDate,
  required bool csv,
}) {
  final safeId = buoyId.replaceAll(RegExp(r'[^\w\-]+'), '_');
  final ext = csv ? 'csv' : 'pdf';
  return 'buoy_${safeId}_$fromDate-$toDate.$ext'
      .replaceAll(' ', '_');
}
