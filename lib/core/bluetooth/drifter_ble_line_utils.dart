/// Returns the line body before the protocol terminator.
/// Uses only the **last** `#` so embedded `#` in field values is preserved.
String stripDrifterLineTerminator(String line) {
  final t = line.trim();
  final last = t.lastIndexOf('#');
  if (last < 0) {
    return t;
  }
  return t.substring(0, last);
}

/// True when [buffer] contains at least one `#` (may still be mid-chunk).
bool drifterBufferHasCompleteLine(String buffer) => buffer.contains('#');

/// True when [buffer] ends with the protocol terminator `#` (all chunks received).
bool drifterBufferLooksComplete(String buffer) {
  final t = buffer.trimRight();
  return t.isNotEmpty && t.endsWith('#');
}

/// Whether an idle-buffered line is safe to finalize (avoids completing mid-field
/// when a BLE chunk boundary falls on `#` inside a password/value).
bool drifterRxLineReadyToComplete(String buffer) {
  if (!drifterBufferLooksComplete(buffer)) {
    return false;
  }
  final trimmed = buffer.trimRight();
  final hashCount = '#'.allMatches(trimmed).length;
  if (hashCount > 1) {
    return true;
  }
  if (RegExp(r',[01],#$').hasMatch(trimmed)) {
    return true;
  }
  if (trimmed.contains('list of') || trimmed.length < 60) {
    return true;
  }
  // Single `#` at end but likely mid-value (e.g. chunk ended at `sgdgdg@#`).
  if (RegExp(r'@[^,]*#$').hasMatch(trimmed)) {
    return false;
  }
  return true;
}

/// Index of the protocol terminator in [buffer] (last `#`).
int drifterTerminatorIndex(String buffer) => buffer.lastIndexOf('#');
