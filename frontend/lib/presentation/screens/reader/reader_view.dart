import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/chapter.dart';
import '../../cubits/progress_cubit/progress_cubit.dart';
import '../../cubits/reader_cubit/reader_cubit.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';
import '../../components/buttons/bookmark_buttons.dart';
import '../../cubits/auth_cubit/auth_cubit.dart';
import '../../widgets/responsive_padding.dart';
import '../../cubits/note_cubit/note_cubit.dart';
import 'widgets/reader_bottom_bar.dart';

class ReaderView extends StatefulWidget {
  final String storyId;

  const ReaderView({super.key, required this.storyId});

  @override
  State<ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<ReaderView> {
  bool _showControls = true;
  double _lastProgress = 0.0;
  String? _chapterId;
  Timer? _saveDebounce;
  ProgressCubit? _progressCubit;
  final ScrollController _scrollController = ScrollController();
  bool _hasRestoredScroll = false;
  DateTime? _sessionStartTime;
  bool _skipNextZeroProgress = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _progressCubit ??= context.read<ProgressCubit>();
  }

  void _restoreScrollPosition(double progress) {
    if (progress <= 0.01 || progress >= 0.99 || _hasRestoredScroll) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      if (position.hasContentDimensions && position.maxScrollExtent > 0) {
        final offset = progress * position.maxScrollExtent;
        _scrollController.jumpTo(offset);
        _hasRestoredScroll = true;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _saveDebounce?.cancel();
    // Only save on dispose if user actually read (progress > 0) - avoid creating empty records
    if (_chapterId != null && _lastProgress > 0) {
      final pct = _lastProgress * 100;
      if (!pct.isNaN && !pct.isInfinite) {
        final duration = _sessionStartTime != null
            ? DateTime.now().difference(_sessionStartTime!).inSeconds
            : null;
        _progressCubit?.saveProgress(
          chapterId: _chapterId!,
          percentRead: pct.clamp(0.0, 100.0),
          isCompleted: _lastProgress >= 0.99,
          storyId: widget.storyId,
          durationSeconds: duration,
        );
      }
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  int? _getDurationSeconds() {
    if (_sessionStartTime == null) return null;
    return DateTime.now().difference(_sessionStartTime!).inSeconds;
  }

  void _onScrollProgress(BuildContext context, double progress) {
    // Ignore invalid progress (e.g. 0/0 when maxScrollExtent is 0)
    if (progress.isNaN || progress.isInfinite) return;
    // Skip save when progress=0 from jumpTo(0) during chapter switch
    if (progress == 0 && _skipNextZeroProgress) {
      _skipNextZeroProgress = false;
      _lastProgress = progress;
      context.read<ReaderCubit>().updateProgress(progress);
      return;
    }
    _lastProgress = progress;
    context.read<ReaderCubit>().updateProgress(progress);

    _saveDebounce?.cancel();
    final chapterId = _chapterId;
    _saveDebounce = Timer(const Duration(milliseconds: 1500), () {
      if (mounted && chapterId != null) {
        final pct = _lastProgress * 100;
        if (!pct.isNaN && !pct.isInfinite) {
          _progressCubit?.saveProgress(
            chapterId: chapterId,
            percentRead: pct.clamp(0.0, 100.0),
            isCompleted: _lastProgress >= 0.99,
            storyId: widget.storyId,
            durationSeconds: _getDurationSeconds(),
          );
        }
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _showChapterLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.locked),
        content: Text(context.l10n.chapterLockedHint),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.continueAction),
          ),
        ],
      ),
    );
  }

  void _switchChapter(BuildContext context, String chapterId) {
    // Save current chapter before switching (jumpTo would trigger scroll→wrong save)
    _saveDebounce?.cancel();
    final oldChapterId = _chapterId;
    if (oldChapterId != null && _lastProgress > 0) {
      final pct = (_lastProgress * 100).clamp(0.0, 100.0);
      if (!pct.isNaN && !pct.isInfinite) {
        _progressCubit?.saveProgress(
          chapterId: oldChapterId,
          percentRead: pct,
          isCompleted: _lastProgress >= 0.99,
          storyId: widget.storyId,
          durationSeconds: _getDurationSeconds(),
        );
      }
    }
    _hasRestoredScroll = false;
    _skipNextZeroProgress = true;
    _scrollController.jumpTo(0);
    context.read<ReaderCubit>().loadChapter(chapterId, skipLoading: true);
  }

