import 'package:collection/collection.dart';
import 'package:localsend_app/model/persistence/favorite_device.dart';
import 'package:localsend_app/provider/device_info_provider.dart';
import 'package:localsend_app/provider/http_provider.dart';
import 'package:localsend_app/provider/network/nearby_devices_provider.dart';
import 'package:localsend_app/provider/settings_provider.dart';
import 'package:localsend_isolates/model/device.dart';
import 'package:localsend_isolates/model/dto/multicast_dto.dart';
import 'package:localsend_isolates/rust/api/model.dart' as rust_model;
import 'package:logging/logging.dart';
import 'package:refena_flutter/refena_flutter.dart';

final _logger = Logger('BrotherSendHelper');

/// Resolves a brother's [FavoriteDevice] into an active dialable [Device].
Future<Device?> resolveBrotherDevice(Ref ref, FavoriteDevice favorite) async {
  // 1. Check if the device was already discovered via Wi-Fi mDNS or multicast
  final nearby = ref.read(nearbyDevicesProvider).allDevices.values;
  final discovered = nearby.firstWhereOrNull(
    (d) =>
        d.alias.toLowerCase().contains(favorite.alias.toLowerCase()) ||
        favorite.alias.toLowerCase().contains(d.alias.toLowerCase()) ||
        d.ip.toLowerCase() == favorite.ip.toLowerCase(),
  );

  if (discovered != null) {
    return discovered;
  }

  // 2. Fallback: attempt direct HTTP/HTTPS handshake via configured IP/mDNS
  try {
    final https = ref.read(settingsProvider).https;
    final payload = ref.read(deviceFullInfoProvider).toRegisterDto();
    final response = await ref.read(httpProvider).discovery.register(
      protocol: https ? rust_model.ProtocolType.https : rust_model.ProtocolType.http,
      ip: favorite.ip,
      port: favorite.port,
      payload: payload,
    );
    return response.body.toDevice(favorite.ip, favorite.port, https);
  } catch (e) {
    _logger.info('Could not directly reach ${favorite.alias} at ${favorite.ip}: $e');
    return null;
  }
}
