import 'package:shared/shared.dart';
import 'package:test/test.dart';

void main() {
  group('Shared Models in Backend Services', () {
    test('MatchModel parses and serializes correctly', () {
      final json = {
        'id': 12345,
        'competition': {
          'id': 2021,
          'name': 'Premier League',
          'code': 'PL',
          'type': 'LEAGUE',
          'emblem': 'https://example.com/pl.png',
        },
        'utcDate': '2026-09-12T14:00:00Z',
        'status': 'IN_PLAY',
        'minute': 45,
        'matchday': 4,
        'stage': 'REGULAR_SEASON',
        'homeTeam': {
          'id': 61,
          'name': 'Chelsea FC',
          'shortName': 'Chelsea',
          'tla': 'CHE',
          'crest': 'https://example.com/chelsea.png',
        },
        'awayTeam': {
          'id': 64,
          'name': 'Liverpool FC',
          'shortName': 'Liverpool',
          'tla': 'LIV',
          'crest': 'https://example.com/liverpool.png',
        },
        'score': {
          'winner': null,
          'duration': 'REGULAR',
          'fullTime': {'home': 2, 'away': 1},
          'halfTime': {'home': 1, 'away': 0},
        },
      };

      final match = MatchModel.fromJson(json);
      expect(match.id, 12345);
      expect(match.competition.code, 'PL');
      expect(match.homeTeam.displayName, 'Chelsea');
      expect(match.awayTeam.displayName, 'Liverpool');
      expect(match.score.fullTime.home, 2);
      expect(match.score.fullTime.away, 1);
      expect(match.status, MatchStatus.inPlay);
      expect(match.status.isLive, true);

      final serialized = match.toJson();
      expect(serialized['id'], 12345);
      expect(serialized['status'], 'inPlay');
    });

    test('StandingTable parses and serializes correctly', () {
      final json = {
        'stage': 'REGULAR_SEASON',
        'type': 'TOTAL',
        'table': [
          {
            'position': 1,
            'team': {'id': 65, 'name': 'Manchester City', 'shortName': 'Man City'},
            'playedGames': 3,
            'won': 3,
            'draw': 0,
            'lost': 0,
            'points': 9,
            'goalsFor': 9,
            'goalsAgainst': 2,
            'goalDifference': 7,
          }
        ],
      };

      final table = StandingTable.fromJson(json);
      expect(table.stage, 'REGULAR_SEASON');
      expect(table.table.length, 1);
      expect(table.table.first.position, 1);
      expect(table.table.first.team.displayName, 'Man City');
      expect(table.table.first.points, 9);
    });
  });
}
