import 'dart:io';

import 'package:collection/collection.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:localsend_app/model/brother_config.dart';
import 'package:localsend_app/model/cross_file.dart';
import 'package:localsend_app/model/persistence/favorite_device.dart';
import 'package:localsend_app/pages/progress_page.dart';
import 'package:localsend_app/pages/send_page.dart';
import 'package:localsend_app/pages/tabs/send_tab_vm.dart';
import 'package:localsend_app/provider/network/nearby_devices_provider.dart';
import 'package:localsend_app/provider/network/send_provider.dart';
import 'package:localsend_app/provider/selection/selected_sending_files_provider.dart';
import 'package:localsend_app/provider/settings_provider.dart';
import 'package:localsend_app/util/brother_send_helper.dart';
import 'package:localsend_app/util/native/cross_file_converters.dart';
import 'package:localsend_app/util/native/file_picker.dart';
import 'package:localsend_app/widget/dialogs/brother_identity_dialog.dart';
import 'package:localsend_app/widget/dialogs/live_text_dialog.dart';
import 'package:localsend_app/widget/file_thumbnail.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';
import 'package:localsend_isolates/model/device.dart';
import 'package:localsend_isolates/model/file_type.dart';
import 'package:localsend_isolates/model/session_status.dart';
import 'package:localsend_isolates/util/file_size_helper.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

class SendTab extends StatefulWidget {
  const SendTab({super.key});

  @override
  State<SendTab> createState() => _SendTabState();
}

