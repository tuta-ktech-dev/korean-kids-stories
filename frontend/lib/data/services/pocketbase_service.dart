import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chapter_audio.dart';
import '../models/story.dart';
import '../../core/config/app_config.dart';
import '../models/chapter.dart';

const String _deviceIdKey = 'device_id';

/// Device ID for IAP verification & chapter is_premium. Cached after first get.
String? _cachedDeviceId;

Future<String> getOrCreateDeviceId() async {
  if (_cachedDeviceId != null) return _cachedDeviceId!;
  final prefs = await SharedPreferences.getInstance();
  var id = prefs.getString(_deviceIdKey);
  if (id == null || id.isEmpty) {
    final r = Random();
    id = List.generate(32, (_) => r.nextInt(16).toRadixString(16)).join();
    await prefs.setString(_deviceIdKey, id);
  }
  _cachedDeviceId = id;
  return id;
}

/// HTTP client that adds X-Device-ID header for chapter is_premium API
class _DeviceHeaderClient extends http.BaseClient {
  _DeviceHeaderClient(this._deviceId);
  final String _deviceId;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['X-Device-ID'] = _deviceId;
    return _inner.send(request);
  }

  final _inner = http.Client();
}

/// Custom exception for Pocketbase service errors
class PocketbaseException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  PocketbaseException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'PocketbaseException: $message (status: $statusCode)';
}

/// Service class for interacting with Pocketbase backend
class PocketbaseService {
  static final PocketbaseService _instance = PocketbaseService._internal();
  factory PocketbaseService() => _instance;
  PocketbaseService._internal();

  late final PocketBase _pb;
  bool _initialized = false;

  static String get baseUrl => AppConfig.baseUrl;

  /// Initialize the Pocketbase service
  ///
  /// Must be called before using any other methods
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = await getOrCreateDeviceId();

      final store = AsyncAuthStore(
        save: (String data) async => prefs.setString('pb_auth', data),
        initial: prefs.getString('pb_auth'),
        clear: () async => prefs.remove('pb_auth'),
      );

      _pb = PocketBase(
        baseUrl,
        authStore: store,
        httpClientFactory: () => _DeviceHeaderClient(deviceId),
      );

      // When app restarts: token may be expired but we have stored auth.
      // Try authRefresh to get new token; clear if refresh fails.
      if (_pb.authStore.record != null && !_pb.authStore.isValid) {
        try {
          await _pb.collection('users').authRefresh();
        } catch (_) {
          _pb.authStore.clear();
        }
      }

