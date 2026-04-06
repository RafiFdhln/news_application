import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:news_apps/data/models/article_model.dart';
import 'package:news_apps/presentation/controllers/news_controller.dart';
import '../helpers/fake_repositories.dart';

void main() {
  late FakeNewsRepository fakeNews;
  late NewsController newsController;

  setUp(() async {
    Get.testMode = true;
    fakeNews = FakeNewsRepository(articles: sampleArticles());
    newsController = NewsController(newsRepository: fakeNews);
    await Future.delayed(const Duration(milliseconds: 150));
  });

  tearDown(Get.reset);

  group('NewsController — defaults', () {
    test('selectedCategory starts as "general"', () {
      expect(newsController.selectedCategory.value, 'general');
    });

    test('has exactly 7 categories', () {
      expect(newsController.categories.length, 7);
    });

    test('categories includes expected ids', () {
      final ids = newsController.categories.map((c) => c['id']).toSet();
      expect(ids, containsAll(['general', 'technology', 'business', 'sports']));
    });

    test('searchQuery starts empty', () {
      expect(newsController.searchQuery.value, '');
    });
  });

  group('NewsController — fetchTopHeadlines', () {
    test('populates articles on success', () async {
      await newsController.fetchTopHeadlines();

      expect(newsController.articles.length, 2);
      expect(newsController.articles.first.title, 'Flutter 4.0 Released');
      expect(newsController.isLoading.value, false);
    });

    test('sets errorMessage on network failure', () async {
      fakeNews.shouldThrow = true;
      await newsController.fetchTopHeadlines();

      expect(newsController.errorMessage.value.isNotEmpty, true);
      expect(newsController.isLoading.value, false);
    });

    test('sets isOffline=true when offline', () async {
      fakeNews.offlineMode = true;
      await newsController.fetchTopHeadlines();

      expect(newsController.isOffline.value, true);
    });

    test('sets isOffline=false when online', () async {
      await newsController.fetchTopHeadlines();
      expect(newsController.isOffline.value, false);
    });
  });

  group('NewsController — selectCategory', () {
    test('updates selectedCategory', () async {
      await newsController.selectCategory('technology');
      expect(newsController.selectedCategory.value, 'technology');
    });

    test('does not re-fetch when same category selected', () async {
      newsController.selectedCategory.value = 'sports';
      fakeNews.lastCategory = null; // reset tracker

      await newsController.selectCategory('sports');

      // No new fetch should have been triggered
      expect(fakeNews.lastCategory, isNull);
    });

    test('passes category to repository', () async {
      await newsController.selectCategory('health');
      expect(fakeNews.lastCategory, 'health');
    });

    test('passes null when "general" category selected', () async {
      await newsController.selectCategory('general');
      expect(fakeNews.lastCategory, isNull);
    });
  });

  group('NewsController — search', () {
    test('populates searchResults on valid query', () async {
      await newsController.searchArticles('flutter');

      expect(newsController.searchResults.length, 2);
      expect(newsController.searchQuery.value, 'flutter');
    });

    test('passes query to repository', () async {
      await newsController.searchArticles('dart');
      expect(fakeNews.lastSearchQuery, 'dart');
    });

    test('clears results for empty query', () async {
      newsController.searchResults.value = sampleArticles();
      await newsController.searchArticles('');

      expect(newsController.searchResults.isEmpty, true);
      expect(newsController.isSearching.value, false);
    });

    test('clearSearch resets all search state', () {
      newsController.searchResults.value = sampleArticles();
      newsController.searchQuery.value = 'test';
      newsController.isSearching.value = true;

      newsController.clearSearch();

      expect(newsController.searchResults.isEmpty, true);
      expect(newsController.searchQuery.value, '');
      expect(newsController.isSearching.value, false);
    });
  });

  group('ArticleModel — model tests', () {
    test('isExpired returns true when cachedAt is null', () {
      final a = ArticleModel(title: 'Test', url: 'https://test.com');
      expect(a.isExpired, isTrue);
    });

    test('isExpired returns false for recently cached article', () {
      final a = ArticleModel(
        title: 'Test',
        url: 'https://test.com',
        cachedAt: DateTime.now(),
      );
      expect(a.isExpired, isFalse);
    });

    test('fromJson parses source correctly', () {
      final json = {
        'title': 'Hello',
        'url': 'https://example.com',
        'source': {'name': 'BBC', 'id': 'bbc'},
        'publishedAt': '2024-01-01T00:00:00Z',
      };
      final article = ArticleModel.fromJson(json);
      expect(article.source?.name, 'BBC');
      expect(article.title, 'Hello');
    });

    test('toMap/fromMap round-trip preserves fields', () {
      final a = ArticleModel(
        title: 'Round Trip',
        url: 'https://rt.com',
        description: 'description text',
        author: 'Author Name',
        source: SourceModel(name: 'Source', id: 'src'),
      );
      final map = a.toMap();
      final restored = ArticleModel.fromMap(map);
      expect(restored.title, a.title);
      expect(restored.url, a.url);
      expect(restored.description, a.description);
      expect(restored.source?.name, a.source?.name);
    });
  });
}
