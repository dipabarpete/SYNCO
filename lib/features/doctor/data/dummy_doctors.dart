import '../../../core/theme/app_colors.dart';
import '../models/doctor.dart';

/// Demo doctor profiles used by the Find a Doctor prototype.
/// All data is fictional and for demonstration purposes only.
class DummyDoctors {
  static const List<Doctor> suggestedDoctors = [
    Doctor(
      id: 'dr-ananya-sharma',
      name: 'Dr. Ananya Sharma',
      specialization: 'Gynecologist',
      experience: '8+ years',
      rating: 4.8,
      consultationFee: 800,
      availability: 'Available Today',
      mode: ConsultationMode.online,
      about:
          'Dr. Ananya Sharma is a compassionate gynecologist with over 8 years '
          'of experience in managing PCOS/PCOD, menstrual irregularities and '
          'hormonal health. She believes in a gentle, holistic approach that '
          'combines clinical care with lifestyle guidance.',
      availableDays: ['Mon', 'Tue', 'Thu', 'Fri', 'Sat'],
      timeSlots: ['09:30 AM', '10:30 AM', '11:30 AM', '02:00 PM', '04:30 PM'],
      avatarBackground: AppColors.softLavender,
    ),
    Doctor(
      id: 'dr-meera-kapoor',
      name: 'Dr. Meera Kapoor',
      specialization: "Women's Health Specialist",
      experience: '6+ years',
      rating: 4.7,
      consultationFee: 700,
      availability: 'Available Tomorrow',
      mode: ConsultationMode.online,
      about:
          'Dr. Meera Kapoor specializes in women\u2019s health with a focus on '
          'preventive care, fertility awareness and reproductive wellness. Her '
          'online consultations are known for being thorough, reassuring and '
          'easy to follow.',
      availableDays: ['Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      timeSlots: ['10:00 AM', '12:00 PM', '01:30 PM', '05:00 PM'],
      avatarBackground: AppColors.babyPink,
    ),
  ];

  static const List<Doctor> nearbyDoctors = [
    Doctor(
      id: 'dr-riya-malhotra',
      name: 'Dr. Riya Malhotra',
      specialization: 'Gynecologist',
      experience: '10+ years',
      rating: 4.9,
      consultationFee: 900,
      availability: 'Available Today',
      mode: ConsultationMode.offline,
      distanceKm: 1.8,
      clinicLocation: "Apollo Women's Clinic, Sector 18",
      about:
          'With over a decade of experience, Dr. Riya Malhotra is a trusted '
          'gynecologist known for her warm bedside manner and expertise in '
          'PCOS management, adolescent gynecology and high-risk pregnancy care.',
      availableDays: ['Mon', 'Tue', 'Wed', 'Fri'],
      timeSlots: ['09:00 AM', '11:00 AM', '01:00 PM', '03:00 PM', '06:00 PM'],
      avatarBackground: AppColors.blushPinkLight,
    ),
    Doctor(
      id: 'dr-neha-verma',
      name: 'Dr. Neha Verma',
      specialization: 'Reproductive Health Specialist',
      experience: '7+ years',
      rating: 4.8,
      consultationFee: 750,
      availability: 'Available Tomorrow',
      mode: ConsultationMode.offline,
      distanceKm: 3.2,
      clinicLocation: "Bloom Women's Care, Sector 21",
      about:
          'Dr. Neha Verma is a reproductive health specialist dedicated to '
          'fertility awareness, hormonal balance and women\u2019s wellness at '
          'every life stage. She takes time to listen and empowers every '
          'patient with clear, actionable guidance.',
      availableDays: ['Tue', 'Wed', 'Thu', 'Sat'],
      timeSlots: ['10:30 AM', '12:30 PM', '04:00 PM', '06:30 PM'],
      avatarBackground: AppColors.softLavender,
    ),
  ];

  static List<Doctor> get all =>
      [...suggestedDoctors, ...nearbyDoctors];

  static Doctor? byId(String id) {
    for (final doctor in all) {
      if (doctor.id == id) return doctor;
    }
    return null;
  }
}
