# Spec Delta

## Purpose

Provides a clean, streamlined card interface with dashed drag-and-drop file uploading, default Send tab placement, and live direct text sharing without file generation.

## ADDED Requirements

### Requirement: Primary Send Tab Navigation
The system SHALL position the Send tab as the first item in the primary navigation and display it as the default screen upon application launch.

#### Scenario: App startup navigation
- **WHEN** the user opens the application
- **THEN** the Send tab is automatically selected and displayed as the primary interface

### Requirement: Modern Drag-and-Drop Card Interface
The system SHALL provide a minimalist card containing a dashed drop zone with a cloud upload icon, informative format hints, and a file browser button, allowing users to drop files or folders directly into the zone.

#### Scenario: Dropping files onto transfer zone
- **WHEN** the user drags and drops one or more files or folders onto the drop zone
- **THEN** the files are immediately staged in the selected files list with their names, sizes, and remove actions

### Requirement: Direct Live Text Sharing
The system SHALL provide a direct text composer that transmits the entered message as a live text payload rather than a .txt file, and display incoming text on the recipient device with a one-click copy button.

#### Scenario: Composing and sending live text
- **WHEN** the user selects the Text action, enters text, and transmits it to a recipient
- **THEN** the recipient receives and renders the message text directly in a card with an immediate "Copy to Clipboard" action without saving a file
