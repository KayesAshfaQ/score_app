import 'package:flutter/foundation.dart';
import '../data/standings_repository.dart';
import '../models/standing_model.dart';

class StandingsProvider extends ChangeNotifier {
  final StandingsRepository repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<StandingTable> _standings = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<StandingTable> get standings => _standings;

  StandingsProvider({required this.repository});

  Future<void> fetchStandings(String competitionCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _standings = await repository.getStandings(competitionCode);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
