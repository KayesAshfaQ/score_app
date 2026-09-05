enum CompetitionType { LEAGUE }

class Competition {
  final int? id;
  final String? name;
  final String? code;
  final CompetitionType? type;
  final String? emblem;

  Competition({this.id, this.name, this.code, this.type, this.emblem});
}
