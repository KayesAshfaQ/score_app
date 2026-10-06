import 'package:google_cloud_firestore/google_cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

class FirestoreSyncService {
  final Firestore firestore;

  FirestoreSyncService({required this.firestore});

  /// Batch upserts matches into the `matches` collection.
  Future<int> upsertMatches(List<MatchModel> matches) async {
    if (matches.isEmpty) return 0;

    final batch = firestore.batch();
    int count = 0;

    for (final match in matches) {
      final docRef = firestore.collection('matches').doc(match.id.toString());
      final dateKey = DateFormat('yyyy-MM-dd').format(match.utcDate);

      final docData = <String, dynamic>{
        'id': match.id,
        'competitionId': match.competition.id,
        'competitionCode': match.competition.code,
        'competitionName': match.competition.name,
        'competitionEmblem': match.competition.emblem,
        'dateKey': dateKey,
        'utcDate': Timestamp.fromDate(match.utcDate),
        'status': match.status.name.toUpperCase(),
        'minute': match.minute,
        'matchday': match.matchday,
        'stage': match.stage,
        'group': match.group,
        'venue': match.venue,
        'homeTeamId': match.homeTeam.id,
        'homeTeamName': match.homeTeam.name,
        'homeTeamShortName': match.homeTeam.shortName,
        'homeTeamCrest': match.homeTeam.crest,
        'homeScore': match.score.fullTime.home,
        'awayTeamId': match.awayTeam.id,
        'awayTeamName': match.awayTeam.name,
        'awayTeamShortName': match.awayTeam.shortName,
        'awayTeamCrest': match.awayTeam.crest,
        'awayScore': match.score.fullTime.away,
        'winner': match.score.winner,
        'lastUpdated': Timestamp.now(),
      };

      batch.set(docRef, docData, options: const SetOptions.merge());
      count++;
    }

    await batch.commit();
    return count;
  }

  /// Upserts competition standings into `standings/{competitionCode}`.
  Future<int> upsertStandings(
      String competitionCode, List<StandingTable> standings) async {
    final docRef =
        firestore.collection('standings').doc(competitionCode.toUpperCase());

    final docData = <String, dynamic>{
      'competitionCode': competitionCode.toUpperCase(),
      'standings': standings.map((s) => s.toJson()).toList(),
      'lastUpdated': Timestamp.now(),
    };

    await docRef.set(docData, options: const SetOptions.merge());
    return standings.length;
  }

  /// Batch upserts competitions into `competitions/{id}`.
  Future<int> upsertCompetitions(List<CompetitionBrief> competitions) async {
    if (competitions.isEmpty) return 0;

    final batch = firestore.batch();
    int count = 0;

    for (final comp in competitions) {
      final docRef = firestore.collection('competitions').doc(comp.id.toString());
      final docData = <String, dynamic>{
        'id': comp.id,
        'name': comp.name,
        'code': comp.code,
        'type': comp.type,
        'emblem': comp.emblem,
        'lastUpdated': Timestamp.now(),
      };

      batch.set(docRef, docData, options: const SetOptions.merge());
      count++;
    }

    await batch.commit();
    return count;
  }
}
