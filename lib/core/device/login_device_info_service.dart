import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

import 'package:drifter_buoy/core/device/login_device_info.dart';

class LoginDeviceInfoService {
  LoginDeviceInfoService({DeviceInfoPlugin? deviceInfoPlugin})
      : _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfoPlugin;

  Future<LoginDeviceInfo> getLoginDeviceInfo() async {
    final ip = await _bestEffortLocalIp();
    final location = _bestEffortLocation();

    if (Platform.isAndroid) {
      final info = await _deviceInfoPlugin.androidInfo;
      return LoginDeviceInfo(
        deviceName: info.device,
        deviceType: info.brand,
        osName: 'Android',
        osVersion: info.version.release,
        browserName: 'Flutter',
        ipAddress: ip,
        location: location,
      );
    }

    if (Platform.isIOS) {
      final info = await _deviceInfoPlugin.iosInfo;
      return LoginDeviceInfo(
        deviceName: info.name,
        deviceType: 'iOS',
        osName: 'iOS',
        osVersion: info.systemVersion,
        browserName: 'Flutter',
        ipAddress: ip,
        location: location,
      );
    }

    return LoginDeviceInfo(
      deviceName: Platform.localHostname,
      deviceType: Platform.operatingSystem,
      osName: Platform.operatingSystem,
      osVersion: Platform.version,
      browserName: 'Flutter',
      ipAddress: ip,
      location: location,
    );
  }

  Future<String> _bestEffortLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback) {
            return addr.address;
          }
        }
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  String _bestEffortLocation() {
    try {
      // Fallback "location" field without adding geolocation permissions.
      return DateTime.now().timeZoneName;
    } catch (_) {
      return '';
    }
  }
}

