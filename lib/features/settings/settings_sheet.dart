import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../app_scope.dart';
import '../../core/launcher.dart';

Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (_) => const _SettingsSheet(),
  );
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.settingsOf(context);
    final theme = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: settings.box.listenable(),
      builder: (context, _, __) => SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24 + MediaQuery.paddingOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text('Settings', style: theme.textTheme.titleLarge),
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              secondary: const Icon(Icons.public_rounded),
              title: const Text('Use my time zone'),
              subtitle: Text(
                settings.useLocalTime
                    ? 'Times shown in ${DateTime.now().timeZoneName}'
                    : 'Times shown in UTC',
              ),
              value: settings.useLocalTime,
              onChanged: settings.setUseLocalTime,
            ),
            const ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(Icons.palette_outlined),
              title: Text('Theme'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.brightness_auto_outlined)),
                    ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_outlined)),
                    ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_outlined)),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (value) => settings.setThemeMode(value.single),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showAppAboutDialog(BuildContext context) async {
  // Version and package id come from the installed build, never hardcoded.
  final info = await PackageInfo.fromPlatform();
  if (!context.mounted) return;

  showAboutDialog(
    context: context,
    applicationName: 'CodeList',
    applicationVersion: 'Version ${info.version} (${info.buildNumber})',
    // The icon is dark line art on transparency; a white tile keeps it visible
    // in dark mode.
    applicationIcon: Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Image.asset('asset/icon.png', fit: BoxFit.contain),
    ),
    children: [
      const Text('All your coding contests in one place.'),
      const SizedBox(height: 12),
      const _Bullet('130+ platforms, including Codeforces, LeetCode and AtCoder'),
      const _Bullet('Filter by your favourite platforms'),
      const _Bullet('Add contests to your calendar'),
      const _Bullet('Works offline'),
      const SizedBox(height: 12),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          onPressed: () => _openStoreListing(context, info.packageName),
          icon: const Icon(Icons.rate_review_outlined),
          label: const Text('Feedback'),
        ),
      ),
    ],
  );
}

/// Opens the Play Store listing so users can leave a review; falls back to the
/// web listing when the Play Store app isn't installed.
Future<void> _openStoreListing(BuildContext context, String packageName) async {
  final messenger = ScaffoldMessenger.of(context);
  final opened = await tryLaunchExternal(Uri.parse('market://details?id=$packageName')) ||
      await tryLaunchExternal(
          Uri.https('play.google.com', '/store/apps/details', {'id': packageName}));
  if (!opened) {
    messenger.showSnackBar(const SnackBar(content: Text("Couldn't open the Play Store")));
  }
}

/// A bullet point with a hanging indent so wrapped lines align with the text.
class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
