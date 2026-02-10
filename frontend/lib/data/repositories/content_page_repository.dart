import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../services/pocketbase_service.dart';

@injectable
class ContentPageRepository {
  ContentPageRepository(this._pbService);
  final PocketbaseService _pbService;

  PocketBase get _pb => _pbService.pb;

  /// Fetch content page by slug and optional locale (default: ko)
  Future<ContentPage?> getPage(String slug, {String locale = 'ko'}) async {
    try {
      final safeSlug = slug.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
      var filter = 'slug="$safeSlug" && active=true';
      if (locale.isNotEmpty) {
        final safeLocale = locale.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
        filter += ' && locale="$safeLocale"';
      }
      var result = await _pb.collection('content_pages').getList(
            filter: filter,
            perPage: 1,
          );
      if (result.items.isEmpty && locale.isNotEmpty) {
        result = await _pb.collection('content_pages').getList(
              filter: 'slug="$safeSlug" && active=true',
              perPage: 1,
            );
      }
      if (result.items.isEmpty) return null;
      return ContentPage.fromRecord(result.items.first);
    } catch (e) {
      debugPrint('ContentPageRepository.getPage error: $e');
      return null;
    }
  }
}

class ContentPage {
  final String id;
  final String slug;
  final String title;
  final String? content;
  final String? locale;
  final bool active;

  ContentPage({
    required this.id,
    required this.slug,
    required this.title,
    this.content,
    this.locale,
    this.active = true,
  });

  factory ContentPage.fromRecord(dynamic record) {
    return ContentPage(
      id: record.id,
      slug: record.data['slug']?.toString() ?? '',
      title: record.data['title']?.toString() ?? '',
      content: record.data['content']?.toString(),
      locale: record.data['locale']?.toString(),
      active: record.data['active'] == true,
    );
  }
}
