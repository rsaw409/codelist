import 'package:flutter/material.dart';

/// Searchable multi-select of platforms. Resolves to the new selection, or
/// null if dismissed.
Future<Set<String>?> showPlatformPicker(
  BuildContext context, {
  required List<String> platforms,
  required Set<String> selected,
}) {
  return showModalBottomSheet<Set<String>>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => _PlatformPickerSheet(platforms: platforms, initial: selected),
  );
}

class _PlatformPickerSheet extends StatefulWidget {
  const _PlatformPickerSheet({required this.platforms, required this.initial});

  final List<String> platforms;
  final Set<String> initial;

  @override
  State<_PlatformPickerSheet> createState() => _PlatformPickerSheetState();
}

class _PlatformPickerSheetState extends State<_PlatformPickerSheet> {
  late final Set<String> _selected = {...widget.initial};
  // Ordered once so rows don't jump while the user is ticking them.
  late final List<String> _ordered = [
    ...widget.platforms.where(widget.initial.contains),
    ...widget.platforms.where((p) => !widget.initial.contains(p)),
  ];
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _query.toLowerCase();
    final visible = _ordered.where((p) => p.toLowerCase().contains(query)).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 1,
      // Keep the apply button above the keyboard while searching.
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 12, 8),
              child: Row(
                children: [
                  Expanded(child: Text('Platforms', style: theme.textTheme.titleLarge)),
                  TextButton(
                    onPressed: _selected.isEmpty ? null : () => setState(_selected.clear),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchBar(
                hintText: 'Search ${widget.platforms.length} platforms',
                leading: const Icon(Icons.search_rounded),
                elevation: const WidgetStatePropertyAll(0),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: visible.isEmpty
                  ? Center(
                      child:
                          Text('No platforms match "$_query"', style: theme.textTheme.bodyMedium))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final platform = visible[index];
                        return CheckboxListTile(
                          value: _selected.contains(platform),
                          title: Text(platform),
                          controlAffinity: ListTileControlAffinity.trailing,
                          onChanged: (checked) => setState(() {
                            checked == true ? _selected.add(platform) : _selected.remove(platform);
                          }),
                        );
                      },
                    ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(_selected),
                    child: Text(_selected.isEmpty
                        ? 'Show all platforms'
                        : 'Show ${_selected.length} selected'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
