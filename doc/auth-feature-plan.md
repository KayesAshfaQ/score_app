# Authentication Feature Implementation Plan

## Goal
Implement a foundational Authentication feature in `score_app` comprising an empty/extensible core `AuthService`, an `AuthProvider` state container, and Scora dark-themed `SignInPage` and `SignUpPage` wired via `go_router` and `provider`.

---

## Current Context & Assumptions
- **App Stack**: Flutter 3.10+, `provider: ^6.1.5+1`, `go_router: ^18.0.1`, `firebase_auth: ^6.7.0` (already declared in `pubspec.yaml`), `packages/shared`.
- **Project Structure**: Feature-first hierarchy in `lib/app/features/` with cross-cutting infrastructure in `lib/app/core/`.
- **Theme**: Dark stadium aesthetic (`AppTheme.darkBackground = 0xFF0F1424`, `AppTheme.cardBackground = 0xFF1B2238`, `AppTheme.accentBlue = 0xFF3B82F6`, `AppTheme.liveRed = 0xFFEF4444`).
- **User Requirement**: Create an empty/scaffolded core authentication service, sign-in & sign-up screens, and an `AuthProvider` with complete form validation and routing before wiring live backend credentials.

---

## Architecture & Proposed Approach
```
lib/app/
├── core/
│   ├── router/
│   │   └── app_router.dart          <-- Register /signin and /signup routes
│   └── services/
│       └── auth_service.dart        <-- Core empty/stubbed AuthService contract
├── features/
│   └── auth/
│       ├── pages/
│       │   ├── sign_in_page.dart    <-- Email/Password sign-in form
│       │   └── sign_up_page.dart    <-- Email/Password/Confirm sign-up form
│       └── providers/
│           └── auth_provider.dart   <-- State manager for auth status, loading & errors
└── app.dart                         <-- Wire AuthService & AuthProvider into MultiProvider
```

The `AuthService` in `core/services/` defines the authentication contract with stubbed methods and ready-to-wire `firebase_auth` integration hooks. The `AuthProvider` exposes clean reactive state (`isLoading`, `errorMessage`, `isAuthenticated`, `currentUserEmail`) consumed by `SignInPage` and `SignUpPage`.

---

## Phased Implementation Tasks

### Phase 1: Core Authentication Service Contract
**Target File**: `/Users/kays/dev/flutter/score_app/lib/app/core/services/auth_service.dart`

1. Create directory `lib/app/core/services/` if not present.
2. Implement `AuthService` with standard auth method signatures and stubbed/mock-ready responses:
   - `Future<bool> signInWithEmailAndPassword(String email, String password)`
   - `Future<bool> signUpWithEmailAndPassword(String email, String password, {String? displayName})`
   - `Future<void> signOut()`
   - `Future<void> resetPassword(String email)`
   - `Stream<String?> get authStateChanges`
   - `String? get currentUserId`
   - `String? get currentUserEmail`
   - `bool get isAuthenticated`
3. **Verification Command**:
   ```bash
   flutter analyze lib/app/core/services/auth_service.dart
   ```
   **Expected**: `No issues found!`.

---

### Phase 2: AuthProvider State Management & Unit Tests
**Target Files**:
- `/Users/kays/dev/flutter/score_app/lib/app/features/auth/providers/auth_provider.dart`
- `/Users/kays/dev/flutter/score_app/test/features/auth/auth_provider_test.dart`

1. Create `AuthProvider` extending `ChangeNotifier`:
   - State variables:
     - `bool _isLoading = false`
     - `String? _errorMessage`
     - `bool _isAuthenticated = false`
     - `String? _currentUserEmail`
   - Getters: `isLoading`, `errorMessage`, `isAuthenticated`, `currentUserEmail`.
   - Actions:
     - `Future<bool> signIn(String email, String password)`
     - `Future<bool> signUp(String email, String password, {String? displayName})`
     - `Future<void> signOut()`
     - `void clearError()`
2. Write unit tests in `test/features/auth/auth_provider_test.dart`:
   - Test initial state (`isLoading == false`, `isAuthenticated == false`).
   - Test `signIn` sets `isLoading = true` during execution and clears upon completion.
   - Test error propagation when service throws an exception.
   - Test `clearError()` resets `_errorMessage`.
3. **Verification Command**:
   ```bash
   flutter test test/features/auth/auth_provider_test.dart
   ```
   **Expected**: `All tests passed!`.

---

### Phase 3: Presentation — SignInPage
**Target File**: `/Users/kays/dev/flutter/score_app/lib/app/features/auth/pages/sign_in_page.dart`

