import 'package:localsend_app/model/persistence/favorite_device.dart';

/// Central configuration for the 3-Brother edition of LocalSend.
class BrotherConfig {
  /// Pre-Shared Secret Key required for all transfers between the 3 brothers.
  /// Any incoming transfer lacking this key is rejected with HTTP 401 Unauthorized.
  static const String brotherSecretKey = 'BROTHER_VAULT_KEY_786_SECURE';

  /// Whether to auto-accept transfers directly to Downloads without manual confirmation.
  static bool get autoAcceptTransfers => true;

  /// The list of the 3 brother names.
  static const List<String> brotherNames = [
    'Abdul Qadir',
    'Abdullah',
    'Abdul Samad',
  ];

  /// Predefined brother device profiles with their actual names and mDNS hostnames.
  static List<FavoriteDevice> get defaultFavoriteBrothers => [
    const FavoriteDevice(
      id: 'brother-abdul-qadir',
      fingerprint: 'abdul-qadir-fp',
      ip: 'abdul-qadir.local',
      port: 53317,
      alias: 'Abdul Qadir',
      customAlias: true,
    ),
    const FavoriteDevice(
      id: 'brother-abdullah',
      fingerprint: 'abdullah-fp',
      ip: 'abdullah.local',
      port: 53317,
      alias: 'Abdullah',
      customAlias: true,
    ),
    const FavoriteDevice(
      id: 'brother-abdul-samad',
      fingerprint: 'abdul-samad-fp',
      ip: 'abdul-samad.local',
      port: 53317,
      alias: 'Abdul Samad',
      customAlias: true,
    ),
  ];
}
