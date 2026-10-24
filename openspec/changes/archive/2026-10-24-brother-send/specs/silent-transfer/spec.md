# Spec Delta: silent-transfer

## Purpose
Enables unattended, instant file and folder reception directly to disk when receiving transfers from authenticated brother peers.

## ADDED Requirements

### Requirement: Automatic Silent Acceptance
The system SHALL bypass all interactive confirmation dialogs and automatically accept incoming file and folder transfers that have successfully passed brother authentication.

#### Scenario: Incoming file from verified brother
- **WHEN** an authenticated incoming transfer request is received
- **THEN** the system generates an acceptance session token and begins file streaming without prompting the user

#### Scenario: File destination saving
- **WHEN** incoming files finish streaming from a verified brother transfer
- **THEN** the files are written directly into the pre-configured downloads destination directory
