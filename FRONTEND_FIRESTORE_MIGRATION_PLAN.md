# Frontend Firestore Integration Plan

## 1. Context & Objective
Now that our Dart Cloud Functions backend is live and actively syncing data from `football-data.org` into Cloud Firestore, the Flutter app needs to be migrated from client-side HTTP calls (`DioClient`) to **realtime Cloud Firestore stream listeners**.

### Key Benefits:
- **Zero Client API Quota Usage**: The mobile app never calls `football-data.org` directly.
- **Realtime Push Updates**: When a match score or minute changes in Firestore, connected clients update automatically via `.snapshots()`.
- **Instant Offline Support**: Firestore mobile SDK provides automatic offline persistence on iOS and Android.

---

## 2. Firestore Data Model Mapping

The live Firestore collections contain the following documents:

### 2.1 Collection: `matches/{matchId}`
```json
{
  "id": 555000,
  "competitionId": 2013,
  "competitionCode": "BSA",
  "competitionName": "Campeonato Brasileiro Série A",
  "competitionEmblem": "https://crests.football-data.org/bsa.png",
  "dateKey": "2026-09-12",
  "utcDate": "Timestamp (2026-09-12T19:00:00Z)",
  "status": "FINISHED",
  "minute": null,
  "matchday": 27,
  "stage": "REGULAR_SEASON",
  "group": null,
  "venue": null,
  "homeTeamId": 1766,
  "homeTeamName": "CA Mineiro",
  "homeTeamShortName": "Mineiro",
  "homeTeamCrest": "https://crests.football-data.org/1766.png",
  "homeScore": 3,
  "awayTeamId": 1765,
  "awayTeamName": "Fluminense FC",
  "awayTeamShortName": "Fluminense",
  "awayTeamCrest": "https://crests.football-data.org/1765.png",
  "awayScore": 1,
  "winner": "HOME_TEAM",
  "lastUpdated": "Timestamp (2026-09-12T23:59:07Z)"
}
```

👉 **Shared Model Update**:
Add `MatchModel.fromFirestore(Map<String, dynamic> data)` to `packages/shared`:
- Reconstructs `homeTeam` as `TeamBrief(...)`
- Reconstructs `awayTeam` as `TeamBrief(...)`
- Reconstructs `competition` as `CompetitionBrief(...)`
- Reconstructs `score` as `ScoreModel(...)`
- Safely handles `utcDate` as `Timestamp`, `DateTime`, or ISO8601 string.

---

### 2.2 Collection: `standings/{competitionCode}`
Document ID: e.g. `PL`, `BL1`, `PD`, `SA`, `FL1`, `BSA`
```json
{
  "competitionCode": "BL1",
  "lastUpdated": "Timestamp (...)",
  "standings": [
    {
      "stage": "REGULAR_SEASON",
      "type": "TOTAL",
      "group": "Matchday",
      "table": [
        {
          "position": 1,
          "team": { "id": 17, "name": "SC Freiburg", "shortName": "Freiburg", "crest": "..." },
          "playedGames": 3,
          "won": 3,
          "draw": 0,
          "lost": 0,
          "points": 9,
          "goalsFor": 10,
          "goalsAgainst": 1,
          "goalDifference": 9
        }
      ]
    }
  ]
}
```

👉 **Shared Model Compatibility**:
The inner `standings` array matches `StandingTable.fromJson` directly.

---

### 2.3 Collection: `competitions/{competitionId}`
Document ID: e.g. `2000`, `2021`
```json
{
  "id": 2000,
  "code": "WC",
  "name": "FIFA World Cup",
  "type": "CUP",
  "emblem": "https://crests.football-data.org/wm26.png",
  "lastUpdated": "Timestamp (...)"
}
```

👉 **Shared Model Compatibility**:
Matches `CompetitionBrief.fromJson` directly.

---

## 3. Architecture Transition

