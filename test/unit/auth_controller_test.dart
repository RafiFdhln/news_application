import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:news_apps/presentation/controllers/auth_controller.dart';
import '../helpers/fake_repositories.dart';

void main() {
  late FakeAuthRepository fakeAuth;
  late AuthController authController;

  setUp(() {
    Get.testMode = true;
    fakeAuth = FakeAuthRepository();
    authController = AuthController(authRepository: fakeAuth);
  });

  tearDown(Get.reset);

  group('AuthController — state', () {
    test('starts with no user, no error, not loading', () {
      expect(authController.currentUser.value, isNull);
      expect(authController.errorMessage.value, '');
      expect(authController.isLoading.value, false);
      expect(authController.isLoggedIn, false);
    });
  });

  group('AuthController — sign in with Google', () {
    test('sets user and marks loggedIn on success', () async {
      fakeAuth.setGoogleUser(sampleGoogleUser());
      await authController.signInWithGoogle();

      expect(authController.isLoggedIn, true);
      expect(authController.currentUser.value?.uid, 'google-uid');
      expect(authController.isLoading.value, false);
      expect(authController.errorMessage.value, '');
    });

    test('sets errorMessage on failure', () async {
      fakeAuth.throwOnGoogle = true;
      await authController.signInWithGoogle();

      expect(authController.isLoggedIn, false);
      expect(authController.errorMessage.value.isNotEmpty, true);
      expect(authController.isLoading.value, false);
    });

    test('errorMessage contains human-readable text', () async {
      fakeAuth.throwOnGoogle = true;
      await authController.signInWithGoogle();

      // _formatError should have processed the raw exception
      expect(authController.errorMessage.value, isNot(contains('Exception')));
    });
  });

  group('AuthController — guest sign in', () {
    test('creates guest user', () async {
      fakeAuth.setGuestUser(sampleGuestUser());
      await authController.signInAsGuest();

      expect(authController.isGuest, true);
      expect(authController.currentUser.value?.isGuest, true);
      expect(authController.isLoading.value, false);
    });

    test('sets errorMessage on failure', () async {
      fakeAuth.throwOnGuest = true;
      await authController.signInAsGuest();

      expect(authController.isLoggedIn, false);
      expect(authController.errorMessage.value.isNotEmpty, true);
    });
  });

  group('AuthController — sign out', () {
    test('clears currentUser', () async {
      authController.currentUser.value = sampleGoogleUser();
      await authController.signOut();

      expect(authController.currentUser.value, isNull);
      expect(authController.isLoggedIn, false);
    });
  });

  group('AuthController — helpers', () {
    test('isGuest true when current user isGuest=true', () {
      authController.currentUser.value = sampleGuestUser();
      expect(authController.isGuest, true);
    });

    test('isGuest false when current user isGuest=false', () {
      authController.currentUser.value = sampleGoogleUser();
      expect(authController.isGuest, false);
    });

    test('errorMessage cleared on next successful login', () async {
      authController.errorMessage.value = 'Old error';
      fakeAuth.setGoogleUser(sampleGoogleUser());
      await authController.signInWithGoogle();

      expect(authController.errorMessage.value, '');
    });
  });

  group('AuthController — cached user on init', () {
    test('loads cached user during onInit', () async {
      Get.reset();
      Get.testMode = true;
      final authFake = FakeAuthRepository(cachedUser: sampleGoogleUser());
      final ctrl = AuthController(authRepository: authFake);
      // Wait for async onInit to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(ctrl.currentUser.value?.uid, 'google-uid');
      Get.reset();
    });
  });
}
