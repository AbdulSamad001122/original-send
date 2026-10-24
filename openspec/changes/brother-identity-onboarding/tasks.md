# Tasks

## 1. Onboarding Dialog & Device Type Selection

- [x] 1.1 Create `BrotherIdentityDialog` in `app/lib/widget/dialogs/brother_identity_dialog.dart` with 2-step selection (Brother Name + Device Type: PC/Laptop vs Phone/Mobile).
- [x] 1.2 Wire `HomePage` (`app/lib/pages/home_page.dart`) to trigger `BrotherIdentityDialog` on first launch when identity is unconfigured.
- [x] 1.3 Add identity and device type reselection action in `SettingsTab`.

## 2. Sidebar Navigation & Tab Reordering

- [x] 2.1 Reorder navigation tabs in `app/lib/pages/home_page.dart` so `HomeTab.send` is at index 0 (default launch screen).

## 3. Modern Drag-and-Drop Card UI & Clutter Removal

- [x] 3.1 Build dashed drop zone card widget on `SendTab` (`app/lib/pages/tabs/send_tab.dart`) with cloud upload icon, subtitle, and browse button matching reference mockup.
- [x] 3.2 Remove redundant selection buttons, raw troubleshoot links, and cluttered icons from the main Send screen.
- [x] 3.3 Implement selected files preview card with file icon, name, readable size, and remove button.

## 4. Multi-Recipient Selection & Parallel Transfer

- [x] 4.1 Filter brother chips on `SendTab` to omit current local device and support multi-select toggle state (one or both brothers).
- [x] 4.2 Implement "Send to Selected" button executing parallel transfer dispatch to all selected brothers via `SendController`.

## 5. Direct Live Text Messaging (No .txt File)

- [x] 5.1 Add text composer modal in `SendTab` allowing direct message input.
- [x] 5.2 Transmit raw message payload directly without generating a `.txt` file wrapper.
- [x] 5.3 Verify receiver displays live selectable text with a one-tap "Copy to Clipboard" button.

## 6. Windows Shell Context Menu & Build Optimization

- [x] 6.1 Register top-level Windows Explorer context menu in `HKCU\Software\Classes\*\shell\BrotherSend` for 1-click file sending.
- [x] 6.2 Streamline GitHub Actions workflow `.github/workflows/build.yml` to focus purely on Windows Portable and Android APK builds.
