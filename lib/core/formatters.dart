import 'package:intl/intl.dart';

/// Converts a UTC instant to the zone the user chose to view times in.
DateTime toDisplayZone(DateTime utc, {required bool local}) => local ? utc.toLocal() : utc.toUtc();

String formatTime(DateTime time) => DateFormat('h:mm a').format(time);

String formatDateTime(DateTime time) => DateFormat('EEE, d MMM · h:mm a').format(time);

/// Compact duration such as `45m`, `2h 30m` or `3d 4h`.
String formatDuration(Duration duration) {
  final days = duration.inDays;
  final hours = duration.inHours % 24;
  final minutes = duration.inMinutes % 60;

  if (days > 0) return hours == 0 ? '${days}d' : '${days}d ${hours}h';
  if (duration.inHours > 0) return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
  return '${minutes}m';
}

/// Section label for a contest's start day, relative to [today].
String formatDayHeader(DateTime day, DateTime today) {
  final date = DateTime(day.year, day.month, day.day);
  final base = DateTime(today.year, today.month, today.day);
  return switch (date.difference(base).inDays) {
    0 => 'Today',
    1 => 'Tomorrow',
    < 7 && > 1 => DateFormat('EEEE').format(date),
    _ => DateFormat('EEE, d MMM').format(date),
  };
}

/// Short relative label, e.g. `Updated 5m ago`.
String formatUpdatedAgo(DateTime? last, DateTime now) {
  if (last == null) return 'Not updated yet';
  final diff = now.difference(last);
  if (diff.inMinutes < 1) return 'Updated just now';
  return 'Updated ${formatDuration(diff).split(' ').first} ago';
}
