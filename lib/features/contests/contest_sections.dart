import '../../core/formatters.dart';
import '../../data/contest.dart';

typedef DayGroup = ({DateTime day, List<Contest> contests});

/// Contests split into what's running now and what's coming, grouped by day.
class ContestSections {
  const ContestSections({required this.live, required this.upcoming});

  factory ContestSections.from(
    Iterable<Contest> contests, {
    required Set<String> platforms,
    required DateTime now,
    required bool useLocalTime,
  }) {
    final visible = contests.where(
      (c) => !c.hasEnded(now) && (platforms.isEmpty || platforms.contains(c.title)),
    );

    final live = <Contest>[];
    final upcoming = <Contest>[];
    for (final contest in visible) {
      (contest.isLive(now) ? live : upcoming).add(contest);
    }
    live.sort((a, b) => a.endDate.compareTo(b.endDate));
    upcoming.sort((a, b) => a.startDate.compareTo(b.startDate));

    final groups = <DayGroup>[];
    for (final contest in upcoming) {
      final start = toDisplayZone(contest.startDate, local: useLocalTime);
      final day = DateTime(start.year, start.month, start.day);
      if (groups.isEmpty || groups.last.day != day) {
        groups.add((day: day, contests: [contest]));
      } else {
        groups.last.contests.add(contest);
      }
    }

    return ContestSections(live: live, upcoming: groups);
  }

  final List<Contest> live;
  final List<DayGroup> upcoming;

  bool get isEmpty => live.isEmpty && upcoming.isEmpty;
}
