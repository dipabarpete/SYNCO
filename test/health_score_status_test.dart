import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hersync/features/health/services/health_score_status.dart';

void main() {
  group('getHealthScoreStatus exact ranges', () {
    final cases = <(int, String)>[
      (100, 'EXCELLENT'),
      (99, 'THRIVING'),
      (95, 'THRIVING'),
      (90, 'THRIVING'),
      (89, 'ON TRACK'),
      (85, 'ON TRACK'),
      (82, 'ON TRACK'),
      (81, 'PROGRESSING'),
      (76, 'PROGRESSING'),
      (72, 'PROGRESSING'),
      (71, 'NEEDS IMPROVEMENT'),
      (65, 'NEEDS IMPROVEMENT'),
      (60, 'NEEDS IMPROVEMENT'),
      (59, 'NEEDS ATTENTION'),
      (30, 'NEEDS ATTENTION'),
      (0, 'NEEDS ATTENTION'),
    ];

    for (final (score, expected) in cases) {
      test('score $score -> $expected', () {
        expect(getHealthScoreStatus(score).status, expected);
      });
    }

    test('EXCELLENT appears only for exactly 100', () {
      expect(getHealthScoreStatus(100).status, 'EXCELLENT');
      expect(getHealthScoreStatus(99).status, isNot('EXCELLENT'));
      expect(getHealthScoreStatus(95).status, isNot('EXCELLENT'));
      expect(getHealthScoreStatus(90).status, isNot('EXCELLENT'));
    });

    test('every score 0..100 maps to exactly one status', () {
      final seen = <String>{};
      for (var score = 0; score <= 100; score++) {
        seen.add(getHealthScoreStatus(score).status);
      }
      expect(
        seen,
        {
          'EXCELLENT',
          'THRIVING',
          'ON TRACK',
          'PROGRESSING',
          'NEEDS IMPROVEMENT',
          'NEEDS ATTENTION',
        },
      );
    });

    test('ranges are contiguous with no gaps', () {
      for (var score = 1; score <= 100; score++) {
        final prev = getHealthScoreStatus(score - 1).status;
        final curr = getHealthScoreStatus(score).status;
        expect(
          prev == curr ||
              score == 100 ||
              score == 90 ||
              score == 82 ||
              score == 72 ||
              score == 60,
          isTrue,
          reason: 'unexpected status jump between $score-1 and $score',
        );
      }
    });

    test('messages match the spec', () {
      expect(getHealthScoreStatus(100).message, 'You’re doing great! Keep it up.');
      expect(getHealthScoreStatus(92).message, 'You’re doing great! Keep it up.');
      expect(getHealthScoreStatus(85).message, 'Your health is on a good track.');
      expect(
        getHealthScoreStatus(75).message,
        'You’re doing well, but there’s room to improve.',
      );
      expect(
        getHealthScoreStatus(65).message,
        'Consider focusing more on your health habits.',
      );
      expect(
        getHealthScoreStatus(40).message,
        'It’s time to focus on improving your overall health.',
      );
    });

    test('score is clamped to 0..100', () {
      expect(getHealthScoreStatus(250).score, 100);
      expect(getHealthScoreStatus(-10).score, 0);
      expect(getHealthScoreStatus(250).status, 'EXCELLENT');
      expect(getHealthScoreStatus(-10).status, 'NEEDS ATTENTION');
    });

    test('dashboard and report use the same status instance values', () {
      final fromDashboard = getHealthScoreStatus(84);
      final fromReport = getHealthScoreStatus(84);
      expect(fromDashboard.status, fromReport.status);
      expect(fromDashboard.message, fromReport.message);
      expect(fromDashboard.color, fromReport.color);
    });
  });

  group('getHealthScoreColor score-driven progression', () {
    test('highest score maps to the deepest green', () {
      expect(getHealthScoreColor(100), const Color(0xFF134E2C));
    });

    test('lowest score maps to deep red', () {
      expect(getHealthScoreColor(0), const Color(0xFF9B2C1F));
    });

    test('color follows the numeric score along the gradient', () {
      for (var s = 1; s <= 100; s++) {
        expect(
          getHealthScoreColor(s),
          isNot(getHealthScoreColor(s - 1)),
          reason: 'color must change as the score changes',
        );
      }
    });

    test('keyframe anchors match the visual direction', () {
      expect(getHealthScoreColor(100), const Color(0xFF134E2C));
      expect(getHealthScoreColor(90), const Color(0xFF2E8B76));
      expect(getHealthScoreColor(82), const Color(0xFF6BA14E));
      expect(getHealthScoreColor(72), const Color(0xFFA9A93F));
      expect(getHealthScoreColor(60), const Color(0xFFE8922C));
      expect(getHealthScoreColor(45), const Color(0xFFC0392B));
      expect(getHealthScoreColor(0), const Color(0xFF9B2C1F));
    });

    test('status color matches the score circle color', () {
      expect(getHealthScoreStatus(88).color, getHealthScoreColor(88));
      expect(getHealthScoreStatus(45).color, getHealthScoreColor(45));
    });

    test('color is clamped to 0..100', () {
      expect(getHealthScoreColor(250), getHealthScoreColor(100));
      expect(getHealthScoreColor(-10), getHealthScoreColor(0));
    });
  });
}
