import 'package:flutter/material.dart';
import 'package:localsend_app/model/brother_config.dart';
import 'package:localsend_app/provider/persistence_provider.dart';
import 'package:localsend_app/provider/settings_provider.dart';
import 'package:localsend_isolates/model/device.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

/// A 2-step onboarding dialog that asks "Who are you?" and "What device is this?".
class BrotherIdentityDialog extends StatefulWidget {
  final bool isInitialSetup;

  const BrotherIdentityDialog({this.isInitialSetup = true, super.key});

  @override
  State<BrotherIdentityDialog> createState() => _BrotherIdentityDialogState();
}

class _BrotherIdentityDialogState extends State<BrotherIdentityDialog> {
  int _currentStep = 0; // 0 = Brother name, 1 = Device type
  String? _selectedBrother;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: !widget.isInitialSetup,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _currentStep == 0 ? _buildStep1(context, colorScheme) : _buildStep2(context, colorScheme),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(BuildContext context, ColorScheme colorScheme) {
    return Column(
      key: const ValueKey(1),
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
            child: Icon(Icons.people_alt_rounded, size: 40, color: colorScheme.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Who are you?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Select your identity to connect seamlessly with your brothers',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
        ),
        const SizedBox(height: 20),
        ...BrotherConfig.brotherNames.map((name) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() {
                  _selectedBrother = name;
                  _currentStep = 1;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                      child: Text(
                        name.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join(),
                        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: colorScheme.primary),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep2(BuildContext context, ColorScheme colorScheme) {
    return Column(
      key: const ValueKey(2),
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
            child: Icon(Icons.devices_rounded, size: 40, color: colorScheme.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'What device is this?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose the role for $_selectedBrother\'s device',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
        ),
        const SizedBox(height: 20),
        _buildDeviceCard(
          context: context,
          colorScheme: colorScheme,
          icon: Icons.laptop_mac_rounded,
          title: 'PC / Laptop',
          subtitle: 'Desktop computer or laptop',
          onTap: () => _finishSetup(context, DeviceType.desktop, 'PC / Laptop'),
        ),
        const SizedBox(height: 10),
        _buildDeviceCard(
          context: context,
          colorScheme: colorScheme,
          icon: Icons.phone_android_rounded,
          title: 'Phone / Mobile',
          subtitle: 'Smartphone or tablet',
          onTap: () => _finishSetup(context, DeviceType.mobile, 'Phone / Mobile'),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _currentStep = 0;
                });
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back to brothers'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeviceCard({
    required BuildContext context,
    required ColorScheme colorScheme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
              child: Icon(icon, size: 24, color: colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.check_circle_outline_rounded, size: 20, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Future<void> _finishSetup(BuildContext context, DeviceType deviceType, String deviceModel) async {
    final ref = context.ref;
    final brother = _selectedBrother!;

    await ref.notifier(settingsProvider).setAlias(brother);
    await ref.notifier(settingsProvider).setDeviceType(deviceType);
    await ref.notifier(settingsProvider).setDeviceModel(deviceModel);
    await ref.read(persistenceProvider).setBrotherIdentitySelected(true);

    if (context.mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Identity saved: $brother ($deviceModel)'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
