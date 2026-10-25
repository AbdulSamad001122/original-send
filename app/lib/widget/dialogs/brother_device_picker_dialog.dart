import 'package:flutter/material.dart';
import 'package:localsend_app/util/device_type_ext.dart';
import 'package:localsend_isolates/model/device.dart';
import 'package:routerino/routerino.dart';

/// Modal dialog prompting the sender to select which device of a brother to send to
/// when that brother has multiple active devices online (e.g. PC and Phone).
class BrotherDevicePickerDialog extends StatelessWidget {
  final String brotherName;
  final List<Device> devices;

  const BrotherDevicePickerDialog({
    required this.brotherName,
    required this.devices,
    super.key,
  });

  static Future<List<Device>?> open({
    required BuildContext context,
    required String brotherName,
    required List<Device> devices,
  }) {
    return showDialog<List<Device>>(
      context: context,
      barrierDismissible: true,
      builder: (_) => BrotherDevicePickerDialog(
        brotherName: brotherName,
        devices: devices,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.devices_rounded, size: 36, color: colorScheme.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Send to $brotherName',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Multiple devices are online for $brotherName.\nChoose which device to receive:',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            ...devices.map((device) {
              final deviceName = device.deviceModel ?? device.deviceType.humanName;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context.pop([device]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(device.deviceType.icon, size: 22, color: colorScheme.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deviceName,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${device.deviceType.humanName} • ${device.ip ?? 'Wi-Fi'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colorScheme.primary),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (devices.length > 1) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context.pop(devices),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colorScheme.primary.withValues(alpha: 0.4)),
                      color: colorScheme.primary.withValues(alpha: 0.08),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.all_inclusive_rounded, size: 22, color: colorScheme.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'All Devices',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Send to both PC and Mobile simultaneously',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.done_all_rounded, size: 18, color: colorScheme.primary),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => context.pop(null),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
