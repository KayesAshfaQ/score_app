import 'package:shared/shared.dart';
import 'package:test/test.dart';

void main() {
  group('MatchModel Serialization & Deserialization', () {
    test('parses raw API JSON format', () {
      final rawApiJson = {
        'id': 12345,
        'competition': {
          'id': 2021,
          'name': 'Premier League',
          'code': 'PL',
          'emblem': 'https://crests.football-data.org/PL.png',
        },
        'utcDate': '2026-09-12T14:00:00Z',
        'status': 'IN_PLAY',
        'minute': 35,
        'matchday': 4,
        'homeTeam': {
          'id': 65,
          'name': 'Manchester City FC',
          'shortName': 'Man City',
          'crest': 'https://crests.football-data.org/65.png',
        },
        'awayTeam': {
          'id': 64,
          'name': 'Liverpool FC',
          'shortName': 'Liverpool',
          'crest': 'https://crests.football-data.org/64.png',
        },
        'score': {
          'winner': null,
          'duration': 'REGULAR',
          'fullTime': {'home': 2, 'away': 1},
          'halfTime': {'home': 1, 'away': 0},
        },
      };

      final match = MatchModel.fromJson(rawApiJson);
      expect(match.id, equals(12345));
      expect(match.competition.code, equals('PL'));
      expect(match.status, equals(MatchStatus.inPlay));
      expect(match.status.isLive, isTrue);
      expect(match.minute, equals(35));
      expect(match.homeTeam.displayName, equals('Man City'));
      expect(match.awayTeam.displayName, equals('Liverpool'));
      expect(match.score.displayScore(), equals('2 - 1'));
    });

    test('parses flattened Cloud Firestore document format', () {
      final firestoreDoc = {
        'id': 555000,
        'competitionId': 2013,
        'competitionCode': 'BSA',
        'competitionName': 'Campeonato Brasileiro Série A',
        'competitionEmblem': 'https://crests.football-data.org/bsa.png',
        'dateKey': '2026-09-12',
        'utcDate': '2026-09-12T19:00:00Z',
        'status': 'FINISHED',
        'minute': null,
        'matchday': 27,
        'stage': 'REGULAR_SEASON',
        'homeTeamId': 1766,
        'homeTeamName': 'CA Mineiro',
        'homeTeamShortName': 'Mineiro',
        'homeTeamCrest': 'https://crests.football-data.org/1766.png',
        'homeScore': 3,
        'awayTeamId': 1765,
        'awayTeamName': 'Fluminense FC',
        'awayTeamShortName': 'Fluminense',
        'awayTeamCrest': 'https://crests.football-data.org/1765.png',
        'awayScore': 1,
        'winner': 'HOME_TEAM',
      };

      final match = MatchModel.fromFirestore(firestoreDoc);
      expect(match.id, equals(555000));
      expect(match.competition.code, equals('BSA'));
      expect(match.competition.name, equals('Campeonato Brasileiro Série A'));
      expect(match.status, equals(MatchStatus.finished));
      expect(match.status.isFinished, isTrue);
      expect(match.homeTeam.displayName, equals('Mineiro'));
      expect(match.awayTeam.displayName, equals('Fluminense'));
      expect(match.score.displayScore(), equals('3 - 1'));
      expect(match.score.winner, equals('HOME_TEAM'));
    });
  });
}
