import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/auth/services/auth_service.dart';

void main() {
  group('AuthResult Tests', () {
    test('AuthResult.success creates correct object', () {
      final result = AuthResult.success();
      expect(result.isSuccess, true);
      expect(result.errorMessage, isNull);
      expect(result.user, isNull);
      expect(result.profile, isNull);
    });

    test('AuthResult.failure creates correct object', () {
      const errorMessage = 'Authentication failed';
      final result = AuthResult.failure(errorMessage);
      expect(result.isSuccess, false);
      expect(result.errorMessage, errorMessage);
    });

    test('AuthResult.pendingService creates correct object', () {
      final result = AuthResult.pendingService('Pending');
      expect(result.isSuccess, false);
      expect(result.errorMessage, 'Pending');
      expect(result.isRealAuthPending, true);
    });
  });

  group('AuthService Mock Logic', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('sendOtp returns failure for invalid short number', () async {
      final result = await authService.sendOtp(countryCode: '1', phoneNumber: '123');
      expect(result.isSuccess, false);
      expect(result.errorMessage, 'Please enter a valid phone number.');
    });

    test('verifyOtp returns failure for short code', () async {
      final result = await authService.verifyOtp(phoneNumber: '1234567890', otpCode: '123');
      expect(result.isSuccess, false);
      expect(result.errorMessage, 'Please enter all 6 digits of the OTP code.');
    });

    test('verifyOtp returns failure when uninitialized', () async {
      final result = await authService.verifyOtp(phoneNumber: '1234567890', otpCode: '123456');
      expect(result.isSuccess, false);
      expect(result.errorMessage, 'Firebase client is not initialized.');
    });
  });
}
