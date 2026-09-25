import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [uri] in an external app. Returns false instead of throwing when no
/// installed app can handle it (url_launcher throws on Android in that case).
Future<bool> tryLaunchExternal(Uri uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on PlatformException {
    return false;
  }
}
