import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'data/nutrition_topic.dart';
import 'data/nutrition_recipes.dart';
import 'data/nutrition_topics.dart';
import 'nutrition_recipe_screen.dart';
import 'nutrition_topic_detail_screen.dart';
import 'widgets/article_widgets.dart';

/// Entry screen for the Nutrition card inside Learn.
///
/// Shows educational topics grouped into Nutrition Basics, PCOS-Conscious
/// Eating and Indian Everyday Guides, plus a filterable recipe section.
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  String _selectedRecipeCategory = 'All';

  List<NutritionRecipe> get _visibleRecipes {
    if (_selectedRecipeCategory == 'All') return nutritionRecipes;
    return nutritionRecipes
        .where((r) => r.categories.contains(_selectedRecipeCategory))
        .toList(growable: false);
  }

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
          'Nutrition',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(),
            const SizedBox(height: 22),

            // Educational topics, grouped
            for (final group in nutritionGroups) ...[
              ArticleSectionHeading(title: group.name, icon: group.icon),
              for (final topic in group.topics)
                _NutritionTopicCard(
                  topic: topic,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NutritionTopicDetailScreen(topic: topic),
                      ),
                    );
                  },
                ),
            ],

            const SizedBox(height: 8),

            // Recipes
            const ArticleSectionHeading(
              title: 'Recipes',
              icon: Icons.menu_book_rounded,
            ),
            _buildRecipeIntro(),
            const SizedBox(height: 12),
            _buildCategoryChips(),
            const SizedBox(height: 14),
            _buildRecipeGrid(),

            const SizedBox(height: 20),

            // Educational disclaimer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFFFB085).withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppColors.peachCoral,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'These topics and recipes are educational, not a diagnosis or a treatment plan. '
                      'If you have a medical condition, allergy, eating disorder history, pregnancy, or take '
                      'medications, a healthcare professional or dietitian can guide what suits you best.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.5,
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

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF7ED), Color(0xFFFFF0F3)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFFB085).withValues(alpha: 0.6),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: AppColors.peachCoral,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Eat with kindness',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Simple, practical, non-judgmental food guidance — nutrition basics, '
                  'PCOS-conscious eating, everyday Indian meals, and easy recipes. '
                  'No rigid rules, no shame.',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    height: 1.5,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeIntro() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFB5EAD7).withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.soup_kitchen_rounded,
            size: 18,
            color: Color(0xFF45B69C),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Simple recipes built from familiar foods, including period-friendly meals. '
              'They are practical ideas — not medically prescribed meal plans.',
              style: GoogleFonts.inter(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: nutritionRecipeCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = nutritionRecipeCategories[index];
          final selected = _selectedRecipeCategory == category;
          return GestureDetector(
            onTap: () => setState(() => _selectedRecipeCategory = category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.peachCoral.withValues(alpha: 0.18)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.peachCoral
                      : AppColors.borderGrey.withValues(alpha: 0.8),
                  width: selected ? 1.6 : 1,
                ),
              ),
              child: Text(
                category,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.peachCoral
                      : AppColors.textMedium,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeGrid() {
    final recipes = _visibleRecipes;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return _RecipeCard(
          recipe: recipe,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NutritionRecipeScreen(recipe: recipe),
              ),
            );
          },
        );
      },
    );
  }
}

class _NutritionTopicCard extends StatelessWidget {
  final NutritionTopic topic;
  final VoidCallback onTap;

  const _NutritionTopicCard({required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: topic.backgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: topic.accentColor.withValues(alpha: 0.35),
                ),
              ),
              child: Icon(topic.icon, size: 22, color: topic.accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    topic.shortDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final NutritionRecipe recipe;
  final VoidCallback onTap;

  const _RecipeCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.peachCoral.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Icon(
                    recipe.icon,
                    size: 20,
                    color: AppColors.peachCoral,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          recipe.categories.first,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E8B76),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              recipe.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                height: 1.25,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 13,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  recipe.prepTime,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.signal_cellular_alt_rounded,
                  size: 13,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  recipe.difficulty,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                for (final tag in recipe.categories.skip(1).take(2))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F3),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.inter(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFC94A6E),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}