/// Shapes buoy ids for UserViewBuoyDashboard / report multipart fields.
///
/// - Strips a leading `DB-` / `DB` prefix (case-insensitive).
/// - Zero-pads a single numeric digit so JSON `1` / `"1"` becomes `01` when
///   the backend expects two-character ids.
String normalizeBuoyIdForGeneralUserApi(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }
  final compact = trimmed.toUpperCase().replaceAll(' ', '');
  String tail;
  if (compact.startsWith('DB-')) {
    tail = compact.substring(3).trim();
  } else if (compact.startsWith('DB') && compact.length > 2) {
    tail = compact.substring(2).trim();
  } else {
    tail = trimmed;
  }
  if (tail.length == 1 && RegExp(r'^\d$').hasMatch(tail)) {
    return '0$tail';
  }
  return tail;
}
