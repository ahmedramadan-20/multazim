# Implementation Tasks: Privacy Policy Access

## Implementation Strategy

- Implement a minimal viable approach delivering directly against user stories.
- Verify dependencies first, then implement parallelizable UI tasks.

## Phase 1: Setup

**Goal**: Ensure dependencies are available for navigation external links.

- [x] T001 Verify `url_launcher` is defined and run `flutter pub get` if added in `pubspec.yaml`

## Phase 2: Foundational

- No foundational shared backend or models needed for this feature.

## Phase 3: User Story 1 - View Privacy Policy from Welcome Page (P1)

**Goal**: As a new user landing on the Welcome page, I want to access the Privacy Policy.
**Independent Test**: Navigate to the welcome screen and tap the new text button natively launching a browser.

- [x] T002 [P] [US1] Add a TextButton at the very bottom (with small muted text) calling `launchUrl` in `lib/features/auth/presentation/pages/welcome_page.dart`

## Phase 4: User Story 2 - View Privacy Policy from Settings Menu (P2)

**Goal**: As an existing user, I want to access the Privacy Policy from the Settings bottom sheet.
**Independent Test**: Open the Settings menu and tap the "سياسة الخصوصية" tile natively launching a browser.

- [x] T003 [P] [US2] Add a `ListTile` with `Icons.privacy_tip_outlined` and title "سياسة الخصوصية" above export tile in `lib/core/router/app_router.dart`

## Phase 5: Polish & Cross-Cutting Concerns

- [x] T004 Test both elements by tapping to confirm `https://ahmedramadan-20.github.io/multazim-privacy/` opens correctly in an external browser.

## Dependency Graph & Parallel Execution

- T001 (Setup) blocks all UI implementation tasks.
- T002 and T003 can be executed in parallel since they touch completely independent files and routes.
- T004 must be performed after both T002 and T003 are completed to fully verify the feature.
