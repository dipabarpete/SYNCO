import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';

import '../../../core/backend.dart';

/// Utility to populate Cloud Firestore with realistic sample health tracker
/// data for August 16, 17, and 18, 2026 under the authenticated user's UID.
///
/// Uses deterministic document & map keys (`seed_2026_08_16_*`) so running this
/// operation multiple times is idempotent and never creates duplicate records.
class HealthDataSeeder {
  HealthDataSeeder._();

  static CollectionReference<Map<String, dynamic>>? get _dailyLogsCollection {
    final firestore = Backend.firestore;
    if (firestore == null) return null;
    try {
      final uid = fb.FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;
      return firestore.collection('users').doc(uid).collection('daily_logs');
    } catch (_) {
      return null;
    }
  }

  /// Seeds realistic health records for August 16, 17, and 18, 2026 in Firestore.
  static Future<bool> seedSampleData() async {
    final firestore = Backend.firestore;
    if (firestore == null) return false;

    String? uid;
    try {
      uid = fb.FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return false;
    }

    if (uid == null) return false;

    final collection = firestore.collection('users').doc(uid).collection('daily_logs');

    try {
      // -----------------------------------------------------------------------
      // AUGUST 16, 2026
      // -----------------------------------------------------------------------
      await collection.doc('2026-08-16').set({
        'date': '2026-08-16',
        'sleep_entries': {
          'seed_sleep': {
            'user_id': uid,
            'date': '2026-08-16',
            'start_minutes': 1410, // 23:30
            'end_minutes': 450, // 07:30
            'duration_minutes': 480, // 8h
            'quality': 'Good',
            'factors': ['Early bedtime', 'Earplugs'],
            'created_at': '2026-08-16T07:30:00.000Z',
            'updated_at': '2026-08-16T07:30:00.000Z',
          }
        },
        'water_entries': {
          'seed_water': {
            'user_id': uid,
            'date': '2026-08-16',
            'quantity': 2.4,
            'unit': 'L',
            'hydration_level': 'Good',
            'time_minutes': 900,
            'created_at': '2026-08-16T15:00:00.000Z',
            'updated_at': '2026-08-16T15:00:00.000Z',
          }
        },
        'step_entries': {
          'seed_steps': {
            'user_id': uid,
            'date': '2026-08-16',
            'count': 8450,
            'source': 'manual',
            'created_at': '2026-08-16T21:00:00.000Z',
            'updated_at': '2026-08-16T21:00:00.000Z',
          }
        },
        'sugar_craving_entries': {
          'seed_sugar': {
            'user_id': uid,
            'date': '2026-08-16',
            'craving': 'Dark chocolate with almonds',
            'level': 'Low',
            'time_minutes': 960,
            'created_at': '2026-08-16T16:00:00.000Z',
            'updated_at': '2026-08-16T16:00:00.000Z',
          }
        },
        'supplement_entries': {
          'seed_supplements': {
            'user_id': uid,
            'date': '2026-08-16',
            'name': 'Inositol & Vitamin D3',
            'taken': true,
            'time_minutes': 480,
            'created_at': '2026-08-16T08:00:00.000Z',
            'updated_at': '2026-08-16T08:00:00.000Z',
          }
        },
        'mental_wellness_entries': {
          'seed_wellness': {
            'user_id': uid,
            'date': '2026-08-16',
            'mood': 'Calm',
            'energy_level': 'High',
            'notes': 'Felt refreshed after morning yoga session.',
            'created_at': '2026-08-16T09:00:00.000Z',
            'updated_at': '2026-08-16T09:00:00.000Z',
          }
        },
        'food_entries': {
          'seed_food': {
            'user_id': uid,
            'date': '2026-08-16',
            'meal_type': 'Breakfast',
            'food_name': 'Avocado toast with poached eggs & chia seeds',
            'quality': 'Good',
            'notes': 'High protein, whole grain',
            'created_at': '2026-08-16T08:30:00.000Z',
            'updated_at': '2026-08-16T08:30:00.000Z',
          }
        },
        'weight_entries': {
          'seed_weight': {
            'user_id': uid,
            'date': '2026-08-16',
            'weight_kg': 62.4,
            'time_minutes': 450,
            'created_at': '2026-08-16T07:30:00.000Z',
            'updated_at': '2026-08-16T07:30:00.000Z',
          }
        },
        'period_logs': {
          'seed_period': {
            'user_id': uid,
            'start_date': '2026-08-16',
            'end_date': '2026-08-18',
            'flow_level': 'Medium',
            'pain_level': 2,
            'moods': ['Calm'],
            'symptoms': ['Mild cramping'],
            'notes': 'Cycle started on schedule',
            'created_at': '2026-08-16T08:00:00.000Z',
            'updated_at': '2026-08-16T08:00:00.000Z',
          }
        }
      }, SetOptions(merge: true));

      // -----------------------------------------------------------------------
      // AUGUST 17, 2026
      // -----------------------------------------------------------------------
      await collection.doc('2026-08-17').set({
        'date': '2026-08-17',
        'sleep_entries': {
          'seed_sleep': {
            'user_id': uid,
            'date': '2026-08-17',
            'start_minutes': 1380, // 23:00
            'end_minutes': 390, // 06:30
            'duration_minutes': 450, // 7.5h
            'quality': 'Good',
            'factors': ['Early bedtime'],
            'created_at': '2026-08-17T06:30:00.000Z',
            'updated_at': '2026-08-17T06:30:00.000Z',
          }
        },
        'water_entries': {
          'seed_water': {
            'user_id': uid,
            'date': '2026-08-17',
            'quantity': 2.8,
            'unit': 'L',
            'hydration_level': 'Good',
            'time_minutes': 960,
            'created_at': '2026-08-17T16:00:00.000Z',
            'updated_at': '2026-08-17T16:00:00.000Z',
          }
        },
        'step_entries': {
          'seed_steps': {
            'user_id': uid,
            'date': '2026-08-17',
            'count': 10120,
            'source': 'manual',
            'created_at': '2026-08-17T21:30:00.000Z',
            'updated_at': '2026-08-17T21:30:00.000Z',
          }
        },
        'sugar_craving_entries': {
          'seed_sugar': {
            'user_id': uid,
            'date': '2026-08-17',
            'craving': 'Fresh fruit smoothie',
            'level': 'Medium',
            'time_minutes': 900,
            'created_at': '2026-08-17T15:00:00.000Z',
            'updated_at': '2026-08-17T15:00:00.000Z',
          }
        },
        'supplement_entries': {
          'seed_supplements': {
            'user_id': uid,
            'date': '2026-08-17',
            'name': 'Omega-3 Fish Oil',
            'taken': true,
            'time_minutes': 480,
            'created_at': '2026-08-17T08:00:00.000Z',
            'updated_at': '2026-08-17T08:00:00.000Z',
          }
        },
        'mental_wellness_entries': {
          'seed_wellness': {
            'user_id': uid,
            'date': '2026-08-17',
            'mood': 'Energetic',
            'energy_level': 'High',
            'notes': 'Productive day, accomplished all key tasks.',
            'created_at': '2026-08-17T18:00:00.000Z',
            'updated_at': '2026-08-17T18:00:00.000Z',
          }
        },
        'food_entries': {
          'seed_food': {
            'user_id': uid,
            'date': '2026-08-17',
            'meal_type': 'Lunch',
            'food_name': 'Quinoa salad with chickpea, cucumber & olive oil',
            'quality': 'Good',
            'notes': 'Fibre-rich & filling',
            'created_at': '2026-08-17T13:00:00.000Z',
            'updated_at': '2026-08-17T13:00:00.000Z',
          }
        },
        'weight_entries': {
          'seed_weight': {
            'user_id': uid,
            'date': '2026-08-17',
            'weight_kg': 62.2,
            'time_minutes': 420,
            'created_at': '2026-08-17T07:00:00.000Z',
            'updated_at': '2026-08-17T07:00:00.000Z',
          }
        },
        'period_logs': {
          'seed_period': {
            'user_id': uid,
            'start_date': '2026-08-16',
            'end_date': '2026-08-18',
            'flow_level': 'Light',
            'pain_level': 1,
            'moods': ['Energetic'],
            'symptoms': ['Bloating'],
            'notes': 'Flow lightening',
            'created_at': '2026-08-17T08:00:00.000Z',
            'updated_at': '2026-08-17T08:00:00.000Z',
          }
        }
      }, SetOptions(merge: true));

      // -----------------------------------------------------------------------
      // AUGUST 18, 2026
      // -----------------------------------------------------------------------
      await collection.doc('2026-08-18').set({
        'date': '2026-08-18',
        'sleep_entries': {
          'seed_sleep': {
            'user_id': uid,
            'date': '2026-08-18',
            'start_minutes': 15, // 00:15
            'end_minutes': 465, // 07:45
            'duration_minutes': 450, // 7.5h
            'quality': 'Okay',
            'factors': ['Late bedtime', 'Device in bed'],
            'created_at': '2026-08-18T07:45:00.000Z',
            'updated_at': '2026-08-18T07:45:00.000Z',
          }
        },
        'water_entries': {
          'seed_water': {
            'user_id': uid,
            'date': '2026-08-18',
            'quantity': 2.2,
            'unit': 'L',
            'hydration_level': 'Okay',
            'time_minutes': 930,
            'created_at': '2026-08-18T15:30:00.000Z',
            'updated_at': '2026-08-18T15:30:00.000Z',
          }
        },
        'step_entries': {
          'seed_steps': {
            'user_id': uid,
            'date': '2026-08-18',
            'count': 6800,
            'source': 'manual',
            'created_at': '2026-08-18T20:30:00.000Z',
            'updated_at': '2026-08-18T20:30:00.000Z',
          }
        },
        'sugar_craving_entries': {
          'seed_sugar': {
            'user_id': uid,
            'date': '2026-08-18',
            'craving': 'Dates and walnuts',
            'level': 'Low',
            'time_minutes': 1020,
            'created_at': '2026-08-18T17:00:00.000Z',
            'updated_at': '2026-08-18T17:00:00.000Z',
          }
        },
        'supplement_entries': {
          'seed_supplements': {
            'user_id': uid,
            'date': '2026-08-18',
            'name': 'Magnesium Glycinate',
            'taken': true,
            'time_minutes': 1320,
            'created_at': '2026-08-18T22:00:00.000Z',
            'updated_at': '2026-08-18T22:00:00.000Z',
          }
        },
        'mental_wellness_entries': {
          'seed_wellness': {
            'user_id': uid,
            'date': '2026-08-18',
            'mood': 'Tired',
            'energy_level': 'Medium',
            'notes': 'Slight afternoon slump, rested with chamomile tea.',
            'created_at': '2026-08-18T17:30:00.000Z',
            'updated_at': '2026-08-18T17:30:00.000Z',
          }
        },
        'food_entries': {
          'seed_food': {
            'user_id': uid,
            'date': '2026-08-18',
            'meal_type': 'Dinner',
            'food_name': 'Baked salmon with steamed broccoli & brown rice',
            'quality': 'Good',
            'notes': 'Rich in Omega-3',
            'created_at': '2026-08-18T20:00:00.000Z',
            'updated_at': '2026-08-18T20:00:00.000Z',
          }
        },
        'weight_entries': {
          'seed_weight': {
            'user_id': uid,
            'date': '2026-08-18',
            'weight_kg': 62.0,
            'time_minutes': 465,
            'created_at': '2026-08-18T07:45:00.000Z',
            'updated_at': '2026-08-18T07:45:00.000Z',
          }
        },
        'period_logs': {
          'seed_period': {
            'user_id': uid,
            'start_date': '2026-08-16',
            'end_date': '2026-08-18',
            'flow_level': 'Spotting',
            'pain_level': 0,
            'moods': ['Tired'],
            'symptoms': ['None'],
            'notes': 'Period ending',
            'created_at': '2026-08-18T08:00:00.000Z',
            'updated_at': '2026-08-18T08:00:00.000Z',
          }
        }
      }, SetOptions(merge: true));

      // -----------------------------------------------------------------------
      // EXERCISE SESSIONS
      // -----------------------------------------------------------------------
      final exerciseRef = firestore
          .collection('users')
          .doc(uid)
          .collection('exercise_sessions');

      await exerciseRef.doc('seed_2026_08_16_exercise').set({
        'id': 'seed_2026_08_16_exercise',
        'date': '2026-08-16T08:30:00.000Z',
        'activity_type': 'yoga',
        'duration_minutes': 30,
        'workout_id': 'morning_yoga',
        'created_at': '2026-08-16T08:30:00.000Z',
      }, SetOptions(merge: true));

      await exerciseRef.doc('seed_2026_08_17_exercise').set({
        'id': 'seed_2026_08_17_exercise',
        'date': '2026-08-17T17:00:00.000Z',
        'activity_type': 'walk',
        'duration_minutes': 40,
        'workout_id': 'evening_walk',
        'created_at': '2026-08-17T17:00:00.000Z',
      }, SetOptions(merge: true));

      await exerciseRef.doc('seed_2026_08_18_exercise').set({
        'id': 'seed_2026_08_18_exercise',
        'date': '2026-08-18T18:00:00.000Z',
        'activity_type': 'strength',
        'duration_minutes': 25,
        'workout_id': 'light_strength',
        'created_at': '2026-08-18T18:00:00.000Z',
      }, SetOptions(merge: true));

      // -----------------------------------------------------------------------
      // STRESS JOURNALS & CHECK-INS
      // -----------------------------------------------------------------------
      final journalRef = firestore
          .collection('users')
          .doc(uid)
          .collection('stress_journals');

      await journalRef.doc('seed_2026_08_16_journal').set({
        'id': 'seed_2026_08_16_journal',
        'date': '2026-08-16T20:00:00.000Z',
        'prompt': 'What is one small thing that went well today?',
        'text': 'Enjoyed a peaceful morning routine without rushing.',
      }, SetOptions(merge: true));

      await journalRef.doc('seed_2026_08_17_journal').set({
        'id': 'seed_2026_08_17_journal',
        'date': '2026-08-17T20:30:00.000Z',
        'prompt': 'How does your body feel right now?',
        'text': 'Body feels strong and relaxed after a crisp evening walk.',
      }, SetOptions(merge: true));

      await journalRef.doc('seed_2026_08_18_journal').set({
        'id': 'seed_2026_08_18_journal',
        'date': '2026-08-18T21:00:00.000Z',
        'prompt': 'What do you need permission to let go of?',
        'text': 'Permission to rest without feeling guilty.',
      }, SetOptions(merge: true));

      final checkinRef = firestore
          .collection('users')
          .doc(uid)
          .collection('stress_checkins');

      await checkinRef.doc('seed_2026_08_16_checkin').set({
        'id': 'seed_2026_08_16_checkin',
        'date': '2026-08-16T19:30:00.000Z',
        'level': 'Low',
        'factors': ['Sleep', 'Health'],
      }, SetOptions(merge: true));

      await checkinRef.doc('seed_2026_08_17_checkin').set({
        'id': 'seed_2026_08_17_checkin',
        'date': '2026-08-17T19:30:00.000Z',
        'level': 'Low',
        'factors': ['Work / studies'],
      }, SetOptions(merge: true));

      await checkinRef.doc('seed_2026_08_18_checkin').set({
        'id': 'seed_2026_08_18_checkin',
        'date': '2026-08-18T19:30:00.000Z',
        'level': 'Moderate',
        'factors': ['Sleep'],
      }, SetOptions(merge: true));

      debugPrint('[seeder] Successfully seeded August 16-18 health data into Firestore.');
      return true;
    } catch (e) {
      debugPrint('[seeder] Error seeding Firestore data: $e');
      return false;
    }
  }
}
