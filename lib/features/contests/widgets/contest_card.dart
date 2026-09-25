import 'package:flutter/material.dart';

import '../../../core/formatters.dart';
import '../../../data/contest.dart';
import 'contest_details_sheet.dart';
import 'platform_avatar.dart';

class ContestCard extends StatelessWidget {
  const ContestCard({
    super.key,
    required this.contest,
    required this.now,
    required this.useLocalTime,
  });

  final Contest contest;
  final DateTime now;
  final bool useLocalTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final live = contest.isLive(now);

    void openDetails() => showContestDetails(context, contest: contest, useLocalTime: useLocalTime);

    return Card(
      child: InkWell(
        onTap: openDetails,
        onLongPress: openDetails,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PlatformAvatar(platformId: contest.logoId, name: contest.title),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contest.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          contest.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600, height: 1.25),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ContestStatusBadge(contest: contest, now: now),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _Meta(
                    icon: live ? Icons.flag_outlined : Icons.schedule_rounded,
                    label: live ? 'Ends ${_endLabel()}' : _timeRange(),
                  ),
                  _Meta(
                    icon: Icons.timelapse_rounded,
                    label: formatDuration(Duration(seconds: contest.duration)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _zone => useLocalTime ? '' : ' UTC';

  String _endLabel() {
    final end = toDisplayZone(contest.endDate, local: useLocalTime);
    final today = toDisplayZone(now, local: useLocalTime);
    final sameDay = end.year == today.year && end.month == today.month && end.day == today.day;
    return '${sameDay ? formatTime(end) : formatDateTime(end)}$_zone';
  }

  String _timeRange() {
    final start = toDisplayZone(contest.startDate, local: useLocalTime);
    final end = toDisplayZone(contest.endDate, local: useLocalTime);
    final sameDay = start.year == end.year && start.month == end.month && start.day == end.day;
    return '${formatTime(start)} – ${sameDay ? formatTime(end) : formatDateTime(end)}$_zone';
  }
}

/// "Live" or a countdown to the start. Always textual, never color alone.
class ContestStatusBadge extends StatelessWidget {
  const ContestStatusBadge({super.key, required this.contest, required this.now});

  final Contest contest;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final live = contest.isLive(now);
    final (bg, fg) = live
        ? (scheme.errorContainer, scheme.onErrorContainer)
        : (scheme.secondaryContainer, scheme.onSecondaryContainer);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (live) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            live
                ? 'LIVE'
                : 'in ${formatDuration(contest.startDate.difference(now)).split(' ').first}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  letterSpacing: live ? 0.8 : null,
                ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}
