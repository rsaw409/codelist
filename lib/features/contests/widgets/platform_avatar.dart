import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../app_scope.dart';

/// Rounded platform logo; falls back to the platform's initial until the logo
/// has been cached.
class PlatformAvatar extends StatelessWidget {
  const PlatformAvatar({
    super.key,
    required this.platformId,
    required this.name,
    this.size = 44,
  });

  final int platformId;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.settingsOf(context);
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(size * 0.3);

    final fallback = Container(
      alignment: Alignment.center,
      color: scheme.primaryContainer,
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.42,
        ),
      ),
    );

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: ClipRRect(
          borderRadius: radius,
          child: ValueListenableBuilder(
            valueListenable: settings.box.listenable(keys: [platformId]),
            builder: (context, _, __) {
              final path = settings.logoPath(platformId);
              if (path == null) return fallback;
              // Logos are brand assets drawn for light backgrounds.
              return ColoredBox(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(size * 0.14),
                  child: Image.file(
                    File(path),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => fallback,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
