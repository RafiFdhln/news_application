import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/article_model.dart';
import '../local/dao/article_dao.dart';
import '../remote/api/news_api_service.dart';
import 'news_repository_interface.dart';

class NewsRepository implements NewsRepositoryInterface {
  final NewsApiService _apiService;
  final ArticleDao _articleDao;
  final Connectivity _connectivity;

  NewsRepository({
    required NewsApiService apiService,
    required ArticleDao articleDao,
    Connectivity? connectivity,
  })  : _apiService = apiService,
        _articleDao = articleDao,
        _connectivity = connectivity ?? Connectivity();

  Future<bool> _isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Fetches top headlines. Returns cached data if offline or cache is valid.
  @override
  Future<List<ArticleModel>> getTopHeadlines({
    String country = 'us',
    String? category,
    bool forceRefresh = false,
  }) async {
    final connected = await _isConnected();

    if (!connected) {
      // Offline: return cached articles
      return await _articleDao.getAllArticles();
    }

    // Online: check cache validity
    if (!forceRefresh && await _articleDao.isCacheValid()) {
      final cached = await _articleDao.getAllArticles();
      if (cached.isNotEmpty) return cached;
    }

    // Fetch from API and cache
    final articles = await _apiService.getTopHeadlines(
      country: country,
      category: category,
    );

    if (articles.isNotEmpty) {
      await _articleDao.clearAll();
      await _articleDao.insertArticles(articles);
    }

    return articles;
  }

  @override
  Future<List<ArticleModel>> searchArticles(String query) async {
    final connected = await _isConnected();
    if (!connected) {
      throw Exception('No internet connection. Cannot search articles.');
    }
    return await _apiService.searchNews(query: query);
  }

  @override
  Future<List<ArticleModel>> getCachedArticles() async {
    return await _articleDao.getAllArticles();
  }

  @override
  Future<bool> isOffline() async => !(await _isConnected());
}
