import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Social Connection tool — how reaching out to trusted people can help,
/// with a small network illustration.
class SocialConnectionToolScreen extends StatefulWidget {
  const SocialConnectionToolScreen({super.key});

  @override
  State<SocialConnectionToolScreen> createState() =>
      _SocialConnectionToolScreenState();
}

const _rose = Color(0xFFE892A2);
const _roseLight = Color(0xFFFFF3F6);

class _SocialConnectionToolScreenState extends State<SocialConnectionToolScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  static const _whoToReachOutTo = [
    ('Friend', Icons.favorite_border_rounded),
    ('Family member', Icons.home_outlined),
    ('Trusted adult', Icons.support_agent_rounded),
    ('Support group', Icons.groups_rounded),
    ('Healthcare professional', Icons.medical_services_outlined),
  ];

  static const _waysToStart = [
    '\u201cI had a rough week — fancy a short walk?\u201d',
    '\u201cCan we catch up over a call this week?\u201d',
    '\u201cJust checking in — how are you doing?\u201d',
    '\u201cI\u2019ve been feeling off lately. Is it okay if I talk about it?\u201d',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Social Connection',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _roseLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _rose.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, child) =>
                        _NetworkIllustration(pulse: _pulse.value),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'You are part of a network',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _rose,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'People are allowed to help you. Even a small, honest message can '
                    'lighten a heavy day — for both of you.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      height: 1.5,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Who could you reach out to?',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in _whoToReachOutTo)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _rose.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.$2, size: 16, color: _rose),
                        const SizedBox(width: 6),
                        Text(
                          item.$1,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              'Small ways to start',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < _waysToStart.length; i++)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.borderGrey.withValues(alpha: 0.7),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: _roseLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.forum_outlined,
                        size: 13,
                        color: _rose,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _waysToStart[i],
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          height: 1.45,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4EFFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD8B4F8).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.softPurple,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reaching out is a skill like any other — it grows with practice. '
                      'One short message is a real step.',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        height: 1.45,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple connection/network illustration: "you" in the middle with trusted
/// people around you.
class _NetworkIllustration extends StatelessWidget {
  final double pulse;

  const _NetworkIllustration({required this.pulse});

  @override
  Widget build(BuildContext context) {
    const friends = [
      (dx: 0.0, dy: -0.52, icon: Icons.favorite_border_rounded),
      (dx: 0.50, dy: -0.16, icon: Icons.home_outlined),
      (dx: 0.31, dy: 0.42, icon: Icons.groups_rounded),
      (dx: -0.31, dy: 0.42, icon: Icons.support_agent_rounded),
      (dx: -0.50, dy: -0.16, icon: Icons.medical_services_outlined),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = math.min(constraints.maxWidth, 320.0);
        return SizedBox(
          height: 200,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                painter: _LinesPainter(),
                size: const Size(double.infinity, 200),
              ),
              for (final f in friends)
                Positioned(
                  left: (f.dx + 0.5) * w - 20,
                  top: (f.dy + 0.5) * 200 - 20,
                  child: Transform.scale(
                    scale: 1 + pulse * 0.06,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _roseLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: _rose.withValues(alpha: 0.5)),
                      ),
                      child: Icon(f.icon, size: 17, color: _rose),
                    ),
                  ),
                ),
              Transform.scale(
                scale: 1 + pulse * 0.10,
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF45B69C), Color(0xFF2E8B76)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E8B76).withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.self_improvement_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _rose.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    const friends = [
      (dx: 0.0, dy: -0.52),
      (dx: 0.50, dy: -0.16),
      (dx: 0.31, dy: 0.42),
      (dx: -0.31, dy: 0.42),
      (dx: -0.50, dy: -0.16),
    ];
    final center = Offset(size.width / 2, size.height / 2);
    for (final f in friends) {
      final target = Offset(
        (f.dx + 0.5) * size.width,
        (f.dy + 0.5) * size.height,
      );
      canvas.drawLine(center, target, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}