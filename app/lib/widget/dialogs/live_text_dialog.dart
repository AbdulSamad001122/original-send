import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localsend_app/provider/selection/selected_sending_files_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

class LiveTextDialog extends StatefulWidget {
  const LiveTextDialog({super.key});

  @override
  State<LiveTextDialog> createState() => _LiveTextDialogState();
}

class _LiveTextDialogState extends State<LiveTextDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.edit_note_rounded, color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Live Text Sharing',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'This text will appear live on the receiving device with an instant 1-tap copy button.',
              style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              maxLines: 6,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Type or paste message here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      setState(() {
                        _controller.text = data!.text!;
                      });
                    }
                  },
                  icon: const Icon(Icons.paste_rounded, size: 16),
                  label: const Text('Paste Clipboard'),
                ),
                const Spacer(),
                if (_controller.text.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _controller.clear();
                      });
                    },
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isNotEmpty) {
              context.ref.redux(selectedSendingFilesProvider).dispatch(AddMessageAction(message: text));
              context.pop();
            }
          },
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Add Text'),
        ),
      ],
    );
  }
}
