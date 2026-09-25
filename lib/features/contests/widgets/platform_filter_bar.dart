import 'package:flutter/material.dart';

import '../../../app_scope.dart';
import 'platform_picker_sheet.dart';

/// Horizontal chip row showing the active platform filter.
class PlatformFilterBar extends StatelessWidget {
  const PlatformFilterBar({super.key, required this.selected});

  final Set<String> selected;

  Future<void> _edit(BuildContext context) async {
    final settings = AppScope.settingsOf(context);
    final result = await showPlatformPicker(
      context,
      platforms: settings.allPlatforms,
      selected: selected,
    );
    if (result != null) await settings.setSelectedPlatforms(result);
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.settingsOf(context);
    final sorted = selected.toList()..sort();

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          FilterChip(
            avatar: const Icon(Icons.tune_rounded, size: 18),
            label: Text(selected.isEmpty ? 'All platforms' : 'Platforms · ${selected.length}'),
            selected: selected.isNotEmpty,
            showCheckmark: false,
            onSelected: (_) => _edit(context),
            tooltip: 'Choose platforms',
          ),
          for (final platform in sorted) ...[
            const SizedBox(width: 8),
            InputChip(
              label: Text(platform),
              onDeleted: () => settings.setSelectedPlatforms(selected.difference({platform})),
              deleteButtonTooltipMessage: 'Remove $platform',
            ),
          ],
        ],
      ),
    );
  }
}
