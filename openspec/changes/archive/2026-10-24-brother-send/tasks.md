# Tasks: BrotherSend Implementation

## 1. Repository Setup & Codebase Preparation

- [x] 1.1 Clone official LocalSend repository into the workspace root and verify `app/pubspec.yaml` exists.
- [x] 1.2 Locate and document the Shelf HTTP server upload handler (`server_provider.dart`) and client sender provider (`send_provider.dart`) in `app/lib/`.

## 2. Pre-Shared Key Authentication (brother-auth)

- [x] 2.1 Implement `X-Brother-Key` header inspection in the HTTP server's `/api/localsend/v2/prepare-upload` endpoint and verify missing/invalid keys yield HTTP 401.
- [x] 2.2 Implement `X-Brother-Key` header attachment in outgoing HTTP file transfer client requests and verify outgoing payloads contain the configured brother secret.

## 3. Silent Auto-Accept Transfer Engine (silent-transfer)

- [x] 3.1 Implement bypass logic for interactive confirmation dialogs on authenticated brother requests and verify file sessions are auto-approved.
- [x] 3.2 Ensure completed transfers stream directly to the local Downloads directory and verify no secondary prompts or popups block disk writing.

## 4. 3-Brother Profiles & mDNS Addressing (device-pairing)

- [x] 4.1 Pre-configure the 3 brother identity profiles (Windows Desktop, macOS Desktop, Android Mobile) in default device favorites and verify they display prominently in the send UI.
- [x] 4.2 Configure direct mDNS hostname resolution (`brother1.local`, `brother2.local`, `brother3.local`) on port 53317 and verify connections bypass periodic multicast network scans.

## 5. Cross-Platform Build Automation

- [x] 5.1 Create GitHub Actions multi-platform build workflow (`.github/workflows/build.yml`) targeting Android APK, Windows executable, and macOS DMG, and verify workflow syntax.
