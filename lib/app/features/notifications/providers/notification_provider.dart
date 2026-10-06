import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/notifications/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService.instance;

  static const String _keyMatches = 'notif_subscribed_matches';
  static const String _keyCompetitions = 'notif_subscribed_competitions';
  static const String _keyAllGoals = 'notif_all_goals_enabled';

  final Set<int> _subscribedMatchIds = {};
  final Set<String> _subscribedCompetitionCodes = {};
  bool _allGoalsEnabled = false;
  bool _isLoaded = false;

  Set<int> get subscribedMatchIds => Set.unmodifiable(_subscribedMatchIds);
  Set<String> get subscribedCompetitionCodes =>
      Set.unmodifiable(_subscribedCompetitionCodes);
  bool get allGoalsEnabled => _allGoalsEnabled;
  bool get isLoaded => _isLoaded;

  /// Check if notifications are enabled for a specific match
  bool isMatchSubscribed(int matchId) => _subscribedMatchIds.contains(matchId);

  /// Check if notifications are enabled for a competition
  bool isCompetitionSubscribed(String code) =>
      _subscribedCompetitionCodes.contains(code.toUpperCase());

  /// Load persisted subscription preferences on app startup
  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final matchesList = prefs.getStringList(_keyMatches) ?? [];
      _subscribedMatchIds.clear();
      for (final idStr in matchesList) {
        final id = int.tryParse(idStr);
        if (id != null) _subscribedMatchIds.add(id);
      }

      final compList = prefs.getStringList(_keyCompetitions) ?? [];
      _subscribedCompetitionCodes.clear();
      _subscribedCompetitionCodes.addAll(compList.map((e) => e.toUpperCase()));

      _allGoalsEnabled = prefs.getBool(_keyAllGoals) ?? false;
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[NotificationProvider] Failed to load preferences: $e');
    }
  }

  /// Toggle alerts for an individual match
  Future<bool> toggleMatchSubscription(int matchId) async {
    final willSubscribe = !_subscribedMatchIds.contains(matchId);

    if (willSubscribe) {
      _subscribedMatchIds.add(matchId);
      await _service.subscribeToMatch(matchId);
    } else {
      _subscribedMatchIds.remove(matchId);
      await _service.unsubscribeFromMatch(matchId);
    }

    notifyListeners();
    await _saveMatches();
    return willSubscribe;
  }

  /// Toggle alerts for an entire competition
  Future<bool> toggleCompetitionSubscription(String code) async {
    final upper = code.toUpperCase();
    final willSubscribe = !_subscribedCompetitionCodes.contains(upper);

    if (willSubscribe) {
      _subscribedCompetitionCodes.add(upper);
      await _service.subscribeToCompetition(upper);
    } else {
      _subscribedCompetitionCodes.remove(upper);
      await _service.unsubscribeFromCompetition(upper);
    }

    notifyListeners();
    await _saveCompetitions();
    return willSubscribe;
  }

  /// Toggle global live goals broadcast channel
  Future<bool> toggleAllGoals() async {
    _allGoalsEnabled = !_allGoalsEnabled;

    if (_allGoalsEnabled) {
      await _service.subscribeToLiveGoals();
    } else {
      await _service.unsubscribeFromLiveGoals();
    }

    notifyListeners();
    await _saveAllGoals();
    return _allGoalsEnabled;
  }

  Future<void> _saveMatches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _keyMatches,
        _subscribedMatchIds.map((id) => id.toString()).toList(),
      );
    } catch (e) {
      debugPrint('[NotificationProvider] Failed to save match subscriptions: $e');
    }
  }

  Future<void> _saveCompetitions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _keyCompetitions,
        _subscribedCompetitionCodes.toList(),
      );
    } catch (e) {
      debugPrint('[NotificationProvider] Failed to save comp subscriptions: $e');
    }
  }

  Future<void> _saveAllGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyAllGoals, _allGoalsEnabled);
    } catch (e) {
      debugPrint('[NotificationProvider] Failed to save all-goals preference: $e');
    }
  }
}
