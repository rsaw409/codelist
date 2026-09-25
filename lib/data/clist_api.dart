import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'contest.dart';
import 'credentials.dart';

class ClistApiException implements Exception {
  const ClistApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// A contest platform ("resource" in clist.by terms).
class Platform {
  const Platform({required this.id, required this.name, required this.iconPath});
  final int id;
  final String name;
  final String iconPath;
}

/// Thin client for the clist.by v1 API.
class ClistApi {
  ClistApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _host = 'clist.by';
  static const _timeout = Duration(seconds: 30);
  // The API pages at 100 by default; one large page avoids silently dropping
  // contests and platforms (there are ~170 and ~140 respectively).
  static const _pageLimit = '1000';

  Map<String, String> get _auth => {'username': username, 'api_key': key};

  Future<List<Contest>> fetchContests() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final json = await _getJson('/api/v1/contest/', {
      'end__gte': today,
      'order_by': 'end',
      'limit': _pageLimit,
    });
    return [
      for (final item in json['objects'] as List) Contest.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<List<Platform>> fetchPlatforms() async {
    final json = await _getJson('/api/v1/resource/', const {'limit': _pageLimit});
    return [
      for (final item in (json['objects'] as List).cast<Map<String, dynamic>>())
        Platform(
          id: item['id'] as int,
          name: item['name'] as String,
          iconPath: item['icon'] as String,
        ),
    ];
  }

  Future<Uint8List> downloadIcon(String iconPath) async {
    final uri = Uri.https(_host, iconPath.startsWith('/') ? iconPath : '/$iconPath');
    final response = await _client.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw ClistApiException('Icon download failed (${response.statusCode})');
    }
    return response.bodyBytes;
  }

  Future<Map<String, dynamic>> _getJson(String path, Map<String, String> query) async {
    final uri = Uri.https(_host, path, {..._auth, ...query});
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on Exception catch (e) {
      debugPrint('GET $path failed: $e');
      throw const ClistApiException("Couldn't reach clist.by. Check your connection.");
    }
    if (response.statusCode != 200) {
      throw ClistApiException('clist.by returned an error (${response.statusCode}).');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
