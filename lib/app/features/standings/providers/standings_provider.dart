import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';
import '../data/standings_repository.dart';

class StandingsProvider extends ChangeNotifier {
  final StandingsRepository repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<StandingTable> _standings = [];
  StreamSubscription<List<StandingTable>>? _standingsSubscription;
  String? _currentCompetitionCode;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<StandingTable> get standings => _standings;

  StandingsProvider({required this.repository});

  void subscribeToStandings(String competitionCode) {
    if (_currentCompetitionCode == competitionCode && _standings.isNotEmpty) {
      return;
    }
    _currentCompetitionCode = competitionCode;
    _standingsSubscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _standingsSubscription = repository.watchStandings(competitionCode).listen(
      (data) {
        _standings = data;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> fetchStandings(String competitionCode) async {
    subscribeToStandings(competitionCode);
  }

  @override
  void dispose() {
    _standingsSubscription?.cancel();
    super.dispose();
  }
}
