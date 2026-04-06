import '../models/article_model.dart';

abstract class NewsRepositoryInterface {
  Future<bool> isOffline();
  Future<List<ArticleModel>> getTopHeadlines({
    String country,
    String? category,
    bool forceRefresh,
  });
  Future<List<ArticleModel>> searchArticles(String query);
  Future<List<ArticleModel>> getCachedArticles();
}
