# Design

## Context

BrotherSend is tailored for seamless, daily file and text sharing among three brothers across their PCs/laptops and mobile devices. The app replaces the generic LocalSend layout with a simplified, elegant UI inspired by modern upload cards, prioritizes sending as the main entry point, and provides an effortless 2-step onboarding wizard.

## Goals / Non-Goals

**Goals:**
- Present a 2-step onboarding dialog on first launch: choose brother identity (Abdul Qadir, Abdullah, Abdul Samad), then choose device type (PC/Laptop or Phone/Mobile).
- Set Send tab as the first item in sidebar and bottom navigation (index 0).
- Simplify `SendTab` with a modern dashed drop zone card (matching user reference mockup) supporting direct file and folder drag-and-drop.
- Support multi-recipient selection (toggle one or both brothers) and concurrent transfer.
- Support direct live text messaging without `.txt` file wrapping, providing a 1-tap clipboard copy button on the receiver.
- Provide top-level Windows Explorer right-click integration (`HKCU\Software\Classes\*\shell\BrotherSend`).
- Streamline CI and build footprint for fast Windows and Android builds.

**Non-Goals:**
- External web send link hosting or public browser downloads (simplified out in favor of direct brother-to-brother vault protocol).
- Complex discovery scanning for arbitrary public devices.

## Decisions

### 1. 2-Step Onboarding Wizard (`BrotherIdentityDialog`)
- **Choice**: Display a modal dialog on first launch when alias is not configured.
  - Step 1: 3 cards for brother identities (Abdul Qadir, Abdullah, Abdul Samad).
  - Step 2: 2 cards for device types (PC/Laptop with desktop icon, Phone/Mobile with phone icon).
- **Rationale**: Sets both the alias and device type cleanly, saving `brotherIdentitySelected: true` in persistence.

### 2. Default Initial Tab: Send First
- **Choice**: In `app/lib/pages/home_page.dart`, reorder the `HomeTab` list to `[HomeTab.send, HomeTab.receive, HomeTab.settings]`.
- **Rationale**: The user primarily launches BrotherSend to share content immediately.

### 3. Streamlined Drag-and-Drop Card
- **Choice**: Build a clean card widget on `SendTab` with a dashed border (`CustomPainter`), cloud upload icon, informative labels ("Choose a file or drag & drop it here"), and a "Browse File" button. Wrap with `DropTarget` to accept drops anywhere on the card.
- **Rationale**: Replaces cluttered buttons with an aesthetic, modern interface directly modeled after the user's reference mockup.

### 4. Multi-Recipient Selection & Parallel Dispatch
- **Choice**: Present brother recipient chips as toggles (`Set<Device> selectedBrothers`). A primary "Send to Selected" button triggers `Future.wait` on `SendController.send` for each selected device.
- **Rationale**: Enables sharing to one or both brothers in a single tap without re-selecting files.

### 5. Direct Live Text Transfer Protocol
- **Choice**: When composing text, dispatch a session where `files` is empty or carries `message` directly in `PrepareUploadDto`, or transmit via direct text payload. On receipt, the server emits `session.message` which triggers `ReceivePage`'s message viewer with `SelectableText` and a prominent "Copy to Clipboard" button.
- **Rationale**: Eliminates creating and saving unwanted `.txt` attachment files on disk when only sharing text/links.

### 6. Windows Shell 1-Click Context Menu
- **Choice**: Register `HKCU\Software\Classes\*\shell\BrotherSend` and `Directory\shell\BrotherSend`.
- **Rationale**: Provides instant 1-click sharing directly from Windows File Explorer without admin rights.

## Risks / Trade-offs

- **Concurrent Send Bandwidth**: Sending large files to two devices over Wi-Fi splits local upload bandwidth.
  - *Mitigation*: Both transfers execute over separate local TCP streams; LocalSend's Rust core handles concurrent outbound sessions efficiently.
