import 'dart:convert';
import 'package:firebase_functions/firebase_functions.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';
import 'package:functions/config.dart';
import 'package:functions/services/firestore_sync.dart';
import 'package:functions/services/football_api.dart';

void main(List<String> args) {
  final apiService = FootballApiService();

  runFunctions((firebase) {
    // 1. Health check endpoint
    firebase.https.onRequest(
      name: 'healthCheck',
      (request) async {
        return Response.ok(
          jsonEncode({
            'status': 'healthy',
            'runtime': 'Dart AOT',
            'timestamp': DateTime.now().toUtc().toIso8601String(),
          }),
          headers: {'content-type': 'application/json'},
        );
      },
    );

    // 2. Sync Live Matches (typically scheduled every 1 min)
    firebase.https.onRequest(
      name: 'syncLiveMatches',
      (request) async {
        if (!_isAuthorized(request)) {
          return Response.forbidden(
            jsonEncode({'error': 'Unauthorized: invalid or missing x-sync-token'}),
            headers: {'content-type': 'application/json'},
          );
        }

        try {
          final firestore = firebase.adminApp.firestore();
          final syncService = FirestoreSyncService(firestore: firestore);

          // Support optional ?date=YYYY-MM-DD parameter, default to today UTC
          final dateStr = request.url.queryParameters['date'] ??
              DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());

          final matches = await apiService.fetchMatchesByDate(dateStr);
          final written = await syncService.upsertMatches(matches);

          return Response.ok(
            jsonEncode({
              'success': true,
              'date': dateStr,
              'matchesFetched': matches.length,
              'matchesWritten': written,
              'timestamp': DateTime.now().toUtc().toIso8601String(),
            }),
            headers: {'content-type': 'application/json'},
          );
        } catch (e, st) {
          print('[syncLiveMatches] Error: $e\n$st');
          return Response.internalServerError(
            body: jsonEncode({'error': e.toString()}),
            headers: {'content-type': 'application/json'},
          );
        }
      },
    );

    // 3. Sync Tomorrow Matches (pre-populates tomorrow's fixtures)
    firebase.https.onRequest(
      name: 'syncTomorrowMatches',
      (request) async {
        if (!_isAuthorized(request)) {
          return Response.forbidden(
            jsonEncode({'error': 'Unauthorized: invalid or missing x-sync-token'}),
            headers: {'content-type': 'application/json'},
          );
        }

        try {
          final firestore = firebase.adminApp.firestore();
          final syncService = FirestoreSyncService(firestore: firestore);

          final tomorrow = DateTime.now().toUtc().add(const Duration(days: 1));
          final dateStr = DateFormat('yyyy-MM-dd').format(tomorrow);

          final matches = await apiService.fetchMatchesByDate(dateStr);
          final written = await syncService.upsertMatches(matches);

          return Response.ok(
            jsonEncode({
              'success': true,
              'date': dateStr,
              'matchesFetched': matches.length,
              'matchesWritten': written,
              'timestamp': DateTime.now().toUtc().toIso8601String(),
            }),
            headers: {'content-type': 'application/json'},
          );
        } catch (e, st) {
          print('[syncTomorrowMatches] Error: $e\n$st');
          return Response.internalServerError(
            body: jsonEncode({'error': e.toString()}),
            headers: {'content-type': 'application/json'},
          );
        }
      },
    );

    // 4. Sync Standings & Competitions (12-hour scheduled task)
    firebase.https.onRequest(
      name: 'sync12hStandings',
      (request) async {
        if (!_isAuthorized(request)) {
          return Response.forbidden(
            jsonEncode({'error': 'Unauthorized: invalid or missing x-sync-token'}),
            headers: {'content-type': 'application/json'},
          );
        }

        try {
          final firestore = firebase.adminApp.firestore();
          final syncService = FirestoreSyncService(firestore: firestore);

          // 1. Sync metadata for available competitions
          final competitions = await apiService.fetchCompetitions();
          final compsWritten =
              await syncService.upsertCompetitions(competitions);

          // 2. Sync standings tables for free tier leagues with rate limit pacing (≤ 10 req/min)
          int totalStandingsWritten = 0;
          for (final code in CompetitionConstants.freeCompetitionCodes) {
            try {
              final standings = await apiService.fetchCompetitionStandings(code);
              if (standings.isNotEmpty) {
                totalStandingsWritten +=
                    await syncService.upsertStandings(code, standings);
              }
            } catch (err) {
              print('[sync12hStandings] Notice on $code: $err');
            }
            // 6-second delay between leagues to strictly stay under 10 req/min
            await Future.delayed(const Duration(seconds: 6));
          }

          return Response.ok(
            jsonEncode({
              'success': true,
              'competitionsWritten': compsWritten,
              'standingsWritten': totalStandingsWritten,
              'timestamp': DateTime.now().toUtc().toIso8601String(),
            }),
            headers: {'content-type': 'application/json'},
          );
        } catch (e, st) {
          print('[sync12hStandings] Error: $e\n$st');
          return Response.internalServerError(
            body: jsonEncode({'error': e.toString()}),
            headers: {'content-type': 'application/json'},
          );
        }
      },
    );
  });
}

bool _isAuthorized(Request request) {
  final token = request.headers['x-sync-token'];
  return token == FunctionsConfig.syncAuthToken;
}
