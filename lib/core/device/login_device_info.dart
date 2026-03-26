class LoginDeviceInfo {
  final String deviceName;
  final String deviceType;
  final String osName;
  final String osVersion;
  final String browserName;
  final String ipAddress;
  final String location;

  const LoginDeviceInfo({
    required this.deviceName,
    required this.deviceType,
    required this.osName,
    required this.osVersion,
    required this.browserName,
    required this.ipAddress,
    required this.location,
  });
}

