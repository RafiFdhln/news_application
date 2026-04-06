import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/article_model.dart';
import '../../../core/constants/app_constants.dart';

class NewsApiService {
  final http.Client _client;

  NewsApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<ArticleModel>> getTopHeadlines({
    String country = 'us',
    String? category,
    String? query,
    int page = 1,
    int pageSize = AppConstants.pageSize,
  }) async {
    final queryParams = {
      'country': country,
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      'apiKey': AppConstants.newsApiKey,
      if (category != null) 'category': category,
      if (query != null && query.isNotEmpty) 'q': query,
    };

    final uri = Uri.parse(
      '${AppConstants.newsApiBaseUrl}/top-headlines',
    ).replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final articles = json['articles'] as List<dynamic>?;
      if (articles == null) return [];
      return articles
          .whereType<Map<String, dynamic>>()
          .map(ArticleModel.fromJson)
          .where((a) => a.title != '[Removed]' && a.url.isNotEmpty)
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API key. Please check your NewsAPI key.');
    } else if (response.statusCode == 429) {
      throw Exception('Rate limit exceeded. Please try again later.');
    } else {
      final body = jsonDecode(response.body) as Map<String, dynamic>?;
      final message = body?['message'] ?? 'Unknown error';
      throw Exception('Failed to fetch news: $message');
    }
  }

  Future<List<ArticleModel>> searchNews({
    required String query,
    String sortBy = 'popularity',
    String language = 'en',
    int page = 1,
    int pageSize = AppConstants.pageSize,
  }) async {
    final queryParams = {
      'q': query,
      'sortBy': sortBy,
      'language': language,
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      'apiKey': AppConstants.newsApiKey,
    };

    final uri = Uri.parse(
      '${AppConstants.newsApiBaseUrl}/everything',
    ).replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final articles = json['articles'] as List<dynamic>?;
      if (articles == null) return [];
      return articles
          .whereType<Map<String, dynamic>>()
          .map(ArticleModel.fromJson)
          .where((a) => a.title != '[Removed]' && a.url.isNotEmpty)
          .toList();
    } else {
      throw Exception(
        'Failed to search news: ${response.statusCode}',
      );
    }
  }

  void dispose() => _client.close();
}
