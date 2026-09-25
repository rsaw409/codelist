import 'package:codelist/core/formatters.dart';
import 'package:codelist/data/contest.dart';
import 'package:codelist/features/contests/contest_sections.dart';
import 'package:flutter_test/flutter_test.dart';

Contest _contest(int id, String platform, DateTime start, Duration length) => Contest(
      id: id,
      duration: length.inSeconds,
      description: 'Contest $id',
      title: platform,
      link: 'https://example.com/$id',
      logoId: id,
      startDate: start,
      endDate: start.add(length),
    );

void main() {
  group('formatDuration', () {
    test('formats minutes, hours and days compactly', () {
      expect(formatDuration(const Duration(minutes: 45)), '45m');
      expect(formatDuration(const Duration(hours: 2)), '2h');
      expect(formatDuration(const Duration(hours: 2, minutes: 30)), '2h 30m');
      expect(formatDuration(const Duration(days: 3)), '3d');
      expect(formatDuration(const Duration(days: 3, hours: 4)), '3d 4h');
    });
  });

  group('formatDayHeader', () {
    final today = DateTime(2026, 9, 24, 15);
    test('uses relative names for the next few days', () {
      expect(formatDayHeader(DateTime(2026, 9, 24, 23), today), 'Today');
      expect(formatDayHeader(DateTime(2026, 9, 25, 1), today), 'Tomorrow');
      expect(formatDayHeader(DateTime(2026, 9, 27), today), 'Sunday');
      expect(formatDayHeader(DateTime(2026, 10, 5), today), 'Mon, 5 Oct');
    });
  });

  group('ContestSections', () {
    final now = DateTime.utc(2026, 9, 24, 12);
    final contests = [
      _contest(
          1, 'codeforces.com', now.subtract(const Duration(hours: 1)), const Duration(hours: 2)),
      _contest(2, 'atcoder.jp', now.add(const Duration(hours: 3)), const Duration(hours: 2)),
      _contest(3, 'codeforces.com', now.add(const Duration(days: 1)), const Duration(hours: 2)),
      _contest(4, 'leetcode.com', now.subtract(const Duration(hours: 3)), const Duration(hours: 1)),
    ];

    test('splits live and upcoming, drops ended, groups by day', () {
      final sections = ContestSections.from(contests, platforms: {}, now: now, useLocalTime: false);
      expect(sections.live.map((c) => c.id), [1]);
      expect(sections.upcoming.map((g) => g.contests.map((c) => c.id).toList()), [
        [2],
        [3],
      ]);
    });

    test('filters by selected platforms', () {
      final sections =
          ContestSections.from(contests, platforms: {'atcoder.jp'}, now: now, useLocalTime: false);
      expect(sections.live, isEmpty);
      expect(sections.upcoming.single.contests.single.id, 2);
    });
  });
}
