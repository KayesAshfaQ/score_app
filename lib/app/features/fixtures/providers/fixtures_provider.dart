import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';
import '../data/fixtures_repository.dart';

class FixturesProvider extends ChangeNotifier {
  final FixturesRepository repository;

  DateTime _selectedDate = DateTime.now();
  String? _selectedCompetitionCode; // null means "All"
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<MatchModel>>? _matchesSubscription;

  List<MatchModel> _allMatches = [];
  Map<CompetitionBrief, List<MatchModel>> _groupedMatches = {};

  DateTime get selectedDate => _selectedDate;
  String? get selectedCompetitionCode => _selectedCompetitionCode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MatchModel> get allMatches => _allMatches;
  Map<CompetitionBrief, List<MatchModel>> get groupedMatches => _groupedMatches;

  bool get hasLiveMatches => _allMatches.any((m) => m.status.isLive);

  FixturesProvider({required this.repository}) {
    subscribeToMatches();
  }

  void subscribeToMatches() {
    _matchesSubscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _matchesSubscription = repository.watchMatchesByDate(_selectedDate).listen(
      (matches) {
        _allMatches = matches;
        _isLoading = false;
        _errorMessage = null;
        _updateGroupedMatches();
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> fetchMatches({bool forceRefresh = false}) async {
    // Re-subscribe or fetch fresh snapshot
    subscribeToMatches();
  }

  void selectDate(DateTime date) {
    if (_isSameDay(_selectedDate, date)) return;
    _selectedDate = date;
    subscribeToMatches();
  }

  void selectCompetition(String? code) {
    if (_selectedCompetitionCode == code) {
      _selectedCompetitionCode = null; // Toggle off if selected again
    } else {
      _selectedCompetitionCode = code;
    }
    _updateGroupedMatches();
    notifyListeners();
  }

  void _updateGroupedMatches() {
    final filtered = _selectedCompetitionCode == null
        ? _allMatches
        : _allMatches
            .where((m) => m.competition.code == _selectedCompetitionCode)
            .toList();

    final Map<CompetitionBrief, List<MatchModel>> grouped = {};
    for (final match in filtered) {
      final comp = match.competition;
      if (!grouped.containsKey(comp)) {
        grouped[comp] = [];
      }
      grouped[comp]!.add(match);
    }
    _groupedMatches = grouped;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void dispose() {
    _matchesSubscription?.cancel();
    super.dispose();
  }
}
