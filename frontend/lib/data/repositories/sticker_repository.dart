import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../models/sticker.dart';
import '../models/user_sticker.dart';
import '../services/pocketbase_service.dart';
import 'local_sticker_repository.dart';

@injectable
class StickerRepository {
  StickerRepository(this._pbService, this._localStickerRepo);
  final PocketbaseService _pbService;
  final LocalStickerRepository _localStickerRepo;

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

  /// Get sticker for a story (by story relation)
  Future<Sticker?> getStickerByStoryId(String storyId) async {
    try {
      final result = await _pb.collection('stickers').getList(
            filter: 'type="story" && story="$storyId"',
            perPage: 1,
          );
      if (result.items.isEmpty) return null;
      return Sticker.fromRecord(result.items.first, pb: _pb);
    } catch (e) {
      debugPrint('StickerRepository.getStickerByStoryId error: $e');
      return null;
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

  /// Get current user's unlocked stickers (with sticker expanded).
  /// App kids không đăng nhập → đọc từ LocalStickerRepository.
  Future<List<UserSticker>> getMyUnlockedStickers() async {
    try {
      if (!_pbService.isAuthenticated) {
        return _getLocalUnlockedStickers();
      }

      final userId = _pbService.currentUser?.id;
      if (userId == null) return _getLocalUnlockedStickers();

      final result = await _pb.collection('user_stickers').getFullList(
            filter: 'user="$userId"',
            sort: '-created',
            expand: 'sticker',
          );
      return result.map((r) => UserSticker.fromRecord(r, pb: _pb)).toList();
    } catch (e) {
      debugPrint('StickerRepository.getMyUnlockedStickers error: $e');
      return _getLocalUnlockedStickers();
    }
  }

  Future<List<UserSticker>> _getLocalUnlockedStickers() async {
    final localList = await _localStickerRepo.getAll();
    if (localList.isEmpty) return [];
    final result = <UserSticker>[];
    for (final u in localList) {
      try {
        final sticker = await _pb.collection('stickers').getOne(u.stickerId);
        result.add(UserSticker.fromLocal(
          stickerId: u.stickerId,
          sticker: Sticker.fromRecord(sticker, pb: _pb),
          unlockSource: u.unlockSource,
          unlockedAt: u.unlockedAt,
        ));
      } catch (_) {
        // Sticker đã bị xóa trên PB, bỏ qua
      }
    }
    result.sort((a, b) => (b.unlockedAt ?? DateTime(0)).compareTo(a.unlockedAt ?? DateTime(0)));
    return result;
  }

  /// Unlock sticker local (khi hoàn thành truyện có has_sticker).
  Future<bool> unlockStickerLocal({
    required String stickerId,
    String unlockSource = 'story_complete',
  }) async {
    return _localStickerRepo.unlockSticker(
      stickerId: stickerId,
      unlockSource: unlockSource,
    );
  }
}
