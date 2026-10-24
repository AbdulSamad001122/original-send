# Design: BrotherSend Architecture

## Context
See `proposal.md` for background and motivation. LocalSend utilizes Flutter with a Shelf-based embedded HTTP server for receiving files and an HTTP client for streaming chunked file transfers over LAN. By default, incoming requests undergo user confirmation in the UI unless global Quick Save is enabled. We are modifying this architecture to introduce authenticated, automatic transfers exclusively for 3 trusted brothers across Windows, macOS, and Android.

## Goals / Non-Goals

**Goals:**
- Provide zero-click, automatic file acceptance directly to disk for incoming requests carrying the valid `X-Brother-Key`.
- Block or return 401 Unauthorized for all other local network requests.
- Provide permanent 3-brother destination endpoints using local mDNS hostnames (`.local`).
- Keep modifications minimal and isolated within the network server and client providers.

**Non-Goals:**
- iOS compilation or App Store distribution.
- Continuous folder watching or bidirectional folder synchronization.
- Clipboard synchronization.
- Centralized external authentication servers.

## Decisions

### 1. Forking LocalSend vs. Building from Scratch
- **Decision:** Fork and modify `localsend/localsend` rather than building an app from scratch.
- **Rationale:** LocalSend has robust, battle-tested solutions for Android Scoped Storage, gigabit chunked HTTP streaming, pause/resume, and native OS tray/notification integrations. Building from scratch would take months of edge-case debugging.
- **Alternatives Considered:** Building a lightweight Go/Rust daemon with web UI (lacks native Android share sheet integration and requires custom mobile wrappers).

### 2. Pre-Shared Key (PSK) vs. Asymmetric Cryptography
- **Decision:** Use a shared secret passphrase (`X-Brother-Key` header) embedded in the private fork build or configured once.
- **Rationale:** The 3 brothers have 100% mutual trust. A symmetric shared key provides complete isolation from any unauthorized devices on the home Wi-Fi without the complexity of managing and exchanging public key rings.
- **Alternatives Considered:** TLS client certificates or SSH-style public key pairing (excessive ceremony for a closed 3-person private household).

### 3. Direct mDNS Hostnames vs. Periodic Multicast UDP Scans
- **Decision:** Pin target devices to local mDNS hostnames (`brother1.local`, `brother2.local`, `brother3.local`) on default port 53317.
- **Rationale:** Home Wi-Fi routers frequently reassign IP addresses via DHCP. mDNS hostname resolution ensures devices always find each other without requiring continuous battery-draining UDP multicast broadcasts.
- **Alternatives Considered:** Static router IP leases (requires router admin access) or continuous multicast pinging (can fail on routers with buggy multicast snooping).

### 4. GitHub Actions CI for Multi-Platform Distribution
- **Decision:** Automate packaging of Android APK, Windows executable, and macOS DMG via GitHub Actions.
- **Rationale:** Compiling for Android, Windows, and macOS on a single local development machine requires extensive SDK installations. GitHub Actions runners build all three platforms cleanly in the cloud.

## Risks / Trade-offs

- **[Router AP Isolation / Client Isolation enabled on Wi-Fi]** → *Mitigation:* Ensure home router has Client Isolation disabled so LAN devices can communicate directly on port 53317.
- **[Android Background Doze mode]** → *Mitigation:* Keep LocalSend's foreground service option enabled so the Android device can receive files when the screen is locked.
- **[Upstream LocalSend divergence]** → *Mitigation:* Keep code changes restricted to `server_provider.dart` (receiver) and `send_provider.dart` (sender), preserving easy rebasing against future upstream releases.

## Migration / Setup Plan
1. Clone `localsend/localsend` into the workspace.
2. Implement header inspection in the HTTP server endpoint (`/api/localsend/v2/prepare-upload`).
3. Implement header injection in the outgoing send client.
4. Add pinned brother profile configuration.
5. Create GitHub Actions workflow file (`.github/workflows/build.yml`) for automated APK, EXE, and DMG generation.
