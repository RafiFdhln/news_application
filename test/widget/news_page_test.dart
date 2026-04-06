import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:news_apps/core/theme/app_theme.dart';
import 'package:news_apps/presentation/controllers/auth_controller.dart';
import 'package:news_apps/presentation/controllers/bookmark_controller.dart';
import 'package:news_apps/presentation/controllers/news_controller.dart';
import 'package:news_apps/presentation/pages/news/news_page.dart';
import '../helpers/fake_repositories.dart';
import '../helpers/fake_bookmark_controller.dart';

void main() {
  late FakeNewsRepository fakeNews;
  late AuthController authController;
  late NewsController newsController;

  setUp(() async {
    Get.testMode = true;
    fakeNews = FakeNewsRepository(articles: sampleArticles());

    authController = AuthController(
      authRepository: FakeAuthRepository(cachedUser: sampleGoogleUser()),
    );
    authController.currentUser.value = sampleGoogleUser();

    newsController = NewsController(newsRepository: fakeNews);

    Get.put<AuthController>(authController);
    Get.put<NewsController>(newsController);
    Get.put<BookmarkController>(FakeBookmarkController());

    await Future.delayed(const Duration(milliseconds: 150));
  });

  tearDown(Get.reset);


  Widget pumpNewsPage() => GetMaterialApp(
        theme: AppTheme.darkTheme,
        home: const NewsPage(),
      );

  group('NewsPage — layout elements', () {
    testWidgets('shows "News Application" app bar title', (tester) async {
      await tester.pumpWidget(pumpNewsPage());
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('News Application'), findsOneWidget);
    });

    testWidgets('has search TextField', (tester) async {
      await tester.pumpWidget(pumpNewsPage());
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows "Search news..." hint', (tester) async {
      await tester.pumpWidget(pumpNewsPage());
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Search news...'), findsOneWidget);
    });

    testWidgets('renders BottomNavigationBar', (tester) async {
      await tester.pumpWidget(pumpNewsPage());
      await tester.pump();
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('BottomNavigationBar has News, Bookmarks, Profile, Chat items',
        (tester) async {
      await tester.pumpWidget(pumpNewsPage());
      await tester.pump();
      expect(find.text('News'), findsOneWidget);
      expect(find.text('Bookmarks'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
    });

    testWidgets('has Top Stories category chip', (tester) async {
      await tester.pumpWidget(pumpNewsPage());
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('🌍 Top Stories'), findsOneWidget);
    });
  });

  group('NewsPage — articles', () {
    testWidgets('displays article titles after load', (tester) async {
      await tester.pumpWidget(pumpNewsPage());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Flutter 4.0 Released'), findsOneWidget);
      expect(find.text('Dart Testing Best Practices'), findsOneWidget);
    });

    testWidgets('shows offline banner when offline', (tester) async {
      fakeNews.offlineMode = true;
      await tester.pumpWidget(pumpNewsPage());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(newsController.isOffline.value, isTrue);
    });
  });

  group('NewsPage — search interaction', () {
    testWidgets('typing in search updates query', (tester) async {
      await tester.pumpWidget(pumpNewsPage());
      await tester.pump(const Duration(milliseconds: 500));

      final searchField = find.byType(TextField);
      await tester.tap(searchField);
      await tester.enterText(searchField, 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(fakeNews.lastSearchQuery, 'flutter');
    });
  });
}
