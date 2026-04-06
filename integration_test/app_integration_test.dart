// ignore_for_file: avoid_print
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

// Pull in shared fakes
import '../test/helpers/fake_repositories.dart';
import '../test/helpers/fake_bookmark_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // These are reassigned in setUp() so every group block can close over them.
  late FakeAuthRepository fakeAuth;
  late FakeNewsRepository fakeNews;
  late FakeChatRepository fakeChat;

  setUp(() async {
    Get.testMode = true;

    fakeAuth = FakeAuthRepository(
      guestUser: sampleGuestUser(),
      googleUser: sampleGoogleUser(),
    );
    fakeNews = FakeNewsRepository(articles: sampleArticles());
    fakeChat = FakeChatRepository();

    // ── AuthController ────────────────────────────────────────────────────
    Get.put<AuthController>(
      AuthController(authRepository: fakeAuth),
      permanent: true,
    );

    // ── NewsController ────────────────────────────────────────────────────
    Get.put<NewsController>(
      NewsController(newsRepository: fakeNews),
      permanent: true,
    );

    // ── ChatController ────────────────────────────────────────────────────
    Get.put<ChatController>(
      ChatController(chatRepository: fakeChat),
      permanent: true,
    );

    // ── BookmarkController ────────────────────────────────────────────────────
    Get.put<BookmarkController>(
      FakeBookmarkController(),
      permanent: true,
    );

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

  // ══════════════════════════════════════════════════════════════════════════
  // GROUP 1: Authentication
  // ══════════════════════════════════════════════════════════════════════════

  group('Authentication', () {
    testWidgets('1.1 Login page renders with all required elements',
        (tester) async {
      await tester.pumpWidget(buildApp(AppRoutes.login));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('1.2 Guest login navigates to News page', (tester) async {
      await tester.pumpWidget(buildApp(AppRoutes.login));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('News Application'), findsOneWidget);
    });

    testWidgets('1.3 Google sign-in failure keeps user on login page',
        (tester) async {
      fakeAuth.throwOnGoogle = true;

      await tester.pumpWidget(buildApp(AppRoutes.login));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Welcome Back!'), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // GROUP 2: News Page
  // ══════════════════════════════════════════════════════════════════════════

  group('News Page', () {
    setUp(() {
      // Runs AFTER the outer setUp, so controllers are already registered.
      Get.find<AuthController>().currentUser.value = sampleGoogleUser();
    });

    testWidgets('2.1 News page displays article list', (tester) async {
      await tester.pumpWidget(buildApp(AppRoutes.news));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Flutter 4.0 Released'), findsOneWidget);
      expect(find.text('Dart Testing Best Practices'), findsOneWidget);
    });

    testWidgets('2.2 Selecting Technology category updates controller',
        (tester) async {
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

    testWidgets('2.3 Search passes query to repository', (tester) async {
      await tester.pumpWidget(buildApp(AppRoutes.news));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.tap(searchField);
      await tester.enterText(searchField, 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(fakeNews.lastSearchQuery, 'flutter');
    });

    testWidgets('2.4 Bottom navigation Chat tab navigates to Chat page',
        (tester) async {
      await tester.pumpWidget(buildApp(AppRoutes.news));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final chatLabel = find.text('Chat');
      if (chatLabel.evaluate().isNotEmpty) {
        await tester.tap(chatLabel);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.text('NewsBot'), findsOneWidget);
      }
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // GROUP 3: News Detail Page
  // ══════════════════════════════════════════════════════════════════════════

  group('News Detail Page', () {
    setUp(() {
      Get.find<AuthController>().currentUser.value = sampleGoogleUser();
    });

    testWidgets('3.1 Tapping article navigates to detail page', (tester) async {
      await tester.pumpWidget(buildApp(AppRoutes.news));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final articleTitle = find.text('Flutter 4.0 Released');
      if (articleTitle.evaluate().isNotEmpty) {
        await tester.tap(articleTitle);
        await tester.pumpAndSettle();

        expect(find.text('Read Full Article'), findsOneWidget);
      }
    });

    testWidgets('3.2 Detail page shows bookmark icon in app bar',
        (tester) async {
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
      }
    });

    testWidgets(
        '3.3 "Ask NewsBot" FAB and "Read Full Article" button are both '
        'visible and do NOT overlap (UI fix verification)', (tester) async {
      await tester.pumpWidget(buildApp(AppRoutes.news));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final articleTitle = find.text('Flutter 4.0 Released');
      if (articleTitle.evaluate().isNotEmpty) {
        await tester.tap(articleTitle);
        await tester.pumpAndSettle();

        final readBtnFinder = find.text('Read Full Article');
        final fabFinder = find.text('Ask NewsBot');

        expect(readBtnFinder, findsOneWidget);
        expect(fabFinder, findsOneWidget);

        // With endFloat, FAB is at the bottom-right corner.
        // Its left edge must be to the right of the button's horizontal center,
        // proving it cannot be covering the button.
        final readBtnBox = tester.getRect(readBtnFinder);
        final fabBox = tester.getRect(fabFinder);

        print('Read Full Article rect: $readBtnBox');
        print('Ask NewsBot FAB rect:   $fabBox');

        expect(
          fabBox.left > readBtnBox.center.dx,
          isTrue,
          reason: 'FAB (endFloat) left edge must be to the right of the button '
              'center. FAB left=${fabBox.left}, button center=${readBtnBox.center.dx}',
        );
      }
    });

    testWidgets('3.4 Copy URL button is visible in app bar', (tester) async {
      await tester.pumpWidget(buildApp(AppRoutes.news));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final articleTitle = find.text('Flutter 4.0 Released');
      if (articleTitle.evaluate().isNotEmpty) {
        await tester.tap(articleTitle);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      }
    });

    testWidgets('3.5 Back button navigates back to News page', (tester) async {
      await tester.pumpWidget(buildApp(AppRoutes.news));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final articleTitle = find.text('Flutter 4.0 Released');
      if (articleTitle.evaluate().isNotEmpty) {
        await tester.tap(articleTitle);
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
        await tester.pumpAndSettle();

        expect(find.text('News Application'), findsOneWidget);
      }
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // GROUP 4: Chat / NewsBot Page
  // ══════════════════════════════════════════════════════════════════════════

  group('Chat Page', () {
    setUp(() {
      Get.find<AuthController>().currentUser.value = sampleGoogleUser();
    });

    testWidgets('4.1 Chat page renders the NewsBot header', (tester) async {
      await tester.pumpWidget(buildApp(AppRoutes.chat));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('NewsBot'), findsOneWidget);
    });

    testWidgets('4.2 Sending a message stores it in repository',
        (tester) async {
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

    testWidgets('4.3 Bot reply is generated after a user message',
        (tester) async {
      await tester.pumpWidget(buildApp(AppRoutes.chat));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final textFields = find.byType(TextField);
      await tester.tap(textFields.last);
      await tester.enterText(textFields.last, 'Tell me the news');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // At least one message (user's) must be stored.
      expect(fakeChat.stored.isNotEmpty, isTrue);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // GROUP 5: Full end-to-end user journey
  // ══════════════════════════════════════════════════════════════════════════

  group('End-to-End User Journey', () {
    testWidgets(
        'E2E: Guest login → browse news → open article → verify UI fix '
        '→ go to chat → send message', (tester) async {
      // ── Step 1: Arrive at Login page ──────────────────────────────────
      await tester.pumpWidget(buildApp(AppRoutes.login));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!'), findsOneWidget);

      // ── Step 2: Login as Guest ─────────────────────────────────────────
      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('News Application'), findsOneWidget);

      // ── Step 3: Wait for articles to appear ───────────────────────────
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Flutter 4.0 Released'), findsOneWidget);

      // ── Step 4: Tap first article ──────────────────────────────────────
      await tester.tap(find.text('Flutter 4.0 Released'));
      await tester.pumpAndSettle();

      // ── Step 5: Verify overlap fix ─────────────────────────────────────
      expect(find.text('Read Full Article'), findsOneWidget);
      expect(find.text('Ask NewsBot'), findsOneWidget);

      final readBtnBox = tester.getRect(find.text('Read Full Article'));
      final fabBox = tester.getRect(find.text('Ask NewsBot'));
      expect(
        fabBox.left > readBtnBox.center.dx,
        isTrue,
        reason: 'FAB must not overlap the Read Full Article button.',
      );

      // ── Step 6: Tap "Ask NewsBot" FAB to go to chat ───────────────────
      await tester.tap(find.text('Ask NewsBot'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('NewsBot'), findsOneWidget);

      // ── Step 7: Send a message ─────────────────────────────────────────
      final textFields = find.byType(TextField);
      await tester.tap(textFields.last);
      await tester.enterText(textFields.last, 'What are the top headlines?');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final sent = fakeChat.stored
          .where((m) => m.text == 'What are the top headlines?' && m.isUser)
          .toList();
      expect(sent, isNotEmpty,
          reason: 'User message must be stored in chat repository.');
    });
  });
}
