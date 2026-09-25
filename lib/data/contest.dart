import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'contest.g.dart';

@HiveType(typeId: 0)
class Contest extends HiveObject {
  Contest({
    required this.id,
    required this.duration,
    required this.description,
    required this.title,
    required this.link,
    required this.logoId,
    required this.startDate,
    required this.endDate,
  });

  factory Contest.fromJson(Map<String, dynamic> json) {
    final resource = json['resource'] as Map<String, dynamic>;
    return Contest(
      id: json['id'] as int,
      duration: json['duration'] as int,
      startDate: _parseUtc(json['start'] as String),
      endDate: _parseUtc(json['end'] as String),
      description: json['event'] as String,
      title: resource['name'] as String,
      link: json['href'] as String,
      logoId: resource['id'] as int,
    );
  }

  /// Contest id in clist.by.
  @HiveField(0)
  int id;

  /// Contest duration in seconds.
  @HiveField(1)
  int duration;

  /// Contest start, in UTC.
  @HiveField(2)
  DateTime startDate;

  /// Contest end, in UTC.
  @HiveField(3)
  DateTime endDate;

  /// Platform (resource) name, e.g. `codeforces.com`.
  @HiveField(4)
  String title;

  /// Link to the contest page.
  @HiveField(5)
  String link;

  /// Contest name, e.g. `Codeforces Round 900 (Div. 2)`.
  @HiveField(6)
  String description;

  /// Platform (resource) id in clist.by, also used as the logo cache key.
  @HiveField(7)
  int logoId;

  bool isLive(DateTime now) => !startDate.isAfter(now) && endDate.isAfter(now);

  bool hasEnded(DateTime now) => !endDate.isAfter(now);

  static DateTime _parseUtc(String value) =>
      DateFormat('yyyy-MM-dd HH:mm:ss').parse(value.replaceFirst('T', ' '), true);
}
