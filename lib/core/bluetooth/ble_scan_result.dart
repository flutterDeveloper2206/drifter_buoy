/// Discovered peripheral from a BLE scan (no plugin types).
class BleScanResult {
  const BleScanResult({
    required this.remoteId,
    required this.displayName,
    required this.rssi,
  });

  final String remoteId;
  final String displayName;
  final int rssi;
}