  Widget _buildContent(
    BuildContext context,
    Chapter chapter,
    bool isDarkMode,
    double fontSize, {
    void Function(double progress)? onScrollProgress,
    Chapter? prevChapter,
    VoidCallback? onPrevChapter,
    Chapter? nextChapter,
    VoidCallback? onNextChapter,
    Chapter? nextChapterLocked,
  }) {
    return SafeArea(
      top: false,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (onScrollProgress == null) return false;
          final m = notification.metrics;
          final progress = m.maxScrollExtent > 0
              ? (m.pixels / m.maxScrollExtent).clamp(0.0, 1.0)
              : 1.0;
          onScrollProgress(progress);
          return false;
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            if (!_showControls) const SizedBox(height: 16),
            Text(
              context.l10n.chapterTitleFormatted(
                chapter.chapterNumber,
              ),
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.grey : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              chapter.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              chapter.content,
              style: TextStyle(
                fontSize: fontSize,
                height: 1.8,
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.9)
                    : Colors.black87,
              ),
            ),
            if (prevChapter != null || nextChapter != null || nextChapterLocked != null) ...[
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prevChapter != null && onPrevChapter != null)
                    IconButton.filled(
                      onPressed: onPrevChapter,
                      icon: const Icon(Icons.arrow_back_rounded, size: 28),
                      iconSize: 32,
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor(context),
                        foregroundColor: Colors.white,
                      ),
                      tooltip: context.l10n.previousChapter,
                    ),
                  if (prevChapter != null && (nextChapter != null || nextChapterLocked != null))
                    const SizedBox(width: 16),
                  if (nextChapter != null && onNextChapter != null)
                    IconButton.filled(
                      onPressed: onNextChapter,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 28),
                      iconSize: 32,
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor(context),
                        foregroundColor: Colors.white,
                      ),
                      tooltip: context.l10n.nextChapter,
                    )
                  else if (nextChapterLocked != null)
                    IconButton.filled(
                      onPressed: () => _showChapterLockedDialog(context),
                      icon: Icon(
                        Icons.lock_outline_rounded,
                        size: 28,
                        color: AppTheme.textMutedColor(context),
                      ),
                      iconSize: 32,
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.textMutedColor(context).withValues(alpha: 0.2),
                        foregroundColor: AppTheme.textMutedColor(context),
                      ),
                      tooltip: context.l10n.nextChapterLocked,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderCubit, ReaderState>(
      builder: (context, state) {
        if (state is ReaderLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ReaderError) {
          final msg = state.message == 'chapterNotFound'
              ? context.l10n.chapterNotFound
              : state.message == 'chapterLoadError'
                  ? context.l10n.chapterLoadError
                  : state.message == 'chapterLocked'
                      ? context.l10n.chapterLocked
                      : state.message;
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.error)),
            body: Center(child: Text(msg)),
          );
        }

        if (state is ReaderLoaded) {
          final chapter = state.chapter;
          final isDarkMode = state.isDarkMode;
          final fontSize = state.fontSize;
          if (_chapterId != chapter.id) {
            _sessionStartTime = DateTime.now();
          }
          _chapterId = chapter.id;
          _lastProgress = state.progress;
          _restoreScrollPosition(state.progress);

          return Scaffold(
            backgroundColor: isDarkMode
                ? const Color(0xFF1A1A1A)
                : const Color(0xFFF5F0E8),
            appBar: _showControls
                ? AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      onPressed: () => context.router.maybePop(),
                    ),
                    title: Text(
                      chapter.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    centerTitle: true,
                    actions: [
                      BlocBuilder<AuthCubit, AuthState>(
                        buildWhen: (p, c) => c is Authenticated,
                        builder: (context, authState) {
                          if (authState is! Authenticated) return const SizedBox.shrink();
                          return IconButton(
                            icon: Icon(
                              Icons.note_add_outlined,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            onPressed: () => _addNote(context, state),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.settings_rounded,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        onPressed: () => _showSettings(context, state),
                      ),
                    ],
                  )
                : null,
            body: ResponsivePadding(
              maxWidth: 640,
              horizontalPadding: 24,
              child: GestureDetector(
                onTap: _toggleControls,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: state.hasAudio
                    ? Column(
                        key: ValueKey(chapter.id),
                        children: [
                          Expanded(
                            child: _buildContent(
                            context,
                            chapter,
                            isDarkMode,
                            fontSize,
                            onScrollProgress: (p) => _onScrollProgress(context, p),
                            prevChapter: state.prevChapter,
                            onPrevChapter: state.prevChapter != null
                                ? () => _switchChapter(context, state.prevChapter!.id)
                                : null,
                            nextChapter: state.nextChapter,
                            onNextChapter: state.nextChapter != null
                                ? () => _switchChapter(context, state.nextChapter!.id)
                                : null,
                            nextChapterLocked: state.nextChapterLocked,
                          ),
                        ),
                        ReaderBottomBar(
                          isDarkMode: isDarkMode,
                          progress: state.progress,
                          isPlaying: state.isPlaying,
                          onPlayPause: () =>
                              context.read<ReaderCubit>().togglePlaying(),
                        ),
                      ],
                    )
                  : KeyedSubtree(
                      key: ValueKey(chapter.id),
                      child: _buildContent(
                      context,
                      chapter,
                      isDarkMode,
                      fontSize,
                      onScrollProgress: (p) => _onScrollProgress(context, p),
                      prevChapter: state.prevChapter,
                      onPrevChapter: state.prevChapter != null
                          ? () => _switchChapter(context, state.prevChapter!.id)
                          : null,
                      nextChapter: state.nextChapter,
                      onNextChapter: state.nextChapter != null
                          ? () => _switchChapter(context, state.nextChapter!.id)
                          : null,
                      nextChapterLocked: state.nextChapterLocked,
                    ),
                  ),
              ),
            ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _addNote(BuildContext context, ReaderLoaded state) async {
    final noteCubit = context.read<NoteCubit>();
    final existing = await noteCubit.getChapterNote(state.chapter.id);
    if (!context.mounted) return;
    showNoteSheet(
      context,
      initialNote: existing?.note,
      onSave: (note) async {
        if (note.trim().isEmpty) return;
        final cubit = context.read<NoteCubit>();
        final added = await cubit.addChapterNote(
          storyId: widget.storyId,
          chapterId: state.chapter.id,
          note: note.trim(),
          position: state.progress * 100,
        );
        if (context.mounted && added != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.bookmarkAdded)),
          );
        }
      },
    );
  }

  void _showSettings(BuildContext context, ReaderLoaded state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: context.read<ReaderCubit>(),
        child: BlocBuilder<ReaderCubit, ReaderState>(
          builder: (ctx, state) {
            if (state is! ReaderLoaded) return const SizedBox.shrink();
            return Container(
              decoration: BoxDecoration(
                color: state.isDarkMode
                    ? const Color(0xFF2A2A2A)
                    : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.settingsTitle,
                    style: AppTheme.headingMedium(context),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(context.l10n.fontSize),
                      Expanded(
                        child: Slider(
                          value: state.fontSize,
                          min: 18,
                          max: 36,
                          divisions: 9,
                          label: state.fontSize.round().toString(),
                          onChanged: (value) {
                            context.read<ReaderCubit>().updateSettings(
                              fontSize: value,
                            );
                          },
                        ),
                      ),
                      Text('${state.fontSize.round()}'),
                    ],
                  ),
                  SwitchListTile(
                    title: Text(context.l10n.darkMode),
                    value: state.isDarkMode,
                    onChanged: (value) {
                      context.read<ReaderCubit>().updateSettings(
                        isDarkMode: value,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
