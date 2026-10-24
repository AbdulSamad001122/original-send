# Proposal: BrotherSend (LocalSend 3-Brother Edition)

## Why
Standard LocalSend is designed as a zero-trust public LAN transfer tool requiring interactive approval for every incoming transfer and scanning for arbitrary devices. For a private 3-brother household (Windows, Mac, Android), this introduces unnecessary friction. A tailored version with mutual pre-shared authentication enables instant, silent file and folder transfers exclusively between the three brothers.

## What Changes
- Add **Pre-Shared Secret Key (PSK)** header verification (`X-Brother-Key`) to LocalSend's HTTP transfer handshake.
- Add **Silent Auto-Accept**: When incoming requests carry a valid brother key, transfers bypass interactive confirmation dialogs and save directly to designated downloads.
- Add **Unauthorized Request Rejection**: Drop or return 401 Unauthorized for any incoming transfer lacking the valid brother key.
- Add **Permanent 3-Brother Profiles**: Pre-configure brother identity cards (Android, Windows, Mac) with mDNS hostnames so devices connect directly without repetitive discovery scans.
- **Out of Scope**:
  - iOS / iPhone support (avoiding 7-day sideloading expiration and Apple Developer fee requirements).
  - Background folder watching / continuous directory syncing (transfers remain explicit file/folder sends).
  - Automatic background clipboard synchronization.
  - Public / internet relay servers (transfers operate purely on home Wi-Fi / LAN).

## Capabilities

### New Capabilities
- `brother-auth`: Mutual pre-shared secret key authentication for all incoming and outgoing transfer requests, blocking unauthorized peers.
- `silent-transfer`: Unattended, instant acceptance and direct-to-disk streaming of incoming files/folders from verified brother devices.
- `device-pairing`: Persistent 3-brother device definitions and mDNS resolution, bypassing periodic multicast discovery dances.

### Modified Capabilities
None (new project setup; no existing specs in `openspec/specs/`).

## Impact
- **Codebase**: LocalSend Flutter project (specifically `server_provider.dart`, `send_provider.dart`, and device discovery/UI views).
- **APIs**: Extends LocalSend HTTP API (`/api/localsend/v2/prepare-upload`) with `X-Brother-Key` header requirement.
- **Platforms**: Windows Desktop, macOS Desktop, and Android Mobile.
- **Dependencies**: Uses LocalSend's existing Flutter dependencies (`shelf`, `riverpod`, `network_info_plus`).
