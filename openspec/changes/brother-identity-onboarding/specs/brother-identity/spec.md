# Spec Delta

## Purpose

Provides a zero-effort initial launch onboarding experience that prompts each brother to select their identity and device type, persisting their name and setting up direct Windows shell integration.

## ADDED Requirements

### Requirement: Initial Launch Identity and Device Type Selection
The system SHALL display a 2-step onboarding dialog on the first application launch if an identity has not yet been selected: Step 1 prompts the user to select which brother they are (Abdul Qadir, Abdullah, or Abdul Samad), and Step 2 prompts the user to select their device type (PC / Laptop or Phone / Mobile).

#### Scenario: First application launch
- **WHEN** the application is launched for the first time on any device
- **THEN** a prominent dialog asks "Who are you?" with choices for Abdul Qadir, Abdullah, and Abdul Samad, followed by device type selection

### Requirement: Persistent Identity and Device Role Storage
The system SHALL persist the chosen brother identity and device type in local settings upon selection and dismiss the onboarding prompt permanently.

#### Scenario: Completing onboarding
- **WHEN** the user selects their brother identity and device type
- **THEN** the application sets the local device alias and device model to the selected choices and marks onboarding as completed

### Requirement: Identity Reconfiguration via Settings
The system SHALL allow the user to change or re-select their brother identity and device type at any time from the application settings view.

#### Scenario: Changing identity in settings
- **WHEN** the user navigates to the identity section in settings and chooses a different brother or device type
- **THEN** the device alias updates immediately and the outgoing transfer view reflects the new selection

### Requirement: Direct Windows Explorer Context Menu Action
The system SHALL register a top-level context menu entry in the Windows File Explorer shell for all files and directories, enabling immediate 1-click sharing to BrotherSend without traversing secondary menus.

#### Scenario: Right-clicking file in File Explorer
- **WHEN** the user right-clicks any file or directory in Windows File Explorer
- **THEN** a top-level "Send with BrotherSend" action is available directly in the primary context menu
