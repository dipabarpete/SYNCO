import 'dart:math';

class AISummaryService {
  /// Generates a realistic mock AI summary based on the patient's context.
  /// In a production environment, this would call the Gemini API or a Vercel Edge function.
  static Map<String, dynamic> generateMockSummary({
    required String patientName,
    required String doctorName,
    required String reasonForVisit,
  }) {
    final random = Random();
    
    final recentSymptoms = [
      'Irregular cycle length (varies by 5-8 days over last 3 months).',
      'Mild to moderate cramping reported on days 1-2.',
      'Occasional fatigue and bloating observed.',
      'Spotting between periods reported once in the last 60 days.',
      'Slight increase in acne and mood swings before cycle onset.',
    ];
    
    // Pick 2 random symptoms
    recentSymptoms.shuffle(random);
    final selectedSymptoms = recentSymptoms.take(2).toList();
    
    final aiInsights = [
      'Patient logs indicate a potential hormonal imbalance correlating with recent stress levels.',
      'Cycle variance is slightly above normal threshold; suggest checking thyroid or PCOS indicators.',
      'Symptoms are consistent with primary dysmenorrhea; consider discussing pain management.',
      'Overall health data appears stable, but recent irregularities warrant a routine ultrasound.',
    ];
    
    final selectedInsight = aiInsights[random.nextInt(aiInsights.length)];

    return {
      'patientName': patientName,
      'generatedAt': DateTime.now().toIso8601String(),
      'reasonForConsultation': reasonForVisit,
      'recentSymptomsLogged': selectedSymptoms.join(' '),
      'aiClinicalInsight': selectedInsight,
      'recommendedQuestions': '1. Have there been any recent lifestyle or diet changes?\n2. What is your current stress level on a scale of 1-10?\n3. Are you taking any new supplements or medications?',
      'disclaimer': 'This summary is AI-generated for contextual reference based on patient logs and does not constitute a definitive medical diagnosis.'
    };
  }
}