1. Build `SignInPage` (`StatefulWidget`):
   - Global form key `_formKey = GlobalKey<FormState>()`.
   - Controllers: `_emailController`, `_passwordController`.
   - Password obscure text toggle (`_obscurePassword = true`).
   - Scora dark theme styling:
     - Background: `AppTheme.darkBackground`.
     - Inputs styled with `AppTheme.cardBackground`, rounded borders (`BorderRadius.circular(12)`), hint texts, and soccer-themed accents.
     - Email regex validation (`^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+`).
     - Password validation (`value.isNotEmpty`, minimum length 6).
   - "Sign In" button with `Consumer<AuthProvider>` showing `CircularProgressIndicator` when loading.
   - Inline error banner when `authProvider.errorMessage != null`.
   - Navigation link at bottom: "Don't have an account? Sign Up" -> `context.push('/signup')`.
2. **Verification Command**:
   ```bash
   flutter analyze lib/app/features/auth/pages/sign_in_page.dart
   ```
   **Expected**: `No issues found!`.

---

### Phase 4: Presentation — SignUpPage
**Target File**: `/Users/kays/dev/flutter/score_app/lib/app/features/auth/pages/sign_up_page.dart`

1. Build `SignUpPage` (`StatefulWidget`):
   - Global form key `_formKey = GlobalKey<FormState>()`.
   - Controllers: `_nameController`, `_emailController`, `_passwordController`, `_confirmPasswordController`.
   - Obscure toggles for password and confirm password fields.
   - Validation:
     - Name field validation (non-empty).
     - Email validation (regex format check).
     - Password validation (at least 6 characters).
     - Confirm password validation (must match `_passwordController.text`).
   - "Create Account" button with loading state.
   - Navigation link: "Already have an account? Sign In" -> `context.pop()`.
2. **Verification Command**:
   ```bash
   flutter analyze lib/app/features/auth/pages/sign_up_page.dart
   ```
   **Expected**: `No issues found!`.

---

### Phase 5: Routing & Dependency Injection
**Target Files**:
- `/Users/kays/dev/flutter/score_app/lib/app/core/router/app_router.dart`
- `/Users/kays/dev/flutter/score_app/lib/app.dart`
- `/Users/kays/dev/flutter/score_app/lib/app/features/fixtures/pages/fixtures_page.dart`

1. Update `AppRouter`:
   - Add route `/signin`:
     ```dart
     GoRoute(
       path: '/signin',
       builder: (context, state) => const SignInPage(),
     ),
     ```
   - Add route `/signup`:
     ```dart
     GoRoute(
       path: '/signup',
       builder: (context, state) => const SignUpPage(),
     ),
     ```
2. Update `lib/app.dart`:
   - Register `Provider<AuthService>(create: (_) => AuthService())`.
   - Register `ChangeNotifierProxyProvider<AuthService, AuthProvider>`:
     ```dart
     ChangeNotifierProxyProvider<AuthService, AuthProvider>(
       create: (context) => AuthProvider(authService: context.read<AuthService>()),
       update: (_, authService, previous) =>
           previous ?? AuthProvider(authService: authService),
     ),
     ```
3. Update `FixturesPage` AppBar:
   - Add an auth icon button in the AppBar actions:
     - If authenticated: display user initials or profile icon.
     - If unauthenticated: display `Icons.person_outline_rounded` that invokes `context.push('/signin')`.

---

### Phase 6: Full Verification & Integration Testing
1. Run full project analysis:
   ```bash
   flutter analyze lib/
   ```
   **Expected**: `No issues found!`.
2. Run test suite:
   ```bash
   flutter test
   ```
   **Expected**: All unit and widget tests pass.
3. Test end-to-end routing transitions between `/`, `/signin`, and `/signup`.

---

## Risks, Tradeoffs & Decisions
1. **Empty / Stubbed AuthService vs. Direct FirebaseAuth**:
   - Creating `AuthService` as a clean abstraction in `lib/app/core/services/` allows UI development and tests to run immediately without requiring live Firebase Auth rules or Google Services setup on iOS/Android emulators.
   - When ready for production Firebase Auth, `AuthService` can delegate directly to `FirebaseAuth.instance.signInWithEmailAndPassword` with zero changes to UI or `AuthProvider`.
2. **Navigation Flow**:
   - Signing in should pop back to the previous screen or navigate to `/`.
   - A dedicated Sign In button on `FixturesPage`'s AppBar provides clear discovery without locking unauthenticated users out of public fixture scores.

---

## Verification & Phased Review Checkpoints
- **Phase 1 Checkpoint**: `AuthService` created & clean static analysis. Commit: `feat(core): add core authentication service contract`.
- **Phase 2 Checkpoint**: `AuthProvider` + unit tests passing. Commit: `feat(auth): implement AuthProvider with unit tests`.
- **Phase 3 Checkpoint**: `SignInPage` UI built with dark theme and validation. Commit: `feat(auth): add SignInPage presentation widget`.
- **Phase 4 Checkpoint**: `SignUpPage` UI built with confirmation validation. Commit: `feat(auth): add SignUpPage presentation widget`.
- **Phase 5 Checkpoint**: `app_router.dart` and `app.dart` integrated with app bar entrypoint. Commit: `feat(auth): register auth routes and inject AuthProvider into MultiProvider`.
- **Phase 6 Checkpoint**: `flutter analyze` clean, test suite passing, final review.
