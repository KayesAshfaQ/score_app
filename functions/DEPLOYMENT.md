# Dart Cloud Functions — Deployment & Scheduling Guide

This backend is built entirely in **Dart** using the `firebase_functions` SDK and shares all domain models with the Flutter client via `packages/shared`.

---

## 1. Deploying the Functions

Deploy to your Firebase project (`score-app-b4eba`):

```bash
# Ensure the Dart functions experiment is active in Firebase CLI
firebase experiments:enable dartfunctions

# Deploy all functions
firebase deploy --only functions
```

Firebase CLI will compile the Dart backend Ahead-of-Time (AOT) and deploy the following HTTPS endpoints:
- `healthCheck`
- `syncLiveMatches`
- `syncTomorrowMatches`
- `sync12hStandings`

---

## 2. Setting Up Cloud Scheduler (Free Tier)

Google Cloud Scheduler gives you **3 free jobs per month** forever with unlimited executions. We use **2 jobs**:

### Job 1: Live Matches & Scores (Every 1 Minute)
Runs every minute (`* * * * *`) during matchdays to update live scores, match minutes, and statuses.

```bash
gcloud scheduler jobs create http sync-live-matches \
  --location="us-central1" \
  --schedule="* * * * *" \
  --time-zone="UTC" \
  --uri="https://us-central1-score-app-b4eba.cloudfunctions.net/syncLiveMatches" \
  --http-method="GET" \
  --headers="x-sync-token=score_app_secure_sync_token" \
  --description="Syncs live football matches and scores every minute"
```

---

### Job 2: Standings & Competitions (Every 12 Hours)
Runs twice a day at 00:00 and 12:00 UTC (`0 */12 * * *`) to update league tables and competition metadata.

```bash
gcloud scheduler jobs create http sync-12h-standings \
  --location="us-central1" \
  --schedule="0 */12 * * *" \
  --time-zone="UTC" \
  --uri="https://us-central1-score-app-b4eba.cloudfunctions.net/sync12hStandings" \
  --http-method="GET" \
  --headers="x-sync-token=score_app_secure_sync_token" \
  --description="Syncs league standings tables and competition metadata every 12 hours"
```

---

## 3. Manual / Testing Execution

You can trigger a sync manually at any time via `curl`:

```bash
# Health check
curl -X GET https://us-central1-score-app-b4eba.cloudfunctions.net/healthCheck

# Manually trigger live matches sync for today
curl -X GET https://us-central1-score-app-b4eba.cloudfunctions.net/syncLiveMatches \
  -H "x-sync-token: score_app_secure_sync_token"

# Manually sync any specific past or future date
curl -X GET "https://us-central1-score-app-b4eba.cloudfunctions.net/syncLiveMatches?date=2026-09-15" \
  -H "x-sync-token: score_app_secure_sync_token"

# Manually trigger 12-hour standings sync
curl -X GET https://us-central1-score-app-b4eba.cloudfunctions.net/sync12hStandings \
  -H "x-sync-token: score_app_secure_sync_token"
```

---

## 4. Local Testing with Firebase Emulators

```bash
# Start Firebase emulator suite
firebase emulators:start --only functions,firestore
```
