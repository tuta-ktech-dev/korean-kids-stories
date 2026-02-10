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
