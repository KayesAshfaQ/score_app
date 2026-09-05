import 'package:score_app/app/features/live_scores/models/team.dart';

import 'competition.dart';
import 'filters.dart';
import 'score.dart';
import 'season.dart';

class Match {
  final Filters? filters;
  final ResultSet? resultSet;
  final List<MatchElement>? matches;

  Match({this.filters, this.resultSet, this.matches});
}

enum Stage { REGULAR_SEASON }

enum Status { FINISHED, IN_PLAY, TIMED }

class MatchElement {
  final Area? area;
  final Competition? competition;
  final Season? season;
  final int? id;
  final DateTime? utcDate;
  final Status? status;
  final int? matchday;
  final Stage? stage;
  final dynamic group;
  final DateTime? lastUpdated;
  final Team? homeTeam;
  final Team? awayTeam;
  final Score? score;
  final String? odds;
  final List<String>? referees;

  MatchElement({
    this.area,
    this.competition,
    this.season,
    this.id,
    this.utcDate,
    this.status,
    this.matchday,
    this.stage,
    this.group,
    this.lastUpdated,
    this.homeTeam,
    this.awayTeam,
    this.score,
    this.odds,
    this.referees,
  });
}

class Area {
  final int? id;
  final String? name;
  final String? code;
  final String? flag;

  Area({this.id, this.name, this.code, this.flag});
}

/* class Odds {
  final Msg? msg;

  Odds({this.msg});
}

enum Msg { ACTIVATE_ODDS_PACKAGE_IN_USER_PANEL_TO_RETRIEVE_ODDS } */

/* class Referee {
  final int? id;
  final String? name;
  final RefereeType? type;
  final String? nationality;

  Referee({this.id, this.name, this.type, this.nationality});
}

enum RefereeType { REFEREE } */

class ResultSet {
  final int? count;
  final String? competitions;
  final DateTime? first;
  final DateTime? last;
  final int? played;

  ResultSet({
    this.count,
    this.competitions,
    this.first,
    this.last,
    this.played,
  });
}
