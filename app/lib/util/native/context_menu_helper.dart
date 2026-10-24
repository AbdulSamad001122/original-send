import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

final _logger = Logger('ContextMenuHelper');

Future<bool> enableContextMenu() async {
  if (defaultTargetPlatform != TargetPlatform.windows) {
    return false;
  }

  try {
    final exe = Platform.resolvedExecutable.replaceAll('/', '\\');
    final String script = '''
\$TargetPath = "$exe"
\$ShortcutFile = "${_getWindowsFilePath(_windowsFileName)}"

# 1. Create SendTo shortcut
\$WScriptShell = New-Object -ComObject WScript.Shell
\$Shortcut = \$WScriptShell.CreateShortcut(\$ShortcutFile)
\$Shortcut.TargetPath = \$TargetPath
\$Shortcut.Save()

# 2. Register direct 1-click Windows Explorer right-click shell menu
\$regKeyFiles = "HKCU:\\Software\\Classes\\*\\shell\\BrotherSend"
\$regKeyDirs  = "HKCU:\\Software\\Classes\\Directory\\shell\\BrotherSend"

New-Item -Path \$regKeyFiles -Force | Out-Null
Set-ItemProperty -Path \$regKeyFiles -Name "(Default)" -Value "Send with BrotherSend"
Set-ItemProperty -Path \$regKeyFiles -Name "Icon" -Value "\$TargetPath"
New-Item -Path "\$regKeyFiles\\command" -Force | Out-Null
Set-ItemProperty -Path "\$regKeyFiles\\command" -Name "(Default)" -Value "`"\$TargetPath`" `"%1`""

New-Item -Path \$regKeyDirs -Force | Out-Null
Set-ItemProperty -Path \$regKeyDirs -Name "(Default)" -Value "Send with BrotherSend"
Set-ItemProperty -Path \$regKeyDirs -Name "Icon" -Value "\$TargetPath"
New-Item -Path "\$regKeyDirs\\command" -Force | Out-Null
Set-ItemProperty -Path "\$regKeyDirs\\command" -Name "(Default)" -Value "`"\$TargetPath`" `"%1`""
''';

    final result = await Process.run('powershell', ['-NoProfile', '-Command', script]);
    if (result.stderr != null && result.stderr.toString().isNotEmpty) {
      _logger.warning('Powershell stderr while setting context menu: ${result.stderr}');
    }
    return await File(_getWindowsFilePath(_windowsFileName)).exists();
  } catch (e) {
    _logger.severe('Failed to enable context menu: $e');
    return false;
  }
}

Future<bool> disableContextMenu() async {
  try {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        final file = File(_getWindowsFilePath(_windowsFileName));
        if (await file.exists()) {
          await file.delete();
        }

        const script = '''
Remove-Item -Path "HKCU:\\Software\\Classes\\*\\shell\\BrotherSend" -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "HKCU:\\Software\\Classes\\Directory\\shell\\BrotherSend" -Recurse -ErrorAction SilentlyContinue
''';
        await Process.run('powershell', ['-NoProfile', '-Command', script]);
        return true;
      default:
        return false;
    }
  } catch (e) {
    return false;
  }
}

Future<bool> isContextMenuEnabled() async {
  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
      return await File(_getWindowsFilePath(_windowsFileName)).exists();
    default:
      return false;
  }
}

const _windowsFileName = 'BrotherSend';

String _getWindowsFilePath(String appName) {
  final appData = Platform.environment['APPDATA'];
  return '$appData/Microsoft/Windows/SendTo/$appName.lnk';
}
