import 'package:flutter/material.dart';
import 'exercise_workout.dart';

/// Beginner-friendly guided workouts shown in the Exercise & Movement section.
///
/// All workouts are bodyweight or household-friendly, keep the intensity
/// low, and never prescribe pushing through pain. Timers guide each step.
const List<ExerciseWorkout> allExerciseWorkouts = [
  // -------------------------------------------------------------------------
  // 1. BEGINNER 15-MINUTE WORKOUT
  // -------------------------------------------------------------------------
  ExerciseWorkout(
    id: 'beginner-15-min',
    title: 'Beginner 15-Minute Workout',
    subtitle: 'A friendly full-body warm-up, movement and cool-down.',
    durationMinutes: 15,
    difficulty: 'Beginner',
    activityType: 'general',
    equipment: 'None — bodyweight only',
    gentleNote:
        'This routine is designed to be comfortable. If a step feels too much, sit it out or repeat the rest step.',
    icon: Icons.timer_rounded,
    accentColor: Color(0xFF5B7FFF),
    backgroundColor: Color(0xFFF0F4FF),
    steps: [
      ExerciseStep(
        name: 'March in place',
        detail: 'Gentle marching with soft knees and natural arm swings.',
        seconds: 90,
        icon: Icons.directions_walk_rounded,
      ),
      ExerciseStep(
        name: 'Shoulder rolls',
        detail: 'Roll shoulders back slowly, then forward, breathing easy.',
        seconds: 60,
        icon: Icons.autorenew_rounded,
      ),
      ExerciseStep(
        name: 'Wall push-ups',
        detail: 'Hands on a wall at shoulder height — bend elbows, push back gently.',
        seconds: 90,
        icon: Icons.fitness_center_rounded,
      ),
      ExerciseStep(
        name: 'Sit-to-stand',
        detail: 'From a sturdy chair: stand up slowly, sit back down slowly.',
        seconds: 90,
        icon: Icons.chair_alt_rounded,
      ),
      ExerciseStep(
        name: 'Rest & breathe',
        detail: 'Shake out arms and legs, take slow breaths.',
        seconds: 60,
        icon: Icons.air_rounded,
      ),
      ExerciseStep(
        name: 'Glute bridges',
        detail: 'On your back, knees bent — lift hips gently, lower slowly.',
        seconds: 90,
        icon: Icons.accessibility_new_rounded,
      ),
      ExerciseStep(
        name: 'Calf raises',
        detail: 'Standing near support, rise onto toes slowly and lower.',
        seconds: 60,
        icon: Icons.trending_up_rounded,
      ),
      ExerciseStep(
        name: 'Rest & breathe',
        detail: 'Easy breaths, soft shoulders, let the body settle.',
        seconds: 60,
        icon: Icons.air_rounded,
      ),
      ExerciseStep(
        name: 'Standing side stretch',
        detail: 'Reach one arm overhead and lean gently to the side. Switch.',
        seconds: 90,
        icon: Icons.open_with_rounded,
      ),
      ExerciseStep(
        name: 'Slow breathing',
        detail: 'In through the nose, out slowly — let the heart rate settle.',
        seconds: 90,
        icon: Icons.spa_outlined,
      ),
      ExerciseStep(
        name: 'Neck & shoulder release',
        detail: 'Slow neck circles and shoulder shrugs, staying soft.',
        seconds: 60,
        icon: Icons.self_improvement_rounded,
      ),
      ExerciseStep(
        name: 'Final rest',
        detail: 'Sit or lie down — the workout is done. Well done.',
        seconds: 60,
        icon: Icons.emoji_people_rounded,
      ),
    ],
  ),

  // -------------------------------------------------------------------------
  // 2. STRENGTH TRAINING FOR BEGINNERS
  // -------------------------------------------------------------------------
  ExerciseWorkout(
    id: 'strength-beginners',
    title: 'Strength Training for Beginners',
    subtitle: 'Squat, push, glute and core basics — with rest built in.',
    durationMinutes: 12,
    difficulty: 'Beginner',
    activityType: 'strength',
    equipment: 'None — bodyweight only',
    gentleNote:
        'Move slowly and in control. Stop while it still feels doable — you can always do fewer repetitions.',
    icon: Icons.fitness_center_rounded,
    accentColor: Color(0xFF7B4397),
    backgroundColor: Color(0xFFF4EFFB),
    steps: [
      ExerciseStep(
        name: 'Gentle march',
        detail: 'A slow warm-up march to get the body ready.',
        seconds: 60,
        icon: Icons.directions_walk_rounded,
      ),
      ExerciseStep(
        name: 'Chair squats',
        detail: 'Squat variation: sink toward a chair, stand back up slowly.',
        seconds: 75,
        icon: Icons.chair_alt_rounded,
      ),
      ExerciseStep(
        name: 'Wall push-ups',
        detail: 'Push movement: hands on the wall, gentle elbow bends.',
        seconds: 75,
        icon: Icons.fitness_center_rounded,
      ),
      ExerciseStep(
        name: 'Glute bridges',
        detail: 'Hip & glute: lift hips slowly, squeeze gently, lower.',
        seconds: 75,
        icon: Icons.accessibility_new_rounded,
      ),
      ExerciseStep(
        name: 'Standing knee lifts',
        detail: 'Core: lift one knee at a time while staying tall.',
        seconds: 60,
        icon: Icons.airline_seat_recline_normal_rounded,
      ),
      ExerciseStep(
        name: 'Rest & breathe',
        detail: 'A short recovery between rounds.',
        seconds: 45,
        icon: Icons.air_rounded,
      ),
      ExerciseStep(
        name: 'Chair squats — round 2',
        detail: 'Sink and rise slowly, at your own comfortable pace.',
        seconds: 60,
        icon: Icons.chair_alt_rounded,
      ),
      ExerciseStep(
        name: 'Wall push-ups — round 2',
        detail: 'Keep elbows soft and the movement small and controlled.',
        seconds: 60,
        icon: Icons.fitness_center_rounded,
      ),
      ExerciseStep(
        name: 'Glute bridges — round 2',
        detail: 'Lift and lower with control, breathing out on the lift.',
        seconds: 60,
        icon: Icons.accessibility_new_rounded,
      ),
      ExerciseStep(
        name: 'Standing knee lifts — round 2',
        detail: 'Gentle core work — no need to lift high.',
        seconds: 45,
        icon: Icons.airline_seat_recline_normal_rounded,
      ),
      ExerciseStep(
        name: 'Hamstring & chest stretch',
        detail: 'A gentle cool-down stretch for the legs and chest.',
        seconds: 90,
        icon: Icons.open_with_rounded,
      ),
    ],
  ),

  // -------------------------------------------------------------------------
  // 3. LOW-IMPACT WORKOUT
  // -------------------------------------------------------------------------
  ExerciseWorkout(
    id: 'low-impact',
    title: 'Low-Impact Workout',
    subtitle: 'No jumping, no impact — gentle on your joints.',
    durationMinutes: 10,
    difficulty: 'Beginner',
    activityType: 'gentle',
    equipment: 'None — bodyweight only',
    gentleNote:
        'Every step keeps at least one foot on the ground. Take it at whatever pace feels comfortable.',
    icon: Icons.sailing_rounded,
    accentColor: Color(0xFF45B69C),
    backgroundColor: Color(0xFFE2F5EE),
    steps: [
      ExerciseStep(
        name: 'Gentle march',
        detail: 'March softly in place — feet stay close to the ground.',
        seconds: 60,
        icon: Icons.directions_walk_rounded,
      ),
      ExerciseStep(
        name: 'Step-touch',
        detail: 'Step one foot out, bring the other to meet it. Then switch sides.',
        seconds: 60,
        icon: Icons.stay_current_portrait_rounded,
      ),
      ExerciseStep(
        name: 'Sit-to-stand',
        detail: 'Stand and sit from a sturdy chair — slow and steady.',
        seconds: 60,
        icon: Icons.chair_alt_rounded,
      ),
      ExerciseStep(
        name: 'Wall push-ups',
        detail: 'Push away gently from a wall — small, controlled bends.',
        seconds: 60,
        icon: Icons.fitness_center_rounded,
      ),
      ExerciseStep(
        name: 'Rest & breathe',
        detail: 'Catch your breath — you are doing great.',
        seconds: 45,
        icon: Icons.air_rounded,
      ),
      ExerciseStep(
        name: 'Glute bridges',
        detail: 'Lift hips gently from the floor and lower with control.',
        seconds: 60,
        icon: Icons.accessibility_new_rounded,
      ),
      ExerciseStep(
        name: 'Standing heel taps',
        detail: 'Tap one heel forward in front of you, then the other.',
        seconds: 60,
        icon: Icons.hearing_rounded,
      ),
      ExerciseStep(
        name: 'Calf raises',
        detail: 'Rise slowly onto your toes and lower — no bounce needed.',
        seconds: 45,
        icon: Icons.trending_up_rounded,
      ),
      ExerciseStep(
        name: 'Standing reach',
        detail: 'Reach both arms up slowly, then lower — a gentle cool-down.',
        seconds: 60,
        icon: Icons.open_with_rounded,
      ),
      ExerciseStep(
        name: 'Slow breathing',
        detail: 'Long, easy breaths to finish. Lovely work.',
        seconds: 60,
        icon: Icons.spa_outlined,
      ),
    ],
  ),

  // -------------------------------------------------------------------------
  // 4. YOGA FOR RELAXATION
  // -------------------------------------------------------------------------
  ExerciseWorkout(
    id: 'yoga-relaxation',
    title: 'Yoga for Relaxation',
    subtitle: 'Comfortable movement, breathing and rest — that is all.',
    durationMinutes: 10,
    difficulty: 'Everyone',
    activityType: 'yoga',
    equipment: 'None — a mat, towel or bed surface is optional',
    gentleNote:
        'This is not about perfect poses. Move only as far as feels comfortable, and rest whenever you want.',
    icon: Icons.self_improvement_rounded,
    accentColor: Color(0xFF9D76C1),
    backgroundColor: Color(0xFFF5EEFC),
    steps: [
      ExerciseStep(
        name: 'Gentle seated breathing',
        detail: 'Sit comfortably. Let your breath slow naturally.',
        seconds: 90,
        icon: Icons.spa_outlined,
      ),
      ExerciseStep(
        name: 'Slow neck circles',
        detail: 'Roll your neck slowly in each direction — small and gentle.',
        seconds: 60,
        icon: Icons.autorenew_rounded,
      ),
      ExerciseStep(
        name: 'Gentle spine waves',
        detail: 'Seated cat–cow: soften and round the spine slowly with breath.',
        seconds: 90,
        icon: Icons.waves_rounded,
      ),
      ExerciseStep(
        name: 'Child\u2019s pose',
        detail: 'Rest knees down, arms forward, forehead relaxed. Breathe.',
        seconds: 90,
        icon: Icons.self_improvement_rounded,
      ),
      ExerciseStep(
        name: 'Seated side stretch',
        detail: 'Reach one arm over gently and breathe into the side. Switch.',
        seconds: 60,
        icon: Icons.open_with_rounded,
      ),
      ExerciseStep(
        name: 'Slow forward fold',
        detail: 'Optional: bend forward softly over your legs — or skip it.',
        seconds: 60,
        icon: Icons.keyboard_double_arrow_down_rounded,
      ),
      ExerciseStep(
        name: 'Rest pose',
        detail: 'Lie down or sit back. Let go of effort completely.',
        seconds: 90,
        icon: Icons.bedtime_outlined,
      ),
      ExerciseStep(
        name: 'Closing breaths',
        detail: 'Three slow, full breaths — and congratulations on showing up.',
        seconds: 60,
        icon: Icons.self_improvement_rounded,
      ),
    ],
  ),

  // -------------------------------------------------------------------------
  // 5. MOVEMENT FOR LOW-ENERGY DAYS
  // -------------------------------------------------------------------------
  ExerciseWorkout(
    id: 'low-energy',
    title: 'Movement for Low-Energy Days',
    subtitle: 'A lighter version of movement for days when energy is low.',
    durationMinutes: 7,
    difficulty: 'Gentle',
    activityType: 'gentle',
    equipment: 'None — most steps can be done seated',
    gentleNote:
        'Some days need a lighter version of movement — not "you must exercise every day". '
        'If you feel significantly unwell or dangerously fatigued, rest is the right choice.',
    icon: Icons.bolt_rounded,
    accentColor: Color(0xFFE8A33D),
    backgroundColor: Color(0xFFFFF7E8),
    steps: [
      ExerciseStep(
        name: 'Easy walking in place',
        detail: 'Very slow stepping, or a short stroll around the room.',
        seconds: 90,
        icon: Icons.directions_walk_rounded,
      ),
      ExerciseStep(
        name: 'Slow shoulder rolls',
        detail: 'Small, soft shoulder circles — seated or standing.',
        seconds: 60,
        icon: Icons.autorenew_rounded,
      ),
      ExerciseStep(
        name: 'Gentle hip shifts',
        detail: 'Rock gently from side to side, staying within comfort.',
        seconds: 60,
        icon: Icons.waves_rounded,
      ),
      ExerciseStep(
        name: 'Comfortable stretching',
        detail: 'A few easy stretches only as far as your body allows.',
        seconds: 90,
        icon: Icons.open_with_rounded,
      ),
      ExerciseStep(
        name: 'Short breathing break',
        detail: 'A few minutes of slow breathing — effort-free.',
        seconds: 90,
        icon: Icons.spa_outlined,
      ),
      ExerciseStep(
        name: 'Finish with rest',
        detail: 'Be proud of yourself. Rest is part of caring for you.',
        seconds: 60,
        icon: Icons.bedtime_outlined,
      ),
    ],
  ),
];