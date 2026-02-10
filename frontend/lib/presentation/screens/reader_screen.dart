import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../cubits/reader_cubit/reader_cubit.dart';
import '../cubits/reader_cubit/reader_state.dart';

@RoutePage()
class ReaderScreen extends StatelessWidget {
  final String storyId;
  final String chapterId;

  const ReaderScreen({
    super.key,
    @PathParam('storyId') required this.storyId,
    @PathParam('chapterId') required this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReaderCubit()..loadChapter(chapterId),
      child: const _ReaderView(),
    );
  }
}

class _ReaderView extends StatefulWidget {
  const _ReaderView();

  @override
  State<_ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<_ReaderView> {
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
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
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text(state.message)),
          );
        }

        if (state is ReaderLoaded) {
          final chapter = state.chapter;
          final isDarkMode = state.isDarkMode;
          final fontSize = state.fontSize;

          return Scaffold(
            backgroundColor: isDarkMode
                ? const Color(0xFF1A1A1A)
                : const Color(0xFFF5F0E8),
            body: GestureDetector(
              onTap: _toggleControls,
              child: Stack(
                children: [
                  // Content
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
                          // Chapter title
                          Text(
                            '제 ${chapter.chapterNumber} 화',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.grey
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            chapter.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Story content
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
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),

                  // Top controls
                  if (_showControls)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              isDarkMode
                                  ? Colors.black.withValues(alpha: 0.8)
                                  : Colors.white.withValues(alpha: 0.9),
                              isDarkMode
                                  ? Colors.black.withValues(alpha: 0)
                                  : Colors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  onPressed: () => context.router.maybePop(),
                                ),
                                Expanded(
                                  child: Text(
                                    chapter.title,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.settings,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  onPressed: () =>
                                      _showSettings(context, state),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Bottom controls
                  if (_showControls)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              isDarkMode
                                  ? Colors.black.withValues(alpha: 0.8)
                                  : Colors.white.withValues(alpha: 0.9),
                              isDarkMode
                                  ? Colors.black.withValues(alpha: 0)
                                  : Colors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LinearProgressIndicator(
                                  value: 0.3, // TODO: Link to real progress
                                  backgroundColor: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation(
                                    AppTheme.primaryColor(context),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.skip_previous),
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.play_arrow),
                                      iconSize: 40,
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.skip_next),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showSettings(BuildContext context, ReaderLoaded state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: state.isDarkMode
          ? const Color(0xFF2A2A2A)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('설정', style: AppTheme.headingMedium(context)),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('글자 크기'),
                Expanded(
                  child: Slider(
                    value: state.fontSize,
                    min: 14,
                    max: 32,
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
              title: const Text('어두운 모드'),
              value: state.isDarkMode,
              onChanged: (value) {
                context.read<ReaderCubit>().updateSettings(isDarkMode: value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