      _initialized = true;
    } catch (e) {
      throw PocketbaseException(
        message: 'Failed to initialize Pocketbase service',
        originalError: e,
      );
    }
  }

  /// Get the Pocketbase instance
  ///
  /// Throws [StateError] if not initialized
  PocketBase get pb {
    if (!_initialized) {
      throw StateError(
        'PocketbaseService not initialized. Call initialize() first.',
      );
    }
    return _pb;
  }

  /// Check if user is logged in
  bool get isAuthenticated => pb.authStore.isValid;

  /// Get current user
  RecordModel? get currentUser => pb.authStore.record;

  /// Stories API

  /// Fetch stories with optional filters
  ///
  /// Throws [PocketbaseException] on error
  Future<List<Story>> getStories({
    String? category,
    int? minAge,
    int? maxAge,
    String? search,
  }) async {
    try {
      final filters = <String>[];

      if (category != null && category.isNotEmpty) {
        filters.add('category="${category.replaceAll('"', '\\"')}"');
      }
      if (minAge != null) {
        filters.add('age_min>=$minAge');
      }
      if (maxAge != null) {
        filters.add('age_max<=$maxAge');
      }
      if (search != null && search.isNotEmpty) {
        // Escape special characters in search
        final escapedSearch = search.replaceAll('"', '\\"');
        filters.add('title~"$escapedSearch"');
      }

      // Always filter published stories for public view
      filters.add('is_published=true');

      final filterString = filters.join(' && ');

      final result = await pb
          .collection('stories')
          .getList(page: 1, perPage: 50, filter: filterString);

      return result.items
          .map((record) => Story.fromRecord(record, pb: pb))
          .toList();
    } on ClientException catch (e) {
      throw PocketbaseException(
        message: e.response['message']?.toString() ?? 'Failed to fetch stories',
        statusCode: e.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw PocketbaseException(
        message: 'Failed to fetch stories',
        originalError: e,
      );
    }
  }

  /// Fetch stories with server-side pagination.
  /// Returns items for the given [page] and [perPage], plus [totalItems].
  Future<({List<Story> items, int totalItems})> getStoriesPage({
    int page = 1,
    int perPage = 20,
    String? category,
    String? search,
    int? minAge,
    int? maxAge,
  }) async {
    try {
      final filters = <String>[];
      if (category != null && category.isNotEmpty && category != 'all') {
        filters.add('category="${category.replaceAll('"', '\\"')}"');
      }
      if (search != null && search.isNotEmpty) {
        final escapedSearch = search.replaceAll('"', '\\"');
        filters.add('title~"$escapedSearch"');
      }
      if (minAge != null) {
        filters.add('age_min>=$minAge');
      }
      if (maxAge != null) {
        filters.add('age_max<=$maxAge');
      }
      filters.add('is_published=true');
      final filterString = filters.join(' && ');

      final result = await pb.collection('stories').getList(
            page: page,
            perPage: perPage,
            filter: filterString,
          );
      final items = result.items
          .map((record) => Story.fromRecord(record, pb: pb))
          .toList();
      return (items: items, totalItems: result.totalItems);
    } on ClientException catch (e) {
      throw PocketbaseException(
        message: e.response['message']?.toString() ?? 'Failed to fetch stories',
        statusCode: e.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw PocketbaseException(
        message: 'Failed to fetch stories',
        originalError: e,
      );
    }
  }

  /// Fetch popular searches from API. Cached 24h in SharedPreferences.
  Future<List<String>> getPopularSearches() async {
    const cacheKey = 'popular_searches_cache';
    const cacheTimeKey = 'popular_searches_cache_time';
    const maxAge = Duration(hours: 24);

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(cacheKey);
      final cachedTime = prefs.getInt(cacheTimeKey);

      if (cachedJson != null &&
          cachedTime != null &&
          DateTime.now().millisecondsSinceEpoch - cachedTime <
              maxAge.inMilliseconds) {
        final list = _parseQueriesFromJson(cachedJson);
        if (list.isNotEmpty) return list;
      }

      await initialize();
      final url = '$baseUrl/api/popular-searches';
      final response = await Dio().get<String>(url);
      if (response.statusCode != 200 || response.data == null) return [];

      final queries = _parseQueriesFromJson(response.data!);
      if (queries.isNotEmpty) {
        await prefs.setString(cacheKey, response.data!);
        await prefs.setInt(
            cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
      }
      return queries;
    } catch (e) {
      debugPrint('getPopularSearches error: $e');
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedJson = prefs.getString(cacheKey);
        if (cachedJson != null) {
          final list = _parseQueriesFromJson(cachedJson);
          if (list.isNotEmpty) return list;
        }
      } catch (_) {}
      return [];
    }
  }

  List<String> _parseQueriesFromJson(String jsonStr) {
    try {
      final body = jsonDecode(jsonStr);
      if (body is Map && body['queries'] is List) {
        return (body['queries'] as List)
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Get a single story by ID
  ///
  /// Throws [PocketbaseException] on error
  Future<Story?> getStory(String id) async {
    try {
      final record = await pb.collection('stories').getOne(id);
      return Story.fromRecord(record, pb: pb);
    } on ClientException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }
      throw PocketbaseException(
        message: e.response['message']?.toString() ?? 'Failed to fetch story',
        statusCode: e.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw PocketbaseException(
        message: 'Failed to fetch story',
        originalError: e,
      );
    }
  }

  /// Chapters API

  /// Get all chapters for a story
  ///
  /// Throws [PocketbaseException] on error
  Future<List<Chapter>> getChapters(String storyId) async {
    try {
      final result = await pb
          .collection('chapters')
          .getList(
            page: 1,
            perPage: 100,
            filter: 'story="${storyId.replaceAll('"', '\\"')}"',
            sort: 'chapter_number',
          );

      return result.items
          .map((r) => Chapter.fromRecord(r, baseUrl: baseUrl))
          .toList();
    } on ClientException catch (e) {
      throw PocketbaseException(
        message:
            e.response['message']?.toString() ?? 'Failed to fetch chapters',
        statusCode: e.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw PocketbaseException(
        message: 'Failed to fetch chapters',
        originalError: e,
      );
    }
  }

  /// Get multiple chapters by IDs (for mapping chapter→story from progress)
  Future<List<Chapter>> getChaptersByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      final filter = ids.map((id) => 'id="${id.replaceAll('"', '\\"')}"').join(' || ');
      final result = await pb.collection('chapters').getList(
        page: 1,
        perPage: 500,
        filter: '($filter)',
      );
      return result.items.map((r) => Chapter.fromRecord(r, baseUrl: baseUrl)).toList();
    } catch (e) {
      debugPrint('getChaptersByIds error: $e');
      return [];
    }
  }

  /// Get a single chapter by ID
  ///
  /// Throws [PocketbaseException] on error
  Future<Chapter?> getChapter(String chapterId) async {
    try {
      final record = await pb.collection('chapters').getOne(chapterId);
      return Chapter.fromRecord(record, baseUrl: baseUrl);
    } on ClientException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }
      throw PocketbaseException(
        message: e.response['message']?.toString() ?? 'Failed to fetch chapter',
        statusCode: e.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw PocketbaseException(
        message: 'Failed to fetch chapter',
        originalError: e,
      );
    }
  }

  /// Get all audio versions for a chapter (multiple narrators/voices)
  ///
  /// Throws [PocketbaseException] on error
  Future<List<ChapterAudio>> getChapterAudios(String chapterId) async {
    try {
      final result = await pb
          .collection('chapter_audios')
          .getList(
            page: 1,
            perPage: 20,
            filter: 'chapter="${chapterId.replaceAll('"', '\\"')}"',
          );

      final token = pb.authStore.token;
      return result.items
          .map((r) => ChapterAudio.fromRecord(r,
              baseUrl: baseUrl, authToken: token))
          .toList();
    } on ClientException catch (e) {
      throw PocketbaseException(
        message:
            e.response['message']?.toString() ?? 'Failed to fetch chapter audios',
        statusCode: e.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw PocketbaseException(
        message: 'Failed to fetch chapter audios',
        originalError: e,
      );
    }
  }

  /// Auth API

  /// Authenticate with OAuth provider
  ///
  /// Throws [PocketbaseException] on error
  Future<RecordAuth> loginWithOAuth(String provider) async {
    try {
      return await pb.collection('users').authWithOAuth2(provider, (url) async {
        // Open OAuth URL in browser
        // For mobile, use url_launcher package
        debugPrint('Open this URL to login: $url');
      });
    } on ClientException catch (e) {
      throw PocketbaseException(
        message:
            e.response['message']?.toString() ?? 'OAuth authentication failed',
        statusCode: e.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw PocketbaseException(
        message: 'OAuth authentication failed',
        originalError: e,
      );
    }
  }

  /// Logout current user
  ///
  /// Throws [PocketbaseException] on error
  Future<void> logout() async {
    try {
      pb.authStore.clear();
    } catch (e) {
      throw PocketbaseException(message: 'Failed to logout', originalError: e);
    }
  }

  /// Request email verification
  ///
  /// Throws [PocketbaseException] on error
  Future<void> requestEmailVerification(String email) async {
    try {
      await pb.collection('users').requestVerification(email);
    } on ClientException catch (e) {
      throw PocketbaseException(
        message:
            e.response['message']?.toString() ??
            'Failed to request email verification',
        statusCode: e.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw PocketbaseException(
        message: 'Failed to request email verification',
        originalError: e,
      );
    }
  }

  /// Verify email with token
  ///
  /// Throws [PocketbaseException] on error
  Future<void> verifyEmail(String token) async {
    try {
      await pb.collection('users').confirmVerification(token);
    } on ClientException catch (e) {
      throw PocketbaseException(
        message:
            e.response['message']?.toString() ?? 'Email verification failed',
        statusCode: e.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw PocketbaseException(
        message: 'Email verification failed',
        originalError: e,
      );
    }
  }
}
