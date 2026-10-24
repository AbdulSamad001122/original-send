import 'package:flutter/material.dart';
import 'package:localsend_isolates/model/device.dart';

extension DeviceTypeExt on DeviceType {
  String get humanName {
    return switch (this) {
      DeviceType.mobile => 'Phone / Mobile',
      DeviceType.desktop => 'PC / Laptop',
      DeviceType.web => 'Web',
      DeviceType.headless => 'Headless',
      DeviceType.server => 'Server',
    };
  }

  IconData get icon {
    return switch (this) {
      DeviceType.mobile => Icons.smartphone,
      DeviceType.desktop => Icons.computer,
      DeviceType.web => Icons.language,
      DeviceType.headless => Icons.terminal,
      DeviceType.server => Icons.dns,
    };
  }
}
