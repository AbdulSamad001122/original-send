# Tasks

## 1. Device Picker Modal

- [x] 1.1 Create `BrotherDevicePickerDialog` in `app/lib/widget/dialogs/brother_device_picker_dialog.dart` displaying online devices for a brother (PC / Laptop, Phone / Mobile, or All Devices) with descriptive icons and badges.

## 2. Integration with Send Dispatch

- [x] 2.1 Update send dispatch flow in `app/lib/pages/tabs/send_tab.dart` to inspect matching devices for selected brothers, invoke `BrotherDevicePickerDialog` when multiple devices are active, and dispatch transfers to the chosen target(s).
- [x] 2.2 Verify Dart compilation with `fvm flutter analyze` or formatting checks.
