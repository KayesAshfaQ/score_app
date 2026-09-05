class Season {
  final int? id;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? currentMatchday;
  final dynamic winner;

  Season({
    this.id,
    this.startDate,
    this.endDate,
    this.currentMatchday,
    this.winner,
  });
}
