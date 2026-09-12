# Score App — Firebase Cloud Functions (Dart)

This directory contains native Dart Cloud Functions for Firebase using the `firebase_functions` SDK and `google_cloud_firestore`.

## Prerequisites
- Dart SDK `>=3.13.0`
- Firebase CLI with Dart functions experiment enabled:
  ```bash
  firebase experiments:enable dartfunctions
  ```

## Development
```bash
dart pub get
dart analyze
```

## Structure
- `bin/server.dart`: Server entry point registering HTTPS sync endpoints (`runFunctions`)
- `lib/config.dart`: Configuration, API tokens, and sync security guards
- `lib/services/football_api.dart`: football-data.org v4 HTTP client
- `lib/services/firestore_sync.dart`: Admin Firestore batch-writes using `package:shared/shared.dart`
