import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../app_scope.dart';
import '../../core/formatters.dart';
import '../../data/contest.dart';
import '../../data/contest_repository.dart';
import '../../data/settings_store.dart';
import '../settings/settings_sheet.dart';
import 'contest_sections.dart';
import 'widgets/contest_card.dart';
import 'widgets/platform_filter_bar.dart';
import 'widgets/state_views.dart';

class ContestsPage extends StatefulWidget {
  const ContestsPage({super.key});

  @override
  State<ContestsPage> createState() => _ContestsPageState();
}

class _ContestsPageState extends State<ContestsPage> {
  late final ContestRepository _repository = AppScope.repositoryOf(context);
  late final Listenable _dataChanges = Listenable.merge([
    _repository.contests.listenable(),
    _repository.settings.box.listenable(keys: SettingsStore.listKeys),
  ]);

  // Ticks every minute so "live" badges and countdowns stay current.
  late final Timer _clock;
  DateTime _now = DateTime.now().toUtc();

  bool _refreshing = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _now = DateTime.now().toUtc());
    });
    if (!_repository.hasData || _repository.isStale) {
      // Cached data is still usable, so a background refresh fails quietly.
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh(silent: _repository.hasData));
    }
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  Future<void> _refresh({bool silent = false}) async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      await _repository.refresh();
      _error = null;
    } catch (e) {
      if (!mounted) return;
      if (_repository.hasData) {
        if (silent) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$e'),
          action: SnackBarAction(label: 'Retry', onPressed: _refresh),
        ));
      } else {
        _error = e;
      }
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
          _now = DateTime.now().toUtc();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _dataChanges,
        builder: (context, _) {
          if (!_repository.hasData) return _buildFirstRun();

          final settings = _repository.settings;
          final selected = settings.selectedPlatforms;
          final sections = ContestSections.from(
            _repository.contests.values,
            platforms: selected,
            now: _now,
            useLocalTime: settings.useLocalTime,
          );

          return RefreshIndicator(
            onRefresh: _refresh,
            edgeOffset: 112 + MediaQuery.paddingOf(context).top,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _AppBar(refreshing: _refreshing, onRefresh: _refresh),
                SliverToBoxAdapter(child: PlatformFilterBar(selected: selected)),
                SliverToBoxAdapter(
                  child: _Caption(
                    '${formatUpdatedAgo(settings.lastRefresh, DateTime.now())}'
                    ' · ${settings.useLocalTime ? 'Local time' : 'UTC'}',
                  ),
                ),
                if (sections.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: MessageView(
                      icon: const Icon(Icons.event_busy_rounded),
                      title: 'No upcoming contests',
                      message: selected.isEmpty
                          ? 'Pull down to check for new contests.'
                          : 'Nothing scheduled on your selected platforms.',
                      action: selected.isEmpty
                          ? null
                          : FilledButton.tonal(
                              onPressed: () => settings.setSelectedPlatforms(const []),
                              child: const Text('Show all platforms'),
                            ),
                    ),
                  )
                else ...[
                  if (sections.live.isNotEmpty) ...[
                    _SectionHeader(title: 'Live now', count: sections.live.length),
                    _ContestList(sections.live, now: _now, useLocalTime: settings.useLocalTime),
                  ],
                  for (final group in sections.upcoming) ...[
                    _SectionHeader(
                      title: formatDayHeader(
                          group.day, toDisplayZone(_now, local: settings.useLocalTime)),
                      count: group.contests.length,
                    ),
                    _ContestList(group.contests, now: _now, useLocalTime: settings.useLocalTime),
                  ],
                ],
                SliverToBoxAdapter(
                    child: SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFirstRun() {
    final error = _error;
    if (error == null) {
      return const MessageView(
        icon: SizedBox.square(dimension: 36, child: CircularProgressIndicator(strokeWidth: 3)),
        title: 'Fetching contests',
        message: 'Gathering events from 70+ platforms.\nThis only takes long the first time.',
      );
    }
    return MessageView(
      icon: const Icon(Icons.cloud_off_rounded),
      title: "Couldn't load contests",
      message: '$error',
      action: FilledButton.icon(
        onPressed: _refresh,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Try again'),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.refreshing, required this.onRefresh});

  final bool refreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.medium(
      pinned: true,
      title: const Text('Contests'),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: refreshing ? null : onRefresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
        IconButton(
          tooltip: 'Settings',
          onPressed: () => showSettingsSheet(context),
          icon: const Icon(Icons.settings_outlined),
        ),
        IconButton(
          tooltip: 'About',
          onPressed: () => showAppAboutDialog(context),
          icon: const Icon(Icons.info_outline_rounded),
        ),
        const SizedBox(width: 4),
      ],
      bottom: refreshing
          ? const PreferredSize(preferredSize: Size.fromHeight(4), child: LinearProgressIndicator())
          : null,
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Semantics(
        header: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            children: [
              Text(title,
                  style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContestList extends StatelessWidget {
  const _ContestList(this.contests, {required this.now, required this.useLocalTime});

  final List<Contest> contests;
  final DateTime now;
  final bool useLocalTime;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.separated(
        itemCount: contests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => ContestCard(
          key: ValueKey(contests[index].id),
          contest: contests[index],
          now: now,
          useLocalTime: useLocalTime,
        ),
      ),
    );
  }
}
