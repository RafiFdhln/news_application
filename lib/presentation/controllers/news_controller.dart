import 'package:get/get.dart';
import '../../data/models/article_model.dart';
import '../../data/repositories/news_repository_interface.dart';

class NewsController extends GetxController {
  final NewsRepositoryInterface _newsRepository;

  NewsController({required NewsRepositoryInterface newsRepository})
      : _newsRepository = newsRepository;

  // Observables
  final RxList<ArticleModel> articles = <ArticleModel>[].obs;
  final RxList<ArticleModel> searchResults = <ArticleModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isOffline = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedCategory = 'general'.obs;
  final RxString searchQuery = ''.obs;

  final List<Map<String, String>> categories = [
    {'id': 'general', 'label': 'Top Stories', 'emoji': '🌍'},
    {'id': 'technology', 'label': 'Technology', 'emoji': '💻'},
    {'id': 'business', 'label': 'Business', 'emoji': '💼'},
    {'id': 'sports', 'label': 'Sports', 'emoji': '⚽'},
    {'id': 'entertainment', 'label': 'Entertainment', 'emoji': '🎬'},
    {'id': 'health', 'label': 'Health', 'emoji': '❤️'},
    {'id': 'science', 'label': 'Science', 'emoji': '🔬'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchTopHeadlines();
  }

  Future<void> fetchTopHeadlines({bool forceRefresh = false}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final offline = await _newsRepository.isOffline();
      isOffline.value = offline;

      if (offline) {
        Get.snackbar(
          '📡 Offline Mode',
          'Showing cached news',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }

      final result = await _newsRepository.getTopHeadlines(
        category: selectedCategory.value == 'general' ? null : selectedCategory.value,
        forceRefresh: forceRefresh,
      );
      articles.value = result;
    } catch (e) {
      errorMessage.value = _formatError(e.toString());
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> selectCategory(String categoryId) async {
    if (selectedCategory.value == categoryId) return;
    selectedCategory.value = categoryId;
    await fetchTopHeadlines(forceRefresh: true);
  }

  Future<void> searchArticles(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;
    searchQuery.value = query;
    errorMessage.value = '';

    try {
      final results = await _newsRepository.searchArticles(query);
      searchResults.value = results;
    } catch (e) {
      errorMessage.value = _formatError(e.toString());
    } finally {
      isSearching.value = false;
    }
  }

  @override
  Future<void> refresh() async {
    isRefreshing.value = true;
    await fetchTopHeadlines(forceRefresh: true);
  }

  void clearSearch() {
    searchResults.clear();
    searchQuery.value = '';
    isSearching.value = false;
  }

  String _formatError(String error) {
    if (error.contains('No internet')) {
      return 'No internet connection. Showing cached news.';
    } else if (error.contains('API key') || error.contains('401')) {
      return 'API key error. Please configure a valid NewsAPI key.';
    } else if (error.contains('429')) {
      return 'Rate limit reached. Please try again later.';
    }
    return 'Failed to load news. Pull to refresh.';
  }
}
