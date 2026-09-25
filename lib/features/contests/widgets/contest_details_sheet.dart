import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';

import '../../../core/formatters.dart';
import '../../../core/launcher.dart';
import '../../../data/contest.dart';
import 'platform_avatar.dart';

Future<void> showContestDetails(
  BuildContext context, {
  required Contest contest,
  required bool useLocalTime,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => _ContestDetailsSheet(contest: contest, useLocalTime: useLocalTime),
  );
}

class _ContestDetailsSheet extends StatelessWidget {
  const _ContestDetailsSheet({required this.contest, required this.useLocalTime});

  final Contest contest;
  final bool useLocalTime;

  String _format(DateTime utc) =>
      '${formatDateTime(toDisplayZone(utc, local: useLocalTime))}${useLocalTime ? '' : ' UTC'}';

  Future<void> _openWebsite(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final uri = Uri.tryParse(contest.link);
    final opened = uri != null && await tryLaunchExternal(uri);
    if (!opened) {
      messenger.showSnackBar(const SnackBar(content: Text("Couldn't open the contest page")));
      return;
    }
    navigator.pop();
  }

  Future<void> _addToCalendar(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final added = await Add2Calendar.addEvent2Cal(Event(
      title: contest.description,
      description: '${contest.description}\n${contest.link}',
      location: contest.title,
      startDate: contest.startDate.toLocal(),
      endDate: contest.endDate.toLocal(),
    ));
    if (!added) {
      messenger.showSnackBar(const SnackBar(content: Text('No calendar app available')));
      return;
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      // Modal sheets extend under the navigation bar; keep actions clear of it.
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PlatformAvatar(platformId: contest.logoId, name: contest.title, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  contest.title,
                  style: theme.textTheme.titleSmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(contest.description, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 20),
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _InfoRow(
                    icon: Icons.play_circle_outline_rounded,
                    label: 'Starts',
                    value: _format(contest.startDate)),
                _InfoRow(icon: Icons.flag_outlined, label: 'Ends', value: _format(contest.endDate)),
                _InfoRow(
                  icon: Icons.timelapse_rounded,
                  label: 'Duration',
                  value: formatDuration(Duration(seconds: contest.duration)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => _addToCalendar(context),
                  icon: const Icon(Icons.event_available_rounded),
                  label: const Text('Add to calendar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openWebsite(context),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Open'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label, style: theme.textTheme.labelMedium),
        subtitle: Text(value, style: theme.textTheme.bodyLarge),
      ),
    );
  }
}
