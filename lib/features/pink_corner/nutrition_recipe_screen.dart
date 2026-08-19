import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'data/nutrition_topic.dart';
import 'widgets/article_widgets.dart';

/// Detail screen for a single Nutrition recipe.
///
/// Shows ingredients, short preparation steps and an optional nutrition note,
/// with an animated step-by-step that advances one step at a time.
class NutritionRecipeScreen extends StatefulWidget {
  final NutritionRecipe recipe;

  const NutritionRecipeScreen({super.key, required this.recipe});

  @override
  State<NutritionRecipeScreen> createState() => _NutritionRecipeScreenState();
}

class _NutritionRecipeScreenState extends State<NutritionRecipeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stepController;
  Timer? _autoTimer;
  int _stepIndex = 0;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _stepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _stepController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _autoTimer?.cancel();
    setState(() {
      _stepIndex = index.clamp(0, widget.recipe.steps.length - 1);
    });
    _stepController.forward(from: 0);
    _scheduleNext();
  }

  void _togglePlay() {
    _autoTimer?.cancel();
    setState(() => _playing = !_playing);
    if (_playing) {
      _scheduleNext();
    }
  }

  void _scheduleNext() {
    if (!_playing) return;
    if (_stepIndex >= widget.recipe.steps.length - 1) {
      setState(() => _playing = false);
      return;
    }
    _autoTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted || !_playing) return;
      setState(() => _stepIndex++);
      _stepController.forward(from: 0);
      _scheduleNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final steps = recipe.steps;

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
          recipe.name,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(recipe),
            const SizedBox(height: 22),

            // Ingredients
            const ArticleSectionHeading(
              title: 'What you need',
              icon: Icons.shopping_basket_rounded,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.borderGrey.withValues(alpha: 0.6),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  for (var i = 0; i < recipe.ingredients.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == recipe.ingredients.length - 1 ? 0 : 10,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF0F3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: AppColors.peachCoral,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              recipe.ingredients[i],
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                height: 1.4,
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
            const SizedBox(height: 22),

            // Steps — animated one by one
            const ArticleSectionHeading(
              title: 'How to make it',
              icon: Icons.play_circle_outline_rounded,
            ),
            _buildStepPlayer(steps),
            const SizedBox(height: 18),

            // Nutrition note
            if (recipe.nutritionNote != null) ...[
              const ArticleSectionHeading(
                title: 'A note on this recipe',
                icon: Icons.info_outline_rounded,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
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
                      Icons.eco_rounded,
                      size: 18,
                      color: Color(0xFF45B69C),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        recipe.nutritionNote!,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          height: 1.5,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Educational note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF4EFFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFD8B4F8).withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppColors.softPurple,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Recipes are practical ideas, not medically prescribed meal plans. '
                      'Adjust portions, ingredients and cooking methods to what suits you — '
                      'and check with a professional if you have allergies or specific health needs.',
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

  Widget _buildHero(NutritionRecipe recipe) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF7ED), Color(0xFFFFF0F3)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFB085).withValues(alpha: 0.6),
          width: 1.2,
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
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              recipe.icon,
              size: 30,
              color: AppColors.peachCoral,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            recipe.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in recipe.categories)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.peachCoral.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.peachCoral,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 15,
                color: AppColors.textMedium,
              ),
              const SizedBox(width: 5),
              Text(
                recipe.prepTime,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.signal_cellular_alt_rounded,
                size: 15,
                color: AppColors.textMedium,
              ),
              const SizedBox(width: 5),
              Text(
                recipe.difficulty,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepPlayer(List<String> steps) {
    final progress = (steps.isEmpty ? 0.0 : (_stepIndex + 1) / steps.length)
        .clamp(0.0, 1.0)
        .toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Step ${_stepIndex + 1} of ${steps.length}',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.peachCoral,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _togglePlay,
                icon: Icon(
                  _playing ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
                  size: 26,
                  color: AppColors.peachCoral,
                ),
                tooltip: _playing ? 'Pause' : 'Play',
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFFFFF0F3),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.peachCoral),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < steps.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _stepIndex ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _stepIndex
                        ? AppColors.peachCoral
                        : AppColors.borderGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Container(
              key: ValueKey(_stepIndex),
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.peachCoral.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: AppColors.peachCoral,
                    child: Text(
                      '${_stepIndex + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      steps[_stepIndex],
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        height: 1.5,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _stepIndex == 0
                    ? null
                    : () => _goTo(_stepIndex - 1),
                icon: const Icon(Icons.arrow_back_rounded, size: 15),
                label: const Text('Previous'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textMedium,
                  textStyle: GoogleFonts.inter(fontSize: 11.5),
                ),
              ),
              TextButton.icon(
                onPressed: _stepIndex >= steps.length - 1
                    ? () => _goTo(0)
                    : () => _goTo(_stepIndex + 1),
                icon: Icon(
                  _stepIndex >= steps.length - 1
                      ? Icons.replay_rounded
                      : Icons.arrow_forward_rounded,
                  size: 15,
                ),
                label: Text(
                  _stepIndex >= steps.length - 1 ? 'Restart' : 'Next',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.peachCoral,
                  textStyle: GoogleFonts.inter(fontSize: 11.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}