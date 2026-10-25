# Spec Delta

## ADDED Requirements

### Requirement: Sender Target Device Disambiguation
The system SHALL prompt the sender to choose the specific target device (PC / Laptop, Phone / Mobile, or All Devices) when sending to a brother who has multiple active devices discovered on the network.

#### Scenario: Multiple devices online for a brother
- **WHEN** the sender initiates a transfer to a selected brother and that brother has multiple active devices online
- **THEN** the system presents a device selection modal allowing the sender to choose between Mobile, PC, or All Devices before dispatching

#### Scenario: Single device online for a brother
- **WHEN** the sender initiates a transfer to a selected brother and only one device is active or resolved for that brother
- **THEN** the system dispatches the transfer directly to that device without blocking with a selection prompt
