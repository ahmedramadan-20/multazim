# Implementation Plan: Privacy Policy Access

## Technical Context

- **UI Framework**: Flutter.
- **Packages**: `url_launcher` (to be verified in `pubspec.yaml`, version resolution via pub if missing).
- **Files Modified**: 
  - `lib/core/router/app_router.dart` (Add `ListTile` to settings sheet).
  - `lib/features/auth/presentation/pages/welcome_page.dart` (Add `TextButton` to Welcome page).

## Current Architecture vs. Target Architecture

1. **Welcome Page**:
   - Update `WelcomePage` to use a layout that pushes the `TextButton` to the bottom without interfering with existing buttons.
2. **Settings Sheet (App Router)**:
   - Within `showModalBottomSheet` inside `app_router.dart`, insert the new `ListTile` with `Icons.privacy_tip_outlined` and title "سياسة الخصوصية" above the export option.
3. **External Launch**:
   - Call `launchUrl(Uri.parse('https://ahmedramadan-20.github.io/multazim-privacy/'), mode: LaunchMode.externalApplication)` on tap.

## Constitution Check

- UI additions conform to standard declarative Flutter patterns specified in the project guidelines.
- Simple, straightforward implementation.

## Phase 0: Outline & Research

- **Dependencies**: Ensure `url_launcher` is in `pubspec.yaml`. No unknowns.

## Phase 1: Design & Contracts

- **Data Models**: None.
- **Contracts**: None.

## Phase 2: Tasks

1. Verify `url_launcher` in `pubspec.yaml`.
2. Modify `WelcomePage` to include Privacy Policy text button.
3. Modify `app_router.dart` to include Privacy Policy list tile.
