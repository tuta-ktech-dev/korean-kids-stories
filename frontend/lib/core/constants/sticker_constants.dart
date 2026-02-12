/// XP values (match backend hooks/reading_progress.go)
const int xpChapterRead = 10;
const int xpChapterListen = 15; // includes read
const int xpStoryBonus = 50;

/// Chức quan Joseon theo level (품계, 문관)
class LevelRank {
  final String rankKo; // 품계
  final String nameKo; // 문관 (tên chức)
  const LevelRank(this.rankKo, this.nameKo);
}

const List<LevelRank> levelRanks = [
  LevelRank('종9품', '장사랑'),      // 1
  LevelRank('정9품', '감사랑'),      // 2
  LevelRank('종8품', '인순부위'),    // 3
  LevelRank('정8품', '통덕랑'),      // 4
  LevelRank('종7품', '겸인순부위'),  // 5
  LevelRank('정7품', '사과'),        // 6
  LevelRank('종6품', '승정랑'),      // 7
  LevelRank('정6품', '수문장'),      // 8
  LevelRank('종5품', '통선랑'),      // 9
  LevelRank('정5품', '통덕랑'),      // 10
  LevelRank('종4품', '봉정대부'),    // 11
  LevelRank('정4품', '봉렬대부'),    // 12
  LevelRank('종3품', '통정대부'),    // 13
  LevelRank('정3품', '통훈대부'),    // 14
  LevelRank('종2품', '가선대부'),    // 15
  LevelRank('정2품', '자헌대부'),    // 16
  LevelRank('종1품', '숭정대부'),    // 17
  LevelRank('정1품', '대광보국숭록대부'), // 18
];

LevelRank getLevelRank(int level) {
  final i = (level - 1).clamp(0, levelRanks.length - 1);
  return levelRanks[i];
}

/// XP thresholds for level 1-18 (min XP to reach level N).
/// Must match backend hooks/reading_progress.go
const List<double> xpLevelThresholds = [
  0, 100, 250, 500, 1000, 1750, 2500, 3500, 5000, 6500, 8500,
  11000, 14000, 17500, 21500, 26000, 31000,
];

int levelFromXp(double totalXp) {
  for (var i = xpLevelThresholds.length - 1; i >= 0; i--) {
    if (totalXp >= xpLevelThresholds[i]) {
      return i + 1;
    }
  }
  return 1;
}

/// Progress from current level to next (0.0 - 1.0).
/// Returns null if already max level (18).
double? progressToNextLevel(double totalXp) {
  final level = levelFromXp(totalXp);
  if (level >= 18) return null;
  final currentThreshold = xpLevelThresholds[level - 1];
  final nextThreshold = xpLevelThresholds[level];
  final range = nextThreshold - currentThreshold;
  final progress = (totalXp - currentThreshold) / range;
  return progress.clamp(0.0, 1.0);
}
