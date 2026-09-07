import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/fixtures_repository.dart';
import '../models/competition_brief.dart';
import '../models/match_model.dart';

class FixturesProvider extends ChangeNotifier {
  final FixturesRepository repository;

  DateTime _selectedDate = DateTime.now();
  String? _selectedCompetitionCode; // null means "All"
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _autoRefreshTimer;

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
    fetchMatches();
  }

  Future<void> fetchMatches({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allMatches = await repository.getMatchesByDate(
        _selectedDate,
        forceRefresh: forceRefresh,
      );
      _updateGroupedMatches();
      _setupAutoRefreshTimer();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectDate(DateTime date) {
    if (_isSameDay(_selectedDate, date)) return;
    _selectedDate = date;
    fetchMatches();
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

  void _setupAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    // Only auto-refresh if looking at today and there are live matches
    if (_isSameDay(_selectedDate, DateTime.now()) && hasLiveMatches) {
      _autoRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
        fetchMatches(forceRefresh: true);
      });
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
