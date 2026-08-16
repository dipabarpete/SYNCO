import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../auth/providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import '../cycle/my_cycle_screen.dart';
import 'widgets/app_bar_header.dart';
import 'widgets/dashboard_hero_header.dart';
import 'widgets/health_score_card.dart';
import 'widgets/period_cycle_overview_card.dart';
import 'widgets/dashboard_feature_row.dart';
import 'widgets/symptoms_assessment_card.dart';
import 'widgets/upcoming_reminders_card.dart';
import '../whisper_room/notifications_screen.dart';
import '../health/screens/health_report_screen.dart';
class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  late final ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      if (offset >= 0 && offset <= 220) {
        setState(() {
          _scrollOffset = offset;
        });
      } else if (_scrollOffset < 220 && offset > 220) {
        setState(() {
          _scrollOffset = 220;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final cycleState = ref.watch(cycleProvider);
    final healthScoreState = ref.watch(healthScoreProvider);

    final firstName = _resolveFirstName(authState);
    final displayName = _resolveDisplayName(authState);
    final avatarUrl = authState.userProfile?.avatarUrl ?? '';

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 360;
    final maxHeroHeight = isCompact ? 142.0 : 155.0;
    const collapseThreshold = 135.0;

    final progress = (_scrollOffset / collapseThreshold).clamp(0.0, 1.0);
    final currentHeroHeight = maxHeroHeight * (1.0 - progress);
    final currentGapHeight = 18.0 * (1.0 - progress);
    final heroOpacity = (1.0 - progress * 1.15).clamp(0.0, 1.0);
    final heroScale = 1.0 - (progress * 0.18);
    final heroParallaxY = -progress * 28.0;
    final textParallaxY = -progress * 18.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 0. FIXED FULL-SCREEN BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/images/dashboard_background.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // DASHBOARD CONTENT
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. APP BAR
                  AppBarHeader(
                    userName: displayName,
                    avatarUrl: avatarUrl,
                    onAvatarTap: () => _showProfileDialog(context, ref, displayName, authState),
                    onNotificationTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20 * (1.0 - progress * 0.3)),

                  // 2. DASHBOARD HERO GREETING (SCROLL COLLAPSIBLE)
                  if (currentHeroHeight > 0.5)
                    SizedBox(
                      height: currentHeroHeight,
                      child: ClipRect(
                        child: DashboardHeroHeader(
                          firstName: firstName,
                          heroScale: heroScale,
                          heroParallaxY: heroParallaxY,
                          textParallaxY: textParallaxY,
                          opacity: heroOpacity,
                        ),
                      ),
                    ),
                  SizedBox(height: currentGapHeight),

              // 3. PERIOD CYCLE OVERVIEW
              if (cycleState.isLoading)
                const Center(child: CircularProgressIndicator(color: AppColors.softPurple))
              else
                PeriodCycleOverviewCard(
                  currentPhase: cycleState.currentPhase,
                  currentDay: cycleState.currentDay,
                  totalDays: cycleState.activeCycle?.cycleLength ?? 28,
                  daysUntilNextPeriod: cycleState.daysUntilNextPeriod,
                  fertilityWindow: 'Days 11–16', // Keeping mock string for now
                  daysUntilOvulation: 14 - cycleState.currentDay > 0 ? 14 - cycleState.currentDay : 0,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => const MyCycleScreen(),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 18),

              // 4. NEW 3-FEATURE ROW (Food Scanner | Kyra AI | Lab Report Interpreter)
              const DashboardFeatureRow(),
              const SizedBox(height: 20),

              // 5. HEALTH SCORE CARD (Hero Card)
              HealthScoreCard(
                score: healthScoreState.score,
                percentile: healthScoreState.percentile,
                title: 'Health Score',
                onTap: () => _showDialogInfo(context, 'Health Score Details'),
                onViewReportTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HealthReportScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // 6. SYMPTOMS ASSESSMENT CARD
              const SymptomsAssessmentCard(),
              const SizedBox(height: 24),

              // 7. UPCOMING REMINDERS
              const UpcomingRemindersCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ],
  ),
);
  }

  String _resolveDisplayName(AuthState authState) {
    final username = authState.userProfile?.username ?? '';
    if (username.trim().isNotEmpty) {
      return username.trim();
    }

    final email = authState.userProfile?.email ?? authState.user?.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    final phone = authState.userProfile?.phone ?? authState.user?.phone;
    if (phone != null && phone.trim().isNotEmpty) {
      return 'User';
    }

    return 'Ananya';
  }

  String _resolveFirstName(AuthState authState) {
    final username = authState.userProfile?.username ?? '';
    if (username.trim().isNotEmpty) {
      return _capitalizeFirst(username.trim().split(RegExp(r'\s+')).first);
    }

    final email = authState.userProfile?.email ?? authState.user?.email;
    if (email != null && email.contains('@')) {
      final localPart = email.split('@').first.trim();
      if (localPart.isNotEmpty) {
        return _capitalizeFirst(localPart.split(RegExp(r'[._-]')).first);
      }
    }

    final phone = authState.userProfile?.phone ?? authState.user?.phone;
    if (phone != null && phone.trim().isNotEmpty) {
      return 'User';
    }

    return 'Ananya';
  }

  String _capitalizeFirst(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }



  void _showProfileDialog(
    BuildContext context,
    WidgetRef ref,
    String userName,
    AuthState authState,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.creamWhite,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.babyPink,
                child: Icon(Icons.person_rounded, color: AppColors.softPurple),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    (authState.userProfile?.email ?? authState.user?.email) ??
                        (authState.userProfile?.phone ?? authState.user?.phone) ??
                        'SYNCO Account',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.verified_user_outlined, size: 18, color: AppColors.softPurple),
                const SizedBox(width: 10),
                Text(
                  'Account Status: Active',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteAccount(context, ref);
              },
              child: Row(
                children: [
                  const Icon(Icons.delete_forever_rounded, size: 18, color: AppColors.deepRose),
                  const SizedBox(width: 10),
                  Text(
                    'Delete Account & Data',
                    style: GoogleFonts.inter(
                      fontSize: 13, 
                      color: AppColors.deepRose,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Close',
              style: GoogleFonts.inter(color: AppColors.textMedium),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authNotifierProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.white),
            label: Text(
              'Log Out',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepRose,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.creamWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Account?',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.deepRose,
          ),
        ),
        content: Text(
          'This action is irreversible. All your profile data, chat history, and appointments will be permanently deleted. Do you wish to proceed?',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepRose,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final authService = ref.read(authServiceProvider);
        await authService.deleteAccount();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.deepRose,
            ),
          );
        }
      }
    }
  }

  void _showDialogInfo(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          featureName,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '$featureName dashboard component tapped.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
