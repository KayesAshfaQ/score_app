import 'package:intl/intl.dart';
import 'package:shared/shared.dart';
import '../../../core/networks/dio_client.dart';

class FixturesRepository {
  final DioClient dioClient;

  // Simple in-memory cache to stay strictly within 10 req/min limit
  final Map<String, List<MatchModel>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  FixturesRepository({required this.dioClient});

  Future<List<MatchModel>> getMatchesByDate(
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    // Cache check: 60s TTL for today/live dates, 10 min for past/future dates
    final isToday = _isSameDay(date, DateTime.now());
    final ttl = isToday
        ? const Duration(seconds: 60)
        : const Duration(minutes: 10);

    if (!forceRefresh &&
        _cache.containsKey(dateStr) &&
        _cacheTimestamps.containsKey(dateStr)) {
      final cachedAt = _cacheTimestamps[dateStr]!;
      if (DateTime.now().difference(cachedAt) < ttl) {
        return _cache[dateStr]!;
      }
    }

    // Call API: GET /v4/matches?date=YYYY-MM-DD
    final data = await dioClient.get(
      '/matches',
      queryParameters: {'date': dateStr},
    );

    final matchesList =
        (data['matches'] as List<dynamic>?)
            ?.map((json) => MatchModel.fromJson(json as Map<String, dynamic>))
            .toList() ??
        [];

    // Store in cache
    _cache[dateStr] = matchesList;
    _cacheTimestamps[dateStr] = DateTime.now();

    return matchesList;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
