import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

@RoutePage()
class ReaderScreen extends StatefulWidget {
  final String storyId;
  final String chapterId;

  const ReaderScreen({
    super.key,
    @PathParam('storyId') required this.storyId,
    @PathParam('chapterId') required this.chapterId,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  double _fontSize = 18;
  bool _isDarkMode = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    // Hide system UI for immersive reading
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore system UI
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
    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF5F0E8),
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
                    const SizedBox(height: 60), // Space for app bar
                    // Chapter title
                    Text(
                      '제 1 화',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isDarkMode ? Colors.grey : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '레이스가 시작되다',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Story content
                    Text(
                      '''옛날 옛적에 토끼와 거북이가 살았습니다. 토끼는 매우 빨랐고, 거북이는 매우 느렸습니다.

어느 날, 토끼가 거북이에게 말했습니다. "너는 너무 느려! 나와 레이스를 합시다."

거북이는 대답했습니다. "좋아요. 꼭 이길 거예요!"

모든 동물들이 레이스를 보기 위해 모였습니다. 코끼리 심판이 외쳤습니다. "준비... 시작!"

토끼는 매우 빨리 달렸습니다. 금방 거북이를 멀리 뒤로 밀어냈죠.

"이 거북이는 너무 느려. 난 잠깐 쉬어도 이길 수 있어."

토끼는 나무 아래에서 잠이 들었습니다.

한편, 거북이는 천천히 그치만 멈추지 않고 걸었습니다.

결국 거북이가 결승선에 먼저 도착했습니다! 모든 동물들이 환호했습니다.

토끼가 깨어났을 때는 이미 늦었습니다. 거북이가 이긴 것이죠.

교훈: 느리지만 꾸준한 것이 이긴다는 것을 배웠습니다.''',
                      style: TextStyle(
                        fontSize: _fontSize,
                        height: 1.8,
                        color: _isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 60), // Space for bottom bar
                  ],
                ),
              ),
            ),

            // Top controls (app bar)
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
                        _isDarkMode ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
                        _isDarkMode ? Colors.black.withOpacity(0) : Colors.white.withOpacity(0),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: _isDarkMode ? Colors.white : Colors.black),
                            onPressed: () => context.router.pop(),
                          ),
                          const Expanded(
                            child: Text(
                              '토끼와 거북이',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.settings, color: _isDarkMode ? Colors.white : Colors.black),
                            onPressed: _showSettings,
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
                        _isDarkMode ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
                        _isDarkMode ? Colors.black.withOpacity(0) : Colors.white.withOpacity(0),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Progress bar
                          LinearProgressIndicator(
                            value: 0.3,
                            backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation(
                              AppTheme.primaryColor(context),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '설정',
              style: AppTheme.headingMedium(context),
            ),
            const SizedBox(height: 20),

            // Font size
            Row(
              children: [
                const Text('글자 크기'),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 14,
                    max: 32,
                    divisions: 9,
                    label: _fontSize.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _fontSize = value;
                      });
                    },
                  ),
                ),
                Text('${_fontSize.round()}'),
              ],
            ),

            // Dark mode toggle
            SwitchListTile(
              title: const Text('어두운 모드'),
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
