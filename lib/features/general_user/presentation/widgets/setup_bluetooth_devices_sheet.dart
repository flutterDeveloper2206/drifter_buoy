import 'package:flutter/material.dart';

/// Nearby devices shown in the setup flow (prototype — replace with real scan).
const List<({String name, String bluetoothId, bool showLinkIcon})>
    kSetupBluetoothNearbyDevices = [
  (name: 'Buoy 02', bluetoothId: 'DB021_BT', showLinkIcon: true),
  (name: 'Device 02', bluetoothId: 'DB_02_XX', showLinkIcon: false),
  (name: 'iPhone 15', bluetoothId: 'iPhone_15_BT', showLinkIcon: false),
];

/// Returns `(displayName, bluetoothId)` when the user picks a row, or `null` if dismissed.
Future<(String, String)?> showSetupBluetoothDeviceSheet(BuildContext context) {
  return showModalBottomSheet<(String, String)>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x99000000),
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.55,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              Text(
                'Bluetooth',
                style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF1D2329),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Nearby Bluetooth Devices',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF70757A),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                  itemCount: kSetupBluetoothNearbyDevices.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE8EBED),
                  ),
                  itemBuilder: (context, index) {
                    final d = kSetupBluetoothNearbyDevices[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      title: Text(
                        d.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: const Color(0xFF2A2F34),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      trailing: d.showLinkIcon
                          ? const Icon(
                              Icons.link_rounded,
                              color: Color(0xFF206BBE),
                              size: 22,
                            )
                          : null,
                      onTap: () => Navigator.of(context).pop(
                        (d.name, d.bluetoothId),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