class _SendTabState extends State<SendTab> {
  final Set<String> _selectedBrothers = {};
  bool _isDragging = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Default select all peer brothers once initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDefaultSelection();
    });
  }

  void _initDefaultSelection() {
    final currentAlias = context.ref.read(settingsProvider).alias;
    final peerBrothers = BrotherConfig.brotherNames.where((name) => !currentAlias.toLowerCase().contains(name.toLowerCase())).toList();

    if (_selectedBrothers.isEmpty && peerBrothers.isNotEmpty) {
      setState(() {
        _selectedBrothers.addAll(peerBrothers);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ref = context.ref;

    final selectedFiles = ref.watch(selectedSendingFilesProvider);
    final currentAlias = ref.watch(settingsProvider.select((s) => s.alias));
    final nearbyDevices = ref.watch(nearbyDevicesProvider).allDevices.values;
    final activeSessions = ref.watch(sendProvider);

    final peerBrothers = BrotherConfig.brotherNames.where((name) => !currentAlias.toLowerCase().contains(name.toLowerCase())).toList();

    return ViewModelBuilder(
      provider: (ref) => sendTabVmProvider,
      init: (context) async => context.global.dispatchAsync(SendTabInitAction(context)),
      builder: (context, vm) {
        return ResponsiveListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            _buildIdentityHeader(context, currentAlias, colorScheme),
            const SizedBox(height: 16),
            _buildUploadCard(context, colorScheme, selectedFiles),
            if (selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSelectedFilesSection(context, colorScheme, selectedFiles),
            ],
            const SizedBox(height: 24),
            _buildBrothersSelectionSection(context, colorScheme, peerBrothers, nearbyDevices),
            const SizedBox(height: 20),
            _buildSendActionButton(context, colorScheme, selectedFiles, peerBrothers, nearbyDevices),
            if (activeSessions.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildActiveSessionsSection(context, colorScheme, activeSessions),
            ],
            const SizedBox(height: 30),
          ],
        );
      },
    );
  }

  Widget _buildIdentityHeader(BuildContext context, String currentAlias, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
            child: Icon(Icons.person_rounded, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Connected as',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.3),
                ),
                Text(
                  currentAlias.isNotEmpty ? currentAlias : 'Brother',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Change Identity / Device',
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (_) => const BrotherIdentityDialog(isInitialSetup: false),
              );
              _initDefaultSelection();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard(BuildContext context, ColorScheme colorScheme, List<CrossFile> selectedFiles) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: DropTarget(
        onDragEntered: (_) => setState(() => _isDragging = true),
        onDragExited: (_) => setState(() => _isDragging = false),
        onDragDone: (event) async {
          setState(() => _isDragging = false);
          final droppedDirectories = event.files.where((file) => Directory(file.path).existsSync()).toList();
          final droppedFiles = event.files.where((file) => !Directory(file.path).existsSync()).toList();

          for (final dir in droppedDirectories) {
            await context.ref.redux(selectedSendingFilesProvider).dispatchAsync(AddDirectoryAction(dir.path));
          }

          if (droppedFiles.isNotEmpty) {
            await context.ref
                .redux(selectedSendingFilesProvider)
                .dispatchAsync(
                  AddFilesAction(files: droppedFiles, converter: CrossFileConverters.convertXFile),
                );
          }
        },
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: _isDragging ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.4),
            borderRadius: 20,
            strokeWidth: _isDragging ? 2.5 : 1.5,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            decoration: BoxDecoration(
              color: _isDragging ? colorScheme.primary.withValues(alpha: 0.08) : colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.cloud_upload_outlined, size: 48, color: colorScheme.primary),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Choose a file or drag & drop it here',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Images, documents, folders, videos, or live text',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        await context.ref.global.dispatchAsync(
                          PickFileAction(option: FilePickerOption.file, context: context),
                        );
                      },
                      icon: const Icon(Icons.file_open_rounded, size: 20),
                      label: const Text('Browse File', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        await context.ref.global.dispatchAsync(
                          PickFileAction(option: FilePickerOption.folder, context: context),
                        );
                      },
                      icon: const Icon(Icons.folder_open_rounded, size: 20),
                      label: const Text('Folder', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (_) => const LiveTextDialog(),
                        );
                      },
                      icon: const Icon(Icons.edit_note_rounded, size: 20),
                      label: const Text('Live Text', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFilesSection(BuildContext context, ColorScheme colorScheme, List<CrossFile> selectedFiles) {
    final totalBytes = selectedFiles.fold<int>(0, (prev, curr) => prev + curr.size);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Selected Items (${selectedFiles.length})',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  '• ${totalBytes.asReadableFileSize}',
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    context.ref.redux(selectedSendingFilesProvider).dispatch(ClearSelectionAction());
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const Divider(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: selectedFiles.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final file = selectedFiles[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    leading: _buildFileLeading(file, colorScheme),
                    title: Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      file.size.asReadableFileSize,
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        context.ref.redux(selectedSendingFilesProvider).dispatch(RemoveSelectedFileAction(index));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileLeading(CrossFile file, ColorScheme colorScheme) {
    if (file.fileType == FileType.text) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.subject_rounded, color: colorScheme.primary, size: 22),
      );
    }
    return SizedBox(
      width: 38,
      height: 38,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SmartFileThumbnail.fromCrossFile(file),
      ),
    );
  }

  Widget _buildBrothersSelectionSection(
    BuildContext context,
    ColorScheme colorScheme,
    List<String> peerBrothers,
    Iterable<Device> nearbyDevices,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Select Brothers to Send',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (peerBrothers.length > 1)
              TextButton(
                onPressed: () {
                  setState(() {
                    if (_selectedBrothers.length == peerBrothers.length) {
                      _selectedBrothers.clear();
                    } else {
                      _selectedBrothers.addAll(peerBrothers);
                    }
                  });
                },
                child: Text(_selectedBrothers.length == peerBrothers.length ? 'Deselect All' : 'Select Both'),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: peerBrothers.map((brotherName) {
            final isSelected = _selectedBrothers.contains(brotherName);
            final onlineDevice = nearbyDevices.firstWhereOrNull(
              (d) => d.alias.toLowerCase().contains(brotherName.toLowerCase()),
            );
            final isOnline = onlineDevice != null;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedBrothers.remove(brotherName);
                      } else {
                        _selectedBrothers.add(brotherName);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? colorScheme.primary.withValues(alpha: 0.12) : colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                              child: Text(
                                brotherName.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join(),
                                style: TextStyle(
                                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                              color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.4),
                              size: 22,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          brotherName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isOnline ? Colors.green : Colors.grey.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                isOnline ? 'Online (${onlineDevice.deviceModel ?? 'Wi-Fi'})' : 'Standby',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isOnline ? Colors.green : colorScheme.onSurface.withValues(alpha: 0.5),
                                  fontWeight: isOnline ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSendActionButton(
    BuildContext context,
    ColorScheme colorScheme,
    List<CrossFile> selectedFiles,
    List<String> peerBrothers,
    Iterable<Device> nearbyDevices,
  ) {
    final hasSelection = _selectedBrothers.isNotEmpty;
    final hasFiles = selectedFiles.isNotEmpty;

    return FilledButton.icon(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      onPressed: _isSending
          ? null
          : () async {
              if (!hasFiles) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please choose a file, folder, or enter live text first.'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              if (!hasSelection) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select at least one brother destination.'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              await _dispatchTransfers(context, selectedFiles);
            },
      icon: _isSending
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.send_rounded, size: 22),
      label: Text(
        _selectedBrothers.isEmpty
            ? 'Select Destination'
            : (_selectedBrothers.length == 1 ? 'Send to ${_selectedBrothers.first}' : 'Send to Both Brothers (${_selectedBrothers.length})'),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _dispatchTransfers(BuildContext context, List<CrossFile> files) async {
    setState(() => _isSending = true);
    final ref = context.ref;
    final defaultFavorites = BrotherConfig.defaultFavoriteBrothers;

    final targetDevices = <Device>[];
    final unreachableBrothers = <String>[];

    for (final brotherName in _selectedBrothers) {
      final favorite = defaultFavorites.firstWhereOrNull(
        (f) => f.alias.toLowerCase() == brotherName.toLowerCase(),
      );

      if (favorite == null) continue;

      final device = await resolveBrotherDevice(ref, favorite);
      if (device != null) {
        targetDevices.add(device);
      } else {
        unreachableBrothers.add(brotherName);
      }
    }

    setState(() => _isSending = false);

    if (unreachableBrothers.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${unreachableBrothers.join(", ")} appears offline or unreachable.'),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    if (targetDevices.isEmpty) return;

    if (targetDevices.length == 1) {
      // Single target: open standard SendPage/ProgressPage directly
      await ref
          .notifier(sendProvider)
          .startSession(
            target: targetDevices.first,
            files: files,
            background: false,
          );
    } else {
      // Multiple targets: initiate concurrent parallel transfers
      for (final device in targetDevices) {
        await ref
            .notifier(sendProvider)
            .startSession(
              target: device,
              files: files,
              background: true,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sending to ${targetDevices.map((d) => d.alias).join(" and ")} simultaneously!'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildActiveSessionsSection(
    BuildContext context,
    ColorScheme colorScheme,
    Map<String, SendSessionState> activeSessions,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Active Transfers',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 16),
            ...activeSessions.values.map((session) {
              final isWaiting = session.status == SessionStatus.waiting;
              final isFinished = session.status == SessionStatus.finished;
              final isSending = session.status == SessionStatus.sending;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: isFinished ? Colors.green.withValues(alpha: 0.15) : colorScheme.primary.withValues(alpha: 0.15),
                  child: Icon(
                    isFinished ? Icons.check_rounded : (isWaiting ? Icons.hourglass_top_rounded : Icons.upload_rounded),
                    color: isFinished ? Colors.green : colorScheme.primary,
                  ),
                ),
                title: Text(session.target.alias, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  isFinished ? 'Completed successfully' : (isWaiting ? 'Connecting / Waiting...' : 'Sending files...'),
                  style: TextStyle(
                    fontSize: 12,
                    color: isFinished ? Colors.green : colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.open_in_new_rounded, size: 20),
                      onPressed: () async {
                        if (session.status == SessionStatus.waiting) {
                          await context.push(
                            () => SendPage(showAppBar: true, closeSessionOnClose: false, sessionId: session.sessionId),
                          );
                        } else {
                          await context.push(
                            () => ProgressPage(showAppBar: true, closeSessionOnClose: false, sessionId: session.sessionId),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () {
                        context.ref.notifier(sendProvider).cancelSession(session.sessionId);
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final double borderRadius;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashWidth = 6.0,
    this.dashGap = 4.0,
    this.borderRadius = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final length = (distance + dashWidth > metric.length) ? metric.length - distance : dashWidth;
        canvas.drawPath(metric.extractPath(distance, distance + length), paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
  }
}
