# device-pairing Specification

## Purpose
Maintains persistent 3-brother device profiles and network resolution targets to allow instantaneous transfers without repeated network discovery scans.

## Requirements

### Requirement: Persistent Brother Device Profiles
The system SHALL maintain pre-configured profiles for the three brother devices (Windows Desktop, macOS Desktop, Android Mobile) in the primary destination view.

#### Scenario: Device list display
- **WHEN** the user opens the application transfer interface
- **THEN** the target cards for the other two brother devices are prominently pinned and available for selection

### Requirement: Direct Network Resolution via mDNS
The system SHALL resolve brother device network addresses using local mDNS hostnames (`.local`) or cached local IPs to initiate connections without waiting for multicast broadcast scans.

#### Scenario: Resolving brother destination
- **WHEN** the user selects a brother device to send a file
- **THEN** the system addresses the target directly using the predefined hostname and port without scanning the broader subnet
