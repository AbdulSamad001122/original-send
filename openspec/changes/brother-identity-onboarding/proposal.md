# Proposal

## Why

Currently, when BrotherSend is launched on a new device (Windows or Android), the user has to manually navigate to Settings to edit their device alias from a default random name (e.g. "Quick Pineapple") to their actual identity ("Abdul Samad", "Abdul Qadir", or "Abdullah"). In addition, the device role (Laptop/PC vs. Phone/Mobile) is not explicitly selected, the Send interface is cluttered with unneeded buttons (multiple picker buttons, troubleshoot links, complex mode menus), the default tab on launch is Receive rather than Send, sending text creates and transfers a `.txt` file rather than direct copyable text, and transfers cannot be broadcast to both brothers at once.

A unified onboarding wizard combined with a clean, modern transfer interface—matching the user's reference card design with a dashed drag-and-drop zone, first-tab Send placement, multi-recipient selection, and direct live text transfer—streamlines BrotherSend into an intuitive, zero-friction tool tailored exclusively for the three brothers.

## What Changes

- **2-Step Initial Launch Onboarding**:
  - Step 1: "Who are you?" presenting three clear brother choices: **Abdul Qadir**, **Abdullah**, and **Abdul Samad**.
  - Step 2: "What device is this?" allowing selection of device type / role: **PC / Laptop** or **Phone / Mobile**.
  - Automatically saves the chosen identity and device type permanently into local storage.
- **Primary Send Tab Placement**:
  - Reorder sidebar / navigation tabs so the **Send tab is FIRST** (index 0), making it the default screen on app startup.
- **Modern & Simple Drag-and-Drop Card Interface**:
  - Remove cluttered buttons, mode selectors, and troubleshooting links from the main Send view.
  - Implement a modern card featuring a prominent dashed-border drop zone with cloud upload icon, *"Choose a file or drag & drop it here"*, format/size guidance, and a clean *"Browse File"* action button matching the user's reference design.
  - Selected files list showing icon, filename, size, and individual remove actions.
- **Multi-Recipient Send (Send to One or Both Brothers)**:
  - Dynamically display only the other two brothers (excluding the local device).
  - Allow selecting one or both brothers simultaneously with checkable recipient chips/cards.
  - Single *"Send to Selected"* button executes concurrent transfer to all selected targets in parallel.
- **Direct Live Text Sharing (No `.txt` files)**:
  - Provide a clean Text editor modal for typing or pasting messages.
  - Send the text directly as a live message payload rather than creating an attachment `.txt` file.
  - On the recipient device, instantly display the incoming text message with a 1-tap **"Copy to Clipboard"** button.
- **Windows Explorer 1-Click Context Menu**:
  - Register direct top-level Windows Explorer right-click context menu entries (`Send with BrotherSend`) under `HKCU\Software\Classes\*\shell` and `Directory\shell` for instant sharing.
- **Feature & Build Streamlining**:
  - Disable unused LocalSend features (e.g., Web Send / browser link share) to optimize the codebase and accelerate GitHub Actions CI workflows for Windows and Android.

## Capabilities

### New Capabilities
- `brother-identity`: First-launch identity and device type onboarding wizard, persisting identity and registering top-level Windows Explorer context menu actions.
- `direct-transfer-ui`: Primary Send tab placement, modern card with dashed drag-and-drop zone, and direct live text sharing bypassing `.txt` file creation.

### Modified Capabilities
- `device-pairing`: Filter predefined brother targets to exclude the local device, and support simultaneous multi-recipient transfers to one or both brothers.

## Impact

- **UI / Views**:
  - New `BrotherIdentityDialog` (2-step modal).
  - `HomePage` reordered with `HomeTab.send` as initial tab.
  - Redesigned `SendTab` with dashed drop zone, selected files list, multi-select brother cards, and direct text editor.
- **Network / Transfer Logic**:
  - Multi-target dispatch in `SendController` using `Future.wait`.
  - Direct message transfer handling on sender and receiver.
- **Platform Support**: Fully compatible with Windows desktop and Android mobile.
