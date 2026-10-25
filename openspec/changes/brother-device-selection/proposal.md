# Proposal

## Why

When a brother has BrotherSend open on both his PC and Mobile device (or multiple devices), the sender currently has no way to select which specific device should receive the files. The system arbitrarily selects the first discovered device matching the brother's name.

Introducing an explicit device target selection flow allows the sender to specify whether they want to send to the brother's Mobile, PC, or all active devices, providing deterministic, intentional delivery.

## What Changes

- **Device Selection Prompt**:
  - When initiating a send to a brother who has multiple active devices discovered on the network (e.g. Abdullah's PC and Abdullah's Phone), prompt the user with a clean device picker modal showing the online devices (Mobile / PC / Laptop) and an "All Devices" option.
  - If a brother is offline or only resolved via default mDNS profile, or if only 1 device is online, direct sending continues seamlessly without redundant prompts unless multiple device targets are available.
  - Allow sending directly to the chosen device(s) in parallel.
- **Enhanced Brother Device Discovery Mapping**:
  - Group discovered devices by brother identity so the UI and dispatch engine can enumerate all active devices for each brother.
  - Display the specific device type icon and label (e.g., PC / Laptop vs. Phone / Mobile) on target cards/prompts.

## Capabilities

### Modified Capabilities
- `device-pairing`: Add device target disambiguation requirements allowing the sender to choose between a brother's active mobile or PC devices.

## Impact

- **UI / Views**:
  - Redesigned send dispatch flow in `SendTab` (`app/lib/pages/tabs/send_tab.dart`) to inspect matching devices for selected brothers and display a `BrotherDevicePickerDialog` when disambiguation is needed.
- **Logic**:
  - `BrotherSendHelper` (`app/lib/util/brother_send_helper.dart`) to support resolving multiple active target devices for a single brother alias.
