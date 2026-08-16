import 'package:flutter/material.dart';

/// Single source of truth for the Health Score status + message logic.
///
/// Both the dashboard Health Score card and the Full Health Report use this
/// helper so the score, status and message always match everywhere in the app.
class HealthScoreStatus {
  /// Clamped score (0–100).
  final int score;

  /// Status label, e.g. "EXCELLENT".
  final String status;

  /// Short personalized message shown with the status.
  final String message;

  /// Accent color used to visualise the status.
  final Color color;

  const HealthScoreStatus({
    required this.score,
    required this.status,
    required this.message,
    required this.color,
  });
}

/// Keyframes used for the smooth score-to-color progression.
///
/// High scores map to dark healthy green; as the score drops the color
/// shifts through yellow/orange down to red. Ordered highest to lowest.
const List<(double, Color)> _scoreColorStops = [
  (100, Color(0xFF134E2C)), // deepest green
  (90, Color(0xFF2E8B76)), // dark green
  (82, Color(0xFF6BA14E)), // green
  (72, Color(0xFFA9A93F)), // green/yellow transition
  (60, Color(0xFFE8922C)), // orange
  (45, Color(0xFFC0392B)), // red
  (0, Color(0xFF9B2C1F)), // deep red
];

/// Maps a health score (0–100) to one accent color.
///
/// The color is interpolated from the numeric score (not just the status
/// label) so it smoothly declines from darkest green to red.
Color getHealthScoreColor(int rawScore) {
  final score = rawScore.clamp(0, 100).toDouble();

  for (var i = 0; i < _scoreColorStops.length - 1; i++) {
    final (highScore, highColor) = _scoreColorStops[i];
    final (lowScore, lowColor) = _scoreColorStops[i + 1];
    if (score <= highScore && score >= lowScore) {
      final t = (highScore - score) / (highScore - lowScore);
      return Color.lerp(highColor, lowColor, t)!;
    }
  }
  return _scoreColorStops.last.$2;
}

/// Maps a health score (0–100) to exactly one status.
///
/// Ranges are exhaustive and non-overlapping:
/// 100 EXCELLENT · 90–99 THRIVING · 82–89 ON TRACK ·
/// 72–81 PROGRESSING · 60–71 NEEDS IMPROVEMENT · 0–59 NEEDS ATTENTION
HealthScoreStatus getHealthScoreStatus(int rawScore) {
  final score = rawScore.clamp(0, 100);
  final color = getHealthScoreColor(score);

  if (score == 100) {
    return HealthScoreStatus(
      score: score,
      status: 'EXCELLENT',
      message: 'You’re doing great! Keep it up.',
      color: color,
    );
  }
  if (score >= 90) {
    return HealthScoreStatus(
      score: score,
      status: 'THRIVING',
      message: 'You’re doing great! Keep it up.',
      color: color,
    );
  }
  if (score >= 82) {
    return HealthScoreStatus(
      score: score,
      status: 'ON TRACK',
      message: 'Your health is on a good track.',
      color: color,
    );
  }
  if (score >= 72) {
    return HealthScoreStatus(
      score: score,
      status: 'PROGRESSING',
      message: 'You’re doing well, but there’s room to improve.',
      color: color,
    );
  }
  if (score >= 60) {
    return HealthScoreStatus(
      score: score,
      status: 'NEEDS IMPROVEMENT',
      message: 'Consider focusing more on your health habits.',
      color: color,
    );
  }
  return HealthScoreStatus(
    score: score,
    status: 'NEEDS ATTENTION',
    message: 'It’s time to focus on improving your overall health.',
    color: color,
  );
}
