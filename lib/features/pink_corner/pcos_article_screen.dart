import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

            // IMAGE 1: Healthy Ovary vs PCOS Ovary
            ArticleImageCard(
              imageUrl: 'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=800',
              caption: 'Figure 1: Comparison between a Healthy Ovary and a PCOS Ovary with multiple underdeveloped follicles.',
              fallbackWidget: Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFF4EFFB),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 28),
                                const SizedBox(height: 6),
                                Text('Healthy Ovary', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text('Regular ovulation, 1 mature egg released per cycle.', style: GoogleFonts.inter(fontSize: 11), textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.softPurple.withValues(alpha: 0.4)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.bubble_chart_rounded, color: AppColors.softPurple, size: 28),
                                const SizedBox(height: 6),
                                Text('PCOS Ovary', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text('Multiple small follicles ("string of pearls"), irregular ovulation.', style: GoogleFonts.inter(fontSize: 11), textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

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

            // PCOS VS PCOD
            const ArticleSectionHeading(title: 'PCOS vs PCOD', icon: Icons.compare_arrows_rounded),
            Text(
              'While both conditions involve the ovaries, they differ significantly in severity, cause, and metabolic impact:',
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textDark),
            ),
            const SizedBox(height: 10),
            _buildComparisonTable(),

            // SYMPTOMS
            const ArticleSectionHeading(title: 'Symptoms', icon: Icons.healing_rounded),
            Text(
              'Hormonal imbalances manifest differently in every woman. Common signs to watch out for include:',
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textDark),
            ),
            
            // IMAGE 2: Symptoms Infographic
            ArticleImageCard(
              imageUrl: 'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?w=800',
              caption: 'Figure 2: Infographic highlighting the 6 primary symptoms of PCOS & PCOD.',
              fallbackWidget: Container(
                padding: const EdgeInsets.all(14),
                color: const Color(0xFFFAF8F5),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSymptomBadge('🩸 Irregular Periods', AppColors.deepRose, const Color(0xFFFFF0F3)),
                    _buildSymptomBadge('✨ Hormonal Acne', AppColors.softPurple, const Color(0xFFF4EFFB)),
                    _buildSymptomBadge('💇‍♀️ Hair Fall & Thinning', const Color(0xFF45B69C), const Color(0xFFF0FDF4)),
                    _buildSymptomBadge('🌸 Facial Hair (Hirsutism)', AppColors.peachCoral, const Color(0xFFFFF7ED)),
                    _buildSymptomBadge('⚖️ Unexplained Weight Gain', const Color(0xFF5B7FFF), const Color(0xFFF0F4FF)),
                    _buildSymptomBadge('🧠 Mood Changes & Fatigue', AppColors.softPurpleLight, const Color(0xFFF8F0FF)),
                  ],
                ),
              ),
            ),

            // CAUSES
            const ArticleSectionHeading(title: 'Causes', icon: Icons.psychology_rounded),
            Text(
              'While the exact root cause of PCOS is multifaceted, research highlights four key underlying factors:',
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            _buildCauseTile(context, 'Genetics', 'A family history of PCOS or insulin sensitivity increases your likelihood.'),
            _buildCauseTile(context, 'Insulin Resistance', 'High circulating insulin levels signal ovaries to secrete excess male hormones.'),
            _buildCauseTile(context, 'Low-Grade Inflammation', 'Chronic inflammation stimulates polycystic ovaries to produce androgens.'),
            _buildCauseTile(context, 'Hormonal Imbalance', 'Disrupted ratio between LH (Luteinizing Hormone) and FSH (Follicle-Stimulating Hormone).'),

            // INSULIN RESISTANCE
            const ArticleSectionHeading(title: 'Insulin Resistance', icon: Icons.grain_rounded),
            Text(
              'Insulin is a hormone produced by your pancreas that helps cells convert blood glucose into energy. When your cells become resistant to insulin, glucose accumulates in the bloodstream.',
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textDark),
            ),

            // IMAGE 3: Insulin Resistance Illustration
            ArticleImageCard(
              imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800',
              caption: 'Figure 3: Medical diagram of Insulin Resistance leading to androgen stimulation in ovaries.',
              fallbackWidget: Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFF4EFFB),
                child: Column(
                  children: [
                    Text('How Insulin Resistance Works:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.softPurple)),
                    const SizedBox(height: 8),
                    _buildStepRow('1', 'Pancreas secretes insulin to transport sugar into cells.'),
                    _buildStepRow('2', 'Receptors resist insulin, forcing pancreas to release excess insulin.'),
                    _buildStepRow('3', 'High insulin levels signal ovaries to overproduce testosterone.'),
                  ],
                ),
              ),
            ),

            // WEIGHT MANAGEMENT
            const ArticleSectionHeading(title: 'Weight Management', icon: Icons.restaurant_menu_rounded),
            Text(
              'Managing weight with PCOS is not about restrictive starvation diets; it is about nourishing your body with balanced, anti-inflammatory meals that keep blood sugar stable.',
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textDark),
            ),

            // IMAGE 4: Healthy Indian Plate
            ArticleImageCard(
              imageUrl: 'https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?w=800',
              caption: 'Figure 4: A balanced Indian Thali plate featuring multigrain Roti, Dal, Paneer, Sabzi, Brown Rice, and fresh Salad.',
              fallbackWidget: Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFF0FDF4),
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

            // EXERCISES
            const ArticleSectionHeading(title: 'Exercises', icon: Icons.fitness_center_rounded),
            Text(
              'Gentle, consistent movement improves insulin sensitivity without placing excessive stress on your adrenal glands.',
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textDark),
            ),

            // IMAGE 5: Exercise Illustration
            ArticleImageCard(
              imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800',
              caption: 'Figure 5: Recommended healthy movements for PCOS including brisk walking, yoga, and gentle strength exercises.',
              fallbackWidget: Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFF0F4FF),
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
                  ],
                ),
              ),
            ),

            // COMMON MYTHS
            const ArticleSectionHeading(title: 'Common Myths', icon: Icons.fact_check_rounded),
            _buildMythCard(context, 'Myth: PCOS means you can never get pregnant.', 'Fact: With proper lifestyle care and medical support, most women with PCOS conceive naturally.'),
            _buildMythCard(context, 'Myth: PCOS only affects overweight women.', 'Fact: "Lean PCOS" affects nearly 20% of women with normal BMI.'),
            _buildMythCard(context, 'Myth: PCOD and PCOS are identical.', 'Fact: PCOD is milder and lifestyle-driven; PCOS is a metabolic-endocrine condition.'),
            _buildMythCard(context, 'Myth: You must completely eliminate all carbohydrates.', 'Fact: Complex carbs like brown rice, oats, and millets provide steady fuel without blood sugar spikes.'),

            // RECOMMENDED VIDEOS
            const ArticleSectionHeading(title: 'Recommended Videos', icon: Icons.video_library_rounded),
            ArticleVideoCard(
              title: 'Understanding PCOS',
              description: 'A comprehensive medical guide explaining hormones, ovulation, and symptoms.',
              duration: '10 mins',
              onTap: () => _showVideoPlaceholder(context, 'Understanding PCOS'),
            ),
            ArticleVideoCard(
              title: 'PCOS Diet Explained',
              description: 'Learn how to construct anti-inflammatory Indian meals for insulin balance.',
              duration: '12 mins',
              onTap: () => _showVideoPlaceholder(context, 'PCOS Diet Explained'),
            ),
            ArticleVideoCard(
              title: 'Best Exercises for PCOS',
              description: 'Low-impact workout routine designed to lower cortisol and build muscle.',
              duration: '8 mins',
              onTap: () => _showVideoPlaceholder(context, 'Best Exercises for PCOS'),
            ),
            ArticleVideoCard(
              title: 'Lifestyle Tips for PCOS',
              description: 'Practical daily routines including seed cycling, sleep, and stress control.',
              duration: '15 mins',
              onTap: () => _showVideoPlaceholder(context, 'Lifestyle Tips for PCOS'),
            ),

            // TAKEAWAY
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    'Key Takeaway',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'PCOS & PCOD are highly manageable conditions. Small, consistent daily habits — balanced Indian meals, gentle movement, quality sleep, and self-compassion — will help you reclaim your hormonal harmony.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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

  Widget _buildCauseTile(BuildContext context, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.softPurple),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark, height: 1.4),
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildComparisonTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.6)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Table(
          border: TableBorder.symmetric(
            inside: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.6)),
          ),
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFF4EFFB)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text('Feature', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.softPurple)),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text('PCOD', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.softPurple)),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text('PCOS', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.softPurple)),
                ),
              ],
            ),
            _buildTableRow('Nature', 'Ovarian disease', 'Endocrine disorder'),
            _buildTableRow('Severity', 'Milder, common', 'More complex'),
            _buildTableRow('Prevalence', 'Up to 25% women', '10% of women'),
            _buildTableRow('Fertility', 'Low impact', 'Requires guidance'),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String feature, String pcod, String pcos) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(feature, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11)),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(pcod, style: GoogleFonts.inter(fontSize: 11)),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(pcos, style: GoogleFonts.inter(fontSize: 11)),
        ),
      ],
    );
  }

  void _showVideoPlaceholder(BuildContext context, String videoTitle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.softLavender,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_circle_fill_rounded, size: 48, color: AppColors.softPurple),
            ),
            const SizedBox(height: 16),
            Text(
              videoTitle,
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Video link preview. Full video playback integration will be available soon!',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMedium),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.softPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
