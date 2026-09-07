import 'competition_brief.dart';
import 'score_model.dart';
import 'team_brief.dart';

enum MatchStatus {
  scheduled,
  timed,
  inPlay,
  paused,
  extraTime,
  penaltyShootout,
  finished,
  suspended,
  postponed,
  cancelled;

  static MatchStatus fromString(String? statusStr) {
    switch (statusStr?.toUpperCase()) {
      case 'IN_PLAY':
        return MatchStatus.inPlay;
      case 'PAUSED':
        return MatchStatus.paused;
      case 'EXTRA_TIME':
        return MatchStatus.extraTime;
      case 'PENALTY_SHOOTOUT':
        return MatchStatus.penaltyShootout;
      case 'FINISHED':
        return MatchStatus.finished;
      case 'TIMED':
        return MatchStatus.timed;
      case 'POSTPONED':
        return MatchStatus.postponed;
      case 'SUSPENDED':
        return MatchStatus.suspended;
      case 'CANCELLED':
        return MatchStatus.cancelled;
      default:
        return MatchStatus.scheduled;
    }
  }

  bool get isLive =>
      this == MatchStatus.inPlay ||
      this == MatchStatus.paused ||
      this == MatchStatus.extraTime ||
      this == MatchStatus.penaltyShootout;

  bool get isFinished => this == MatchStatus.finished;
}

class MatchModel {
  final int id;
  final CompetitionBrief competition;
  final DateTime utcDate;
  final MatchStatus status;
  final int? minute;
  final int? matchday;
  final String? stage;
  final String? group;
  final String? venue;
  final TeamBrief homeTeam;
  final TeamBrief awayTeam;
  final ScoreModel score;

  MatchModel({
    required this.id,
    required this.competition,
    required this.utcDate,
    required this.status,
    this.minute,
    this.matchday,
    this.stage,
    this.group,
    this.venue,
    required this.homeTeam,
    required this.awayTeam,
    required this.score,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as int? ?? 0,
      competition: CompetitionBrief.fromJson(
        json['competition'] as Map<String, dynamic>? ?? {},
      ),
      utcDate: DateTime.parse(json['utcDate'] as String? ?? DateTime.now().toIso8601String()),
      status: MatchStatus.fromString(json['status'] as String?),
      minute: json['minute'] as int?,
      matchday: json['matchday'] as int?,
      stage: json['stage'] as String?,
      group: json['group'] as String?,
      venue: json['venue'] as String?,
      homeTeam: TeamBrief.fromJson(json['homeTeam'] as Map<String, dynamic>? ?? {}),
      awayTeam: TeamBrief.fromJson(json['awayTeam'] as Map<String, dynamic>? ?? {}),
      score: ScoreModel.fromJson(json['score'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'competition': competition.toJson(),
        'utcDate': utcDate.toIso8601String(),
        'status': status.name,
        'minute': minute,
        'matchday': matchday,
        'stage': stage,
        'group': group,
        'venue': venue,
        'homeTeam': homeTeam.toJson(),
        'awayTeam': awayTeam.toJson(),
        'score': score.toJson(),
      };
}
