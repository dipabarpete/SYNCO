import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/article_widgets.dart';

class PcosArticleScreen extends StatelessWidget {
  const PcosArticleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Understanding PCOS & PCOD',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO SECTION
            Text(
              'Understanding PCOS & PCOD',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your guide to hormones, health, and feeling your best.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.softPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),

            // PMOS VIDEOS CAROUSEL
            const PmosVideoCarousel(),

            // INTRODUCTION
            const ArticleSectionHeading(title: 'Introduction', icon: Icons.explore_rounded),
            Text(
              'Polycystic Ovary Syndrome (PCOS) and Polycystic Ovarian Disease (PCOD) affect millions of women across India and around the globe. Despite being extremely common, they are often misunderstood or confused with one another.\n\nTaking charge of your reproductive and hormonal health starts with clear, medically backed knowledge. Let us explore what is happening inside your body and how you can thrive through simple, sustainable choices.',
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textDark),
            ),

            // WHAT IS PCOS?
            const ArticleSectionHeading(title: 'What is PCOS?', icon: Icons.medical_services_rounded),
            Text(
              'PCOS (Polycystic Ovary Syndrome) is a complex endocrine and metabolic disorder. In women with PCOS, the ovaries produce higher levels of androgens (male hormones like testosterone) than normal.',
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            ArticleInfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Key Features of PCOS:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.softPurple)),
                  const SizedBox(height: 6),
                  _buildBulletPoint('Elevated Androgen Levels: Leads to acne, facial hair growth, and scalp hair thinning.'),
                  _buildBulletPoint('Ovulatory Dysfunction: Irregular, prolonged, or absent menstrual cycles.'),
                  _buildBulletPoint('Metabolic Link: Frequently associated with insulin resistance and difficulty managing weight.'),
                ],
              ),
            ),

            // WHAT IS PCOD?
            const ArticleSectionHeading(title: 'What is PCOD?', icon: Icons.spa_rounded),
            Text(
              'PCOD (Polycystic Ovarian Disease) is a condition where the ovaries release immature or partially mature eggs during the menstrual cycle. Over time, these eggs form small sac-like fluid collections (cysts) in the ovaries.',
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            ArticleInfoCard(
              backgroundColor: const Color(0xFFFFF0F3),
              borderColor: const Color(0xFFFFD1DC),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Key Features of PCOD:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.deepRose)),
                  const SizedBox(height: 6),
                  _buildBulletPoint('Very Common: Affects nearly 1 in 4 young women today.'),
                  _buildBulletPoint('Lifestyle Driven: Triggered primarily by stress, unhealthy dietary patterns, and lack of activity.'),
                  _buildBulletPoint('Highly Reversible: Can be managed effectively through disciplined lifestyle habits without heavy medication.'),
                ],
              ),
            ),

            // SYMPTOMS
            const ArticleSectionHeading(title: 'Symptoms', icon: Icons.healing_rounded),
            Text(
              'Hormonal imbalances manifest differently in every woman. Common signs to watch out for include:',
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textDark),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSymptomBadge('🩸 Irregular Periods', AppColors.deepRose, const Color(0xFFFFF0F3)),
                _buildSymptomBadge('✨ Acne', AppColors.softPurple, const Color(0xFFF4EFFB)),
                _buildSymptomBadge('💇‍♀️ Hair Fall', const Color(0xFF45B69C), const Color(0xFFF0FDF4)),
                _buildSymptomBadge('🌸 Excess Facial Hair', AppColors.peachCoral, const Color(0xFFFFF7ED)),
                _buildSymptomBadge('⚖️ Weight Gain', const Color(0xFF5B7FFF), const Color(0xFFF0F4FF)),
                _buildSymptomBadge('🧠 Mood Swings', AppColors.softPurpleLight, const Color(0xFFF8F0FF)),
                _buildSymptomBadge('⚡ Fatigue', AppColors.peachCoral, const Color(0xFFFFF7ED)),
                _buildSymptomBadge('👶 Difficulty Conceiving', AppColors.deepRose, const Color(0xFFFFF0F3)),
              ],
            ),

            // 2. CAUSES (Single purple card with NO divider lines)
            const ArticleSectionHeading(title: 'Causes', icon: Icons.psychology_rounded),
            Text(
              'While the exact root cause of PCOS is multifaceted, research highlights four key underlying factors:',
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            ArticleInfoCard(
              backgroundColor: const Color(0xFFF4EFFB),
              borderColor: const Color(0xFFD8B4F8).withValues(alpha: 0.6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSingleCardCauseItem(
                    icon: Icons.bubble_chart_rounded,
                    title: 'Hormonal Imbalance',
                    desc: 'Disrupted ratio between LH (Luteinizing Hormone) and FSH (Follicle-Stimulating Hormone).',
                  ),
                  const SizedBox(height: 12),
                  _buildSingleCardCauseItem(
                    icon: Icons.grain_rounded,
                    title: 'Insulin Resistance',
                    desc: 'High circulating insulin levels signal ovaries to secrete excess male hormones.',
                  ),
                  const SizedBox(height: 12),
                  _buildSingleCardCauseItem(
                    icon: Icons.family_restroom_rounded,
                    title: 'Genetics',
                    desc: 'A family history of PCOS or insulin sensitivity increases your likelihood.',
                  ),
                  const SizedBox(height: 12),
                  _buildSingleCardCauseItem(
                    icon: Icons.local_fire_department_rounded,
                    title: 'Chronic Inflammation',
                    desc: 'Low-grade chronic inflammation stimulates polycystic ovaries to produce androgens.',
                  ),
                ],
              ),
            ),

            // INSULIN RESISTANCE
            const ArticleSectionHeading(title: 'Insulin Resistance', icon: Icons.grain_rounded),
            Text(
              'Insulin is a hormone produced by your pancreas that helps cells convert blood glucose into energy. When your cells become resistant to insulin, glucose accumulates in the bloodstream.',
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            ArticleInfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How Insulin Resistance Works:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.softPurple)),
                  const SizedBox(height: 8),
                  _buildStepRow('1', 'Pancreas secretes insulin to transport sugar into cells.'),
                  _buildStepRow('2', 'Receptors resist insulin, forcing pancreas to release excess insulin.'),
                  _buildStepRow('3', 'High insulin levels signal ovaries to overproduce testosterone.'),
                ],
              ),
            ),

            // WEIGHT MANAGEMENT
            const ArticleSectionHeading(title: 'Weight Management', icon: Icons.restaurant_menu_rounded),
            Text(
              'Managing weight with PCOS is not about restrictive starvation diets; it is about nourishing your body with balanced, anti-inflammatory meals that keep blood sugar stable.',
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            ArticleInfoCard(
              backgroundColor: const Color(0xFFF0FDF4),
              borderColor: const Color(0xFFB5EAD7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Healthy Balanced Indian Thali Plate:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF2E8B57))),
                  const SizedBox(height: 8),
                  _buildBulletPoint('🌾 Complex Carbs: Multigrain Roti / Jowar Roti or Brown Rice.'),
                  _buildBulletPoint('🍲 Plant & Lean Protein: Yellow Dal, Chana, Rajma, or Grilled Paneer.'),
                  _buildBulletPoint('🥬 Fiber & Micronutrients: Green Sabzi (Palak, Bhindi, Gobhi).'),
                  _buildBulletPoint('🥗 Raw Fiber: Cucumber, Tomato, Beetroot Salad with Lemon.'),
                ],
              ),
            ),

            // TREATMENT OPTIONS
            const ArticleSectionHeading(title: 'Treatment Options', icon: Icons.local_hospital_rounded),
            Text(
              'Treatment for PCOS is personalized based on your individual goals (e.g., cycle regulation, acne control, or fertility support):',
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            ArticleInfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletPoint('Medical Management: Consult a gynecologist or endocrinologist for tailored medical advice.'),
                  _buildBulletPoint('Inositol Supplements: Myo-inositol & D-chiro-inositol help restore ovulatory function and insulin sensitivity.'),
                  _buildBulletPoint('Essential Vitamins: Vitamin D3, Omega-3 fatty acids, and Magnesium support ovarian follicle health.'),
                ],
              ),
            ),

            // LIFESTYLE MANAGEMENT
            const ArticleSectionHeading(title: 'Lifestyle Management', icon: Icons.self_improvement_rounded),
            Text(
              'Simple daily habits create massive long-term improvements in hormonal balance:',
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            ArticleInfoCard(
              backgroundColor: const Color(0xFFFFF7ED),
              borderColor: const Color(0xFFFFB085),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Hormonal Habits:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.peachCoral)),
                  const SizedBox(height: 6),
                  _buildBulletPoint('🌱 Seed Cycling: Flax & pumpkin seeds in Days 1-14; sunflower & sesame in Days 15-28.'),
                  _buildBulletPoint('☕ Spearmint Tea: 1-2 cups daily helps lower free testosterone levels.'),
                  _buildBulletPoint('😴 Quality Sleep: 7-8 hours of restful sleep reduces cortisol (stress hormone) spikes.'),
                ],
              ),
            ),

            // 3. REORDERED: COMMON MYTHS (Moved before Exercises)
            const ArticleSectionHeading(title: 'Common Myths', icon: Icons.fact_check_rounded),
            _buildMythCard(context, 'Myth: PCOS means you can never get pregnant.', 'Fact: With proper lifestyle care and medical support, most women with PCOS conceive naturally.'),
            _buildMythCard(context, 'Myth: PCOS only affects overweight women.', 'Fact: "Lean PCOS" affects nearly 20% of women with normal BMI.'),
            _buildMythCard(context, 'Myth: PCOD and PCOS are identical.', 'Fact: PCOD is milder and lifestyle-driven; PCOS is a metabolic-endocrine condition.'),
            _buildMythCard(context, 'Myth: You must completely eliminate all carbohydrates.', 'Fact: Complex carbs like brown rice, oats, and millets provide steady fuel without blood sugar spikes.'),

            // 3. REORDERED: EXERCISES (Moved after Common Myths)
            const ArticleSectionHeading(title: 'Exercises', icon: Icons.fitness_center_rounded),
            Text(
              'Gentle, consistent movement improves insulin sensitivity without placing excessive stress on your adrenal glands.',
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            ArticleInfoCard(
              backgroundColor: const Color(0xFFF0F4FF),
              borderColor: const Color(0xFFC7CEEA),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildExerciseBadge('🚶‍♀️ Brisk Walking', '30 mins daily'),
                      const SizedBox(width: 8),
                      _buildExerciseBadge('🧘‍♀️ Hormone Yoga', 'Asanas for pelvis'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildExerciseBadge('🏋️‍♀️ Strength Training', '2-3x per week'),
                      const SizedBox(width: 8),
                      _buildExerciseBadge('🚴‍♀️ Gentle Cycling', 'Low impact cardio'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildExerciseBadge('🏊‍♀️ Swimming', 'Full body workout'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.borderGrey.withValues(alpha: 0.6),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/images/yoga_poses_pcos.png',
                  width: double.infinity,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      color: const Color(0xFFF0F4FF),
                      child: const Center(
                        child: Icon(Icons.self_improvement_rounded, size: 48, color: AppColors.softPurple),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.softPurple)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 13, height: 1.4, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomBadge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }

  Widget _buildSingleCardCauseItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.softPurple),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.4,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepRow(String number, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.softPurple,
            child: Text(number, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(desc, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseBadge(String title, String desc) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC7CEEA)),
        ),
        child: Column(
          children: [
            Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 2),
            Text(desc, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMedium)),
          ],
        ),
      ),
    );
  }

  Widget _buildMythCard(BuildContext context, String myth, String fact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  myth,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  fact,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDark, height: 1.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PmosVideoItem {
  final String title;
  final String videoUrl;
  final String videoId;

  const PmosVideoItem({
    required this.title,
    required this.videoUrl,
    required this.videoId,
  });

  String get thumbnailUrl => 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
}

final List<PmosVideoItem> _pmosVideos = const [
  PmosVideoItem(
    title: 'Understanding PMOS',
    videoUrl: 'https://youtu.be/RMWy9_CQZxc?si=scnFPjmC5EAFlC_b',
    videoId: 'RMWy9_CQZxc',
  ),
  PmosVideoItem(
    title: 'PCOS Diet Explained',
    videoUrl: 'https://youtu.be/Wvs_lIqg2RU?si=_F33jtNaYkybLIZk',
    videoId: 'Wvs_lIqg2RU',
  ),
  PmosVideoItem(
    title: 'Best Yoga for PMOS',
    videoUrl: 'https://youtu.be/GTVvhMPSoE8?si=L3T1wtEAfgc9tUka',
    videoId: 'GTVvhMPSoE8',
  ),
  PmosVideoItem(
    title: 'Lifestyle Tips for PMOS',
    videoUrl: 'https://youtu.be/I94SJM07PSE?si=UzS2zisX0v-JhML9',
    videoId: 'I94SJM07PSE',
  ),
];

class PmosVideoCarousel extends StatefulWidget {
  const PmosVideoCarousel({super.key});

  @override
  State<PmosVideoCarousel> createState() => _PmosVideoCarouselState();
}

class _PmosVideoCarouselState extends State<PmosVideoCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openYouTubeVideo(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Could not launch $url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const ArticleSectionHeading(
          title: 'PMOS Videos',
          icon: Icons.play_circle_fill_rounded,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _pmosVideos.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final video = _pmosVideos[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _openYouTubeVideo(video.videoUrl),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.borderGrey.withValues(alpha: 0.6),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  video.thumbnailUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.softLavender,
                                      child: const Center(
                                        child: Icon(
                                          Icons.ondemand_video_rounded,
                                          size: 44,
                                          color: AppColors.softPurple,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Container(
                                  color: Colors.black.withValues(alpha: 0.15),
                                ),
                                Center(
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.softPurple.withValues(alpha: 0.88),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  video.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.open_in_new_rounded,
                                size: 16,
                                color: AppColors.softPurple,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _pmosVideos.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? AppColors.softPurple
                    : AppColors.softPurple.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
