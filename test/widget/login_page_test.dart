import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:news_apps/core/theme/app_theme.dart';
import 'package:news_apps/presentation/controllers/auth_controller.dart';
import 'package:news_apps/presentation/pages/auth/login_page.dart';
import '../helpers/fake_repositories.dart';

void main() {
  late AuthController authController;

  setUp(() {
    Get.testMode = true;
    authController = AuthController(authRepository: FakeAuthRepository());
    Get.put<AuthController>(authController);
  });

  tearDown(Get.reset);

  Widget pumpLoginPage() => GetMaterialApp(
        theme: AppTheme.darkTheme,
        home: const LoginPage(),
      );

  group('LoginPage — renders correctly', () {
    testWidgets('shows app name "News Application"', (tester) async {
      await tester.pumpWidget(pumpLoginPage());
      await tester.pumpAndSettle();
      expect(find.text('News Application'), findsWidgets);
    });

    testWidgets('shows "Welcome Back!" heading', (tester) async {
      await tester.pumpWidget(pumpLoginPage());
      await tester.pumpAndSettle();
      expect(find.text('Welcome Back!'), findsOneWidget);
    });

    testWidgets('shows Google sign-in button', (tester) async {
      await tester.pumpWidget(pumpLoginPage());
      await tester.pumpAndSettle();
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('shows Guest login button', (tester) async {
      await tester.pumpWidget(pumpLoginPage());
      await tester.pumpAndSettle();
      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('shows Terms of Service text', (tester) async {
      await tester.pumpWidget(pumpLoginPage());
      await tester.pumpAndSettle();
      expect(find.textContaining('Terms of Service'), findsOneWidget);
    });

    testWidgets('has newspaper icon', (tester) async {
      await tester.pumpWidget(pumpLoginPage());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.newspaper_rounded), findsWidgets);
    });

    testWidgets('has a Scaffold', (tester) async {
      await tester.pumpWidget(pumpLoginPage());
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('LoginPage — loading state', () {
    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      authController.isLoading.value = true;
      await tester.pumpWidget(pumpLoginPage());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('hides action buttons when loading', (tester) async {
      authController.isLoading.value = true;
      await tester.pumpWidget(pumpLoginPage());
      await tester.pump();
      expect(find.text('Continue with Google'), findsNothing);
      expect(find.text('Continue as Guest'), findsNothing);
    });
  });

  group('LoginPage — error state', () {
    testWidgets('shows error message when set', (tester) async {
      authController.errorMessage.value = 'Network error. Please check your connection.';
      await tester.pumpWidget(pumpLoginPage());
      await tester.pump();
      expect(
        find.text('Network error. Please check your connection.'),
        findsOneWidget,
      );
    });

    testWidgets('error message disappears when cleared', (tester) async {
      authController.errorMessage.value = 'Error!';
      await tester.pumpWidget(pumpLoginPage());
      await tester.pump();
      expect(find.text('Error!'), findsOneWidget);

      authController.errorMessage.value = '';
      await tester.pump();
      expect(find.text('Error!'), findsNothing);
    });
  });
}
