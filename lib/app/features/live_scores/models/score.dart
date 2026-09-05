enum Duration { REGULAR }

enum Winner { AWAY_TEAM, DRAW, HOME_TEAM }

class Score {
  final Winner? winner;
  final Duration? duration;
  final Time? fullTime;
  final Time? halfTime;

  Score({this.winner, this.duration, this.fullTime, this.halfTime});
}

class Time {
  final int? home;
  final int? away;

  Time({this.home, this.away});
}
