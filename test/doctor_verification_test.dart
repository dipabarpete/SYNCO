import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/doctor/models/doctor_verification.dart';
import 'package:hersync/features/doctor/providers/doctor_verification_provider.dart';

void main() {
  group('DoctorVerificationStatus', () {
    test('toDbValue/fromDbValue round trip', () {
      for (final status in DoctorVerificationStatus.values) {
        expect(
          DoctorVerificationStatusX.fromDbValue(status.toDbValue()),
          status,
        );
      }
    });

    test('unknown values fall back to submitted', () {
      expect(
        DoctorVerificationStatusX.fromDbValue('whatever'),
        DoctorVerificationStatus.submitted,
      );
      expect(
        DoctorVerificationStatusX.fromDbValue(null),
        DoctorVerificationStatus.submitted,
      );
    });

    test('labels never claim verification when not verified', () {
      expect(
        DoctorVerificationStatus.submitted.label,
        isNot('Verified Doctor'),
      );
      expect(
        DoctorVerificationStatus.pendingVerification.label,
        isNot('Verified Doctor'),
      );
      expect(DoctorVerificationStatus.rejected.label, 'Needs Changes');
      expect(DoctorVerificationStatus.verified.label, 'Verified Doctor');
    });
  });

  group('DoctorVerification model', () {
    final storedFile = StoredFile(
      name: 'cert.pdf',
      storagePath: 'doctor_documents/uid1/qualification_certificate.pdf',
      url: 'https://storage/uid1/qualification_certificate.pdf',
      uploadedAt: DateTime(2026, 1, 2),
    );

    test('toMap/fromMap round trip preserves all fields', () {
      final data = DoctorVerification(
        userId: 'uid1',
        fullName: 'Dr. Jane Doe',
        registrationNumber: 'MCI-12345',
        registeringAuthority: 'Medical Council of India',
        qualification: 'MBBS, MD',
        qualificationCertificate: storedFile,
        registrationCertificate: storedFile,
        specializationCertificate: storedFile,
        governmentId: storedFile,
        dateOfBirth: DateTime(1985, 5, 12),
        profilePhoto: storedFile,
        specializations: const ['Gynecology', 'Menstrual Disorders'],
        clinicName: 'St. Mary\'s Clinic',
        clinicLocation: 'Mumbai',
        clinicAddress: '12 MG Road, Andheri',
        professionalEmail: 'dr.jane@clinic.com',
        phone: '+919876543210',
        status: DoctorVerificationStatus.submitted,
        submittedAt: DateTime(2026, 1, 2, 10, 30),
      );

      final restored = DoctorVerification.fromMap(data.toMap());

      expect(restored.userId, 'uid1');
      expect(restored.fullName, 'Dr. Jane Doe');
      expect(restored.registrationNumber, 'MCI-12345');
      expect(restored.registeringAuthority, 'Medical Council of India');
      expect(restored.qualification, 'MBBS, MD');
      expect(
        restored.qualificationCertificate?.storagePath,
        storedFile.storagePath,
      );
      expect(restored.registrationCertificate?.url, storedFile.url);
      expect(restored.specializationCertificate?.name, storedFile.name);
      expect(restored.governmentId?.storagePath, storedFile.storagePath);
      expect(restored.dateOfBirth, DateTime(1985, 5, 12));
      expect(restored.profilePhoto?.url, storedFile.url);
      expect(
        restored.specializations,
        ['Gynecology', 'Menstrual Disorders'],
      );
      expect(restored.clinicName, 'St. Mary\'s Clinic');
      expect(restored.clinicLocation, 'Mumbai');
      expect(restored.clinicAddress, '12 MG Road, Andheri');
      expect(restored.professionalEmail, 'dr.jane@clinic.com');
      expect(restored.phone, '+919876543210');
      expect(restored.status, DoctorVerificationStatus.submitted);
      expect(restored.submittedAt, DateTime(2026, 1, 2, 10, 30));
    });

    test('storedFor resolves refs by kind', () {
      final data = DoctorVerification(
        qualificationCertificate: storedFile,
        governmentId: storedFile,
      );
      expect(
        data.storedFor(VerificationDocKind.qualificationCertificate),
        storedFile,
      );
      expect(data.storedFor(VerificationDocKind.governmentId), storedFile);
      expect(data.storedFor(VerificationDocKind.profilePhoto), isNull);
    });

    test('withStored replaces a ref and keeps the rest', () {
      final updated = DoctorVerification(
        fullName: 'Dr. Jane',
      ).withStored(VerificationDocKind.registrationCertificate, storedFile);

      expect(
        updated.storedFor(VerificationDocKind.registrationCertificate),
        storedFile,
      );
      expect(updated.fullName, 'Dr. Jane');

      final cleared = updated.withStored(
        VerificationDocKind.registrationCertificate,
        null,
      );
      expect(
        cleared.storedFor(VerificationDocKind.registrationCertificate),
        isNull,
      );
    });

    test('UploadFile.hasContent reflects path or bytes', () {
      final withPath = UploadFile(
        name: 'a.pdf',
        extension: 'pdf',
        path: '/tmp/a.pdf',
      );
      final withBytes = UploadFile(
        name: 'b.pdf',
        extension: 'pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
      );
      final emptyPath = UploadFile(name: 'c.pdf', extension: 'pdf');

      expect(withPath.hasContent, true);
      expect(withBytes.hasContent, true);
      expect(emptyPath.hasContent, false);
    });
  });

  group('DoctorVerificationNotifier', () {
    late ProviderContainer container;
    late DoctorVerificationNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(doctorVerificationProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('field setters persist across steps', () {
      notifier.setFullName('Dr. Jane Doe');
      notifier.setRegistrationNumber('MCI-12345');
      notifier.setQualification('MBBS, MD');
      notifier.setClinicName('St. Mary\'s Clinic');
      notifier.setProfessionalEmail('dr.jane@clinic.com');

      final data = container.read(doctorVerificationProvider).data;
      expect(data.fullName, 'Dr. Jane Doe');
      expect(data.registrationNumber, 'MCI-12345');
      expect(data.qualification, 'MBBS, MD');
      expect(data.clinicName, 'St. Mary\'s Clinic');
      expect(data.professionalEmail, 'dr.jane@clinic.com');
    });

    test('specialization toggle and custom add', () {
      notifier.toggleSpecialization('Gynecology');
      notifier.toggleSpecialization('Gynecology');
      expect(
        container.read(doctorVerificationProvider).data.specializations,
        isEmpty,
      );

      notifier.toggleSpecialization('Gynecology');
      notifier.addCustomSpecialization('Reproductive Medicine');
      expect(
        container.read(doctorVerificationProvider).data.specializations,
        ['Gynecology', 'Reproductive Medicine'],
      );
    });

    test('pickFile keeps the file pending without uploading', () {
      final file = UploadFile(
        name: 'cert.pdf',
        extension: 'pdf',
        path: '/tmp/cert.pdf',
      );
      notifier.pickFile(VerificationDocKind.qualificationCertificate, file);

      final state = container.read(doctorVerificationProvider);
      expect(
        state.pendingFiles[VerificationDocKind.qualificationCertificate],
        file,
      );
      expect(state.data.qualificationCertificate, isNull);
    });

    test('removeFile clears pending and stored refs', () {
      final record = DoctorVerification(
        qualificationCertificate: StoredFile(
          name: 'old.pdf',
          storagePath: 'doctor_documents/uid/qualification_certificate.pdf',
          url: 'https://x/y',
          uploadedAt: DateTime(2026, 1, 1),
        ),
      );
      notifier.loadExisting(record);
      notifier.removeFile(VerificationDocKind.qualificationCertificate);

      final state = container.read(doctorVerificationProvider);
      expect(
        state.pendingFiles[VerificationDocKind.qualificationCertificate],
        isNull,
      );
      expect(state.data.qualificationCertificate, isNull);
    });

    test('loadExisting enables resubmission on the same identity', () {
      notifier.loadExisting(
        const DoctorVerification(
          userId: 'uid1',
          fullName: 'Dr. John',
          status: DoctorVerificationStatus.rejected,
        ),
      );
      final state = container.read(doctorVerificationProvider);
      expect(state.isEditing, true);
      expect(state.data.userId, 'uid1');
      expect(state.data.fullName, 'Dr. John');
    });

    test('submit fails gracefully when the backend is not initialized',
        () async {
      notifier.setFullName('Dr. Jane');
      notifier.setRegistrationNumber('MCI-1');
      notifier.setProfessionalEmail('dr.jane@clinic.com');
      notifier.setPassword('secret123');
      notifier.setConfirmPassword('secret123');

      await expectLater(
        notifier.submit(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Firebase is not initialized'),
        )),
      );

      final state = container.read(doctorVerificationProvider);
      expect(state.isSubmitting, false);
      expect(state.errorMessage, isNotNull);
      expect(state.data.fullName, 'Dr. Jane');
    });
  });
}