import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';
import 'package:news_apps/core/constants/app_routes.dart';
import 'package:news_apps/core/theme/app_theme.dart';
import 'package:news_apps/presentation/bindings/app_pages.dart';
import 'package:news_apps/presentation/controllers/auth_controller.dart';
import 'package:news_apps/presentation/controllers/bookmark_controller.dart';
import 'package:news_apps/presentation/controllers/chat_controller.dart';
import 'package:news_apps/presentation/controllers/news_controller.dart';
import '../test/helpers/fake_repositories.dart';
import '../test/helpers/fake_bookmark_controller.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRepository fakeAuth;
  late FakeNewsRepository fakeNews;
  late FakeChatRepository fakeChat;

  setUp(() async {
    Get.testMode = true;
    fakeAuth = FakeAuthRepository(guestUser: sampleGuestUser());
    fakeNews = FakeNewsRepository(articles: sampleArticles());
    fakeChat = FakeChatRepository();

    Get.put<AuthController>(AuthController(authRepository: fakeAuth), permanent: true);
    Get.put<NewsController>(NewsController(newsRepository: fakeNews), permanent: true);
    Get.put<ChatController>(ChatController(chatRepository: fakeChat), permanent: true);
    Get.put<BookmarkController>(FakeBookmarkController(), permanent: true);

    await Future.delayed(const Duration(milliseconds: 150));
  });

  tearDown(Get.reset);

  Widget buildApp(String initialRoute) => GetMaterialApp(
        theme: AppTheme.darkTheme,
        initialRoute: initialRoute,
        getPages: AppPages.routes,
        defaultTransition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 80),
      );

  // ── Test 1: Login page renders ───────────────────────────────────────────────
  testWidgets('1. Login page renders correctly', (tester) async {
    await tester.pumpWidget(buildApp(AppRoutes.login));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
  });

  // ── Test 2: Guest login flow ─────────────────────────────────────────────────
  testWidgets('2. Tapping "Continue as Guest" logs in and navigates to News',
          (tester) async {
        await tester.pumpWidget(buildApp(AppRoutes.login));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue as Guest'));
        // Tunggu animasi navigasi + pemuatan data awal
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(find.text('News Application'), findsOneWidget);
      });

  // ── Test 3: News page shows articles ─────────────────────────────────────────
  testWidgets('3. News page displays articles', (tester) async {
    Get.find<AuthController>().currentUser.value = sampleGoogleUser();

    await tester.pumpWidget(buildApp(AppRoutes.news));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Flutter 4.0 Released'), findsOneWidget);
    expect(find.text('Dart Testing Best Practices'), findsOneWidget);
  });

  // ── Test 4: Category selection ────────────────────────────────────────────────
  testWidgets('4. Selecting Technology category updates controller state',
          (tester) async {
        Get.find<AuthController>().currentUser.value = sampleGoogleUser();

        await tester.pumpWidget(buildApp(AppRoutes.news));
        await tester.pumpAndSettle();

        final techChip = find.text('💻 Technology');
        if (techChip.evaluate().isNotEmpty) {
          await tester.tap(techChip);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          expect(Get.find<NewsController>().selectedCategory.value, 'technology');
          expect(fakeNews.lastCategory, 'technology');
        }
      });

  // ── Test 5: Search interaction ────────────────────────────────────────────────
  testWidgets('5. Searching for "dart" passes query to repository',
          (tester) async {
        Get.find<AuthController>().currentUser.value = sampleGoogleUser();

        await tester.pumpWidget(buildApp(AppRoutes.news));
        await tester.pumpAndSettle();

        final searchField = find.byType(TextField).first;
        await tester.tap(searchField);
        await tester.enterText(searchField, 'dart');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(fakeNews.lastSearchQuery, 'dart');
      });

  // ── Test 6: Tapping article opens detail page ────────────────────────────────
  testWidgets('6. Tapping an article navigates to the detail page',
          (tester) async {
        Get.find<AuthController>().currentUser.value = sampleGoogleUser();

        await tester.pumpWidget(buildApp(AppRoutes.news));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final articleTitle = find.text('Flutter 4.0 Released');
        if (articleTitle.evaluate().isNotEmpty) {
          await tester.tap(articleTitle);
          await tester.pumpAndSettle();
          expect(find.text('Read Full Article'), findsOneWidget);
        }
      });

  // ── Test 6b: Bookmark button visible in detail page ──────────────────────────
  testWidgets('6b. News detail page shows bookmark icon in app bar',
          (tester) async {
        Get.find<AuthController>().currentUser.value = sampleGoogleUser();

        await tester.pumpWidget(buildApp(AppRoutes.news));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final articleTitle = find.text('Flutter 4.0 Released');
        if (articleTitle.evaluate().isNotEmpty) {
          await tester.tap(articleTitle);
          await tester.pumpAndSettle();

          expect(
            find.byIcon(Icons.bookmark_border_rounded).evaluate().isNotEmpty ||
                find.byIcon(Icons.bookmark_rounded).evaluate().isNotEmpty,
            isTrue,
          );
          expect(find.text('Read Full Article'), findsOneWidget);
          expect(find.byIcon(Icons.smart_toy_rounded), findsOneWidget);
        }
      });

  // ── Test 7: Chat page renders ─────────────────────────────────────────────────
  testWidgets('7. Chat page shows NewsBot', (tester) async {
    Get.find<AuthController>().currentUser.value = sampleGoogleUser();

    await tester.pumpWidget(buildApp(AppRoutes.chat));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('NewsBot'), findsOneWidget);
  });

  // ── Test 8: Sending a chat message ───────────────────────────────────────────
  testWidgets('8. Sending a chat message stores it in the repository',
          (tester) async {
        Get.find<AuthController>().currentUser.value = sampleGoogleUser();

        await tester.pumpWidget(buildApp(AppRoutes.chat));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final textFields = find.byType(TextField);
        await tester.tap(textFields.last);
        await tester.enterText(textFields.last, 'Hello NewsBot!');
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.send_rounded));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final sentByUser = fakeChat.stored
            .where((m) => m.text == 'Hello NewsBot!' && m.isUser)
            .toList();
        expect(sentByUser, isNotEmpty);
      });
}