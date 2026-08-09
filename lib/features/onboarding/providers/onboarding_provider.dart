import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_profile.dart';
import '../../auth/providers/auth_provider.dart';

class OnboardingState {
  final UserRole selectedRole;
  final String userName;
  final PcosDiagnosisStatus? diagnosisStatus;
  final bool isSubmitting;
  final String? errorMessage;

  const OnboardingState({
    this.selectedRole = UserRole.user,
    this.userName = '',
    this.diagnosisStatus,
    this.isSubmitting = false,
    this.errorMessage,
  });

  OnboardingState copyWith({
    UserRole? selectedRole,
    String? userName,
    PcosDiagnosisStatus? diagnosisStatus,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return OnboardingState(
      selectedRole: selectedRole ?? this.selectedRole,
      userName: userName ?? this.userName,
      diagnosisStatus: diagnosisStatus ?? this.diagnosisStatus,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref);
});

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;

  OnboardingNotifier(this._ref) : super(const OnboardingState());

  void setRole(UserRole role) {
    state = state.copyWith(selectedRole: role);
  }

  void setName(String name) {
    state = state.copyWith(userName: name.trim());
  }

  void setDiagnosisStatus(PcosDiagnosisStatus status) {
    state = state.copyWith(diagnosisStatus: status);
  }

  /// Finalize onboarding state and update the active user profile
  Future<bool> completeOnboarding() async {
    state = state.copyWith(isSubmitting: true);
    try {
      final authNotifier = _ref.read(authNotifierProvider.notifier);
      final currentAuthState = _ref.read(authNotifierProvider);

      final currentProfile = currentAuthState.userProfile ??
          UserProfile(
            id: currentAuthState.user?.id ?? 'usr_local',
            username: state.userName.isNotEmpty ? state.userName : 'Synco User',
            avatarUrl: '',
          );

      final updatedProfile = currentProfile.copyWith(
        username: state.userName.isNotEmpty ? state.userName : currentProfile.username,
        role: state.selectedRole,
        diagnosisStatus: state.diagnosisStatus ?? PcosDiagnosisStatus.preferNotToSay,
        onboardingCompleted: true,
      );

      // Update in Riverpod AuthNotifier
      authNotifier.updateLocalProfile(updatedProfile);

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to save onboarding details. Please try again.',
      );
      return false;
    }
  }

  void reset() {
    state = const OnboardingState();
  }
}
