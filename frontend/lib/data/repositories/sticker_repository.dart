import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../models/sticker.dart';
import '../models/user_sticker.dart';
import '../services/pocketbase_service.dart';

@injectable
class StickerRepository {
  StickerRepository(this._pbService);
  final PocketbaseService _pbService;

  PocketBase get _pb => _pbService.pb;

  /// Get all level stickers (1-18)
  Future<List<Sticker>> getLevelStickers() async {
    try {
      final result = await _pb.collection('stickers').getFullList(
            filter: 'type="level" && is_published=true',
            sort: 'sort_order',
          );
      return result.map((r) => Sticker.fromRecord(r, pb: _pb)).toList();
    } catch (e) {
      debugPrint('StickerRepository.getLevelStickers error: $e');
      return [];
    }
  }

  /// Get all story stickers
  Future<List<Sticker>> getStoryStickers() async {
    try {
      final result = await _pb.collection('stickers').getFullList(
            filter: 'type="story" && is_published=true',
            sort: 'sort_order',
          );
      return result.map((r) => Sticker.fromRecord(r, pb: _pb)).toList();
    } catch (e) {
      debugPrint('StickerRepository.getStoryStickers error: $e');
      return [];
    }
  }

  /// Get current user's unlocked stickers (with sticker expanded)
  Future<List<UserSticker>> getMyUnlockedStickers() async {
    try {
      if (!_pbService.isAuthenticated) return [];

      final userId = _pbService.currentUser?.id;
      if (userId == null) return [];

      final result = await _pb.collection('user_stickers').getFullList(
            filter: 'user="$userId"',
            sort: '-created',
            expand: 'sticker',
          );
      return result.map((r) => UserSticker.fromRecord(r, pb: _pb)).toList();
    } catch (e) {
      debugPrint('StickerRepository.getMyUnlockedStickers error: $e');
      return [];
    }
  }
}
