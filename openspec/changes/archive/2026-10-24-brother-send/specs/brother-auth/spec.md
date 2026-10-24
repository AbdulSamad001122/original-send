# Spec Delta: brother-auth

## Purpose
Provides pre-shared secret key authentication for all incoming and outgoing transfer requests, preventing unauthorized peers on the local network from connecting.

## ADDED Requirements

### Requirement: Pre-Shared Key Verification on Incoming Requests
The system SHALL verify the presence and validity of a pre-shared secret key header (`X-Brother-Key`) on all incoming HTTP transfer requests before accepting any data.

#### Scenario: Valid brother key provided
- **WHEN** an incoming transfer request includes an `X-Brother-Key` header matching the configured brother secret
- **THEN** the system accepts the request and proceeds to upload preparation

#### Scenario: Missing or invalid key provided
- **WHEN** an incoming transfer request lacks `X-Brother-Key` or includes an incorrect key
- **THEN** the system rejects the request immediately with HTTP 401 Unauthorized status

### Requirement: Outgoing Key Attachment
The system SHALL attach the configured pre-shared secret key header (`X-Brother-Key`) to every outgoing transfer request directed to peer brother devices.

#### Scenario: Sending files to brother device
- **WHEN** a user initiates a transfer to a brother device
- **THEN** the HTTP request payload includes the `X-Brother-Key` header populated with the local brother secret
