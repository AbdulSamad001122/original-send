# Design

## Context

See `proposal.md` for background and motivation. Currently, in `SendTab`, the dispatch logic uses:
```dart
final onlineDevice = nearbyDevices.firstWhereOrNull(
  (d) => d.alias.toLowerCase().contains(brotherName.toLowerCase()),
);
```
When a brother is active on both their PC and Phone, `firstWhereOrNull` nondeterministically picks whichever device responded first.

## Goals / Non-Goals

**Goals:**
- Provide clear device disambiguation when sending to a brother who has multiple online devices (e.g. PC and Phone).
- Allow the sender to choose the specific device (PC, Phone, or All Devices).
- Maintain zero-friction dispatch when only a single device is active for a brother.

**Non-Goals:**
- Modifying the underlying protocol transfer engine.
- Re-architecting multicast / mDNS discovery.

## Decisions

- **Decision:** Interactive Device Picker (`BrotherDevicePickerDialog`).
  - *Rationale:* When multiple devices match a selected brother, present a clean, tailored dialog displaying the device roles (PC / Laptop vs. Phone / Mobile), icons, and an option to send to both/all devices.
  - *Alternatives considered:* Always showing separate chips on the SendTab (clutters the interface when brothers only have one device active).
- **Decision:** Automatic Passthrough for Single Device.
  - *Rationale:* If a brother only has one device active on the network, bypass the dialog and dispatch immediately to preserve fast 1-tap transfers.

## Risks / Trade-offs

- [Risk] Sender might close the dialog without choosing.
  → Mitigation: Treat dialog cancellation as aborting the transfer for that brother without failing the other selected recipients.