```
Before (Client-Side REST):
DioClient ──▶ HTTP GET /v4/matches (Polling every 60s) ──▶ FixturesProvider ──▶ UI

After (Realtime Firestore Push):
Cloud Functions ──▶ Firestore (matches, standings, comps)
                         │
                         ▼ Stream (.snapshots())
                   FixturesRepository
                         │
                         ▼
                   FixturesProvider (StreamSubscription)
                         │
                         ▼
                        UI (Instant auto-refresh on goal/status change)
```

---

## 4. Multi-Phase Implementation Plan

Following our working protocol:
- Each phase is executed in isolation.
- Code is validated with static analysis and automated tests.
- Changes are presented for verification and committed to git **before** advancing to the next phase.

### Phase 1: Update `packages/shared` with Firestore Deserializer
1. Add `MatchModel.fromFirestore(Map<String, dynamic> data)` to `packages/shared/lib/src/models/match_model.dart`.
2. Add comprehensive unit tests in `packages/shared/test/model_test.dart` to verify both raw API JSON and Firestore doc format.
3. **Verification**: `dart analyze` and `dart test` in `packages/shared`.
4. **Git Commit & Checkpoint**.

---

### Phase 2: Migrate `FixturesRepository` & `FixturesProvider` to Firestore
1. Update `FixturesRepository`:
   - Replace `DioClient` with `FirebaseFirestore`.
   - Implement `Stream<List<MatchModel>> watchMatchesByDate(DateTime date)`.
   - Query: `firestore.collection('matches').where('dateKey', isEqualTo: dateStr).snapshots()`.
   - Sort client-side by `utcDate` (eliminates mandatory composite index dependency).
2. Update `FixturesProvider`:
   - Replace the polling `Timer.periodic(60s)` with an active `StreamSubscription<List<MatchModel>>`.
   - Subscribes when `selectDate` is called.
   - Automatically calls `notifyListeners()` whenever Firestore pushes an updated match document.
3. **Verification**: `flutter analyze` + `flutter test`.
4. **Git Commit & Checkpoint**.

---

### Phase 3: Migrate `StandingsRepository` & `CompetitionsRepository` to Firestore
1. Update `StandingsRepository`:
   - Replace `DioClient` with `FirebaseFirestore`.
   - Implement `Stream<List<StandingTable>> watchStandings(String competitionCode)`.
   - Reads `firestore.collection('standings').doc(code.toUpperCase()).snapshots()`.
2. Update `CompetitionsRepository`:
   - Implement `Stream<List<MatchModel>> watchCompetitionMatches(String code)`.
   - Reads `firestore.collection('matches').where('competitionCode', isEqualTo: code).snapshots()`.
3. Update `StandingsProvider` and `CompetitionsProvider` to listen to the new Firestore streams.
4. **Verification**: `flutter analyze` + `flutter test`.
5. **Git Commit & Checkpoint**.

---

### Phase 4: Migrate `MatchDetailRepository` & Update Dependency Injection (`app.dart`)
1. Update `MatchDetailRepository`:
   - Replace `DioClient` with `FirebaseFirestore`.
   - Implement `Stream<MatchModel?> watchMatchDetail(int matchId)`.
   - Reads `firestore.collection('matches').doc(matchId.toString()).snapshots()`.
2. Update `MatchDetailProvider` to subscribe to the single match document stream.
3. Update `lib/app.dart`:
   - Replace `Provider<DioClient>` in `MultiProvider` with `FirebaseFirestore.instance`.
   - Update `ProxyProvider` definitions to inject `FirebaseFirestore` into all repositories.
4. **Verification**: `flutter analyze` + `flutter test` across all features.
5. **Git Commit & Checkpoint**.

---

### Phase 5: Verification, Cleanup & End-to-End Test
1. Run full repo static analysis (`flutter analyze` and `dart test`).
2. Run app test suite (`flutter test`).
3. Verify that the mobile app loads today's matches directly from Firestore without issuing external HTTP requests.
4. Final Review & Sign-off.
