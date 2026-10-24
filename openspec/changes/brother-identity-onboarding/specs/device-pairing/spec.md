# Spec Delta

## MODIFIED Requirements

### Requirement: Persistent Brother Device Profiles
The system SHALL maintain pre-configured profiles for the three brother devices (Windows Desktop, macOS Desktop, Android Mobile) in the primary destination view, filtering out the active device's own selected identity so only the other two brothers are shown as destination targets.

#### Scenario: Device list display
- **WHEN** the user opens the application transfer interface
- **THEN** only the target cards or chips for the other two brother devices are displayed and available for quick selection

## ADDED Requirements

### Requirement: Simultaneous Multi-Recipient Transfer
The system SHALL allow the user to select one or both peer brother devices simultaneously and initiate a concurrent transfer session delivering files or text to all selected devices in parallel.

#### Scenario: Sending to both brothers at once
- **WHEN** the user selects multiple brother devices and taps "Send to Selected"
- **THEN** the system initiates parallel transfer sessions to each selected device and tracks their delivery progress concurrently
