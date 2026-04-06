import 'package:sqflite/sqflite.dart';
import '../../models/article_model.dart';
import '../database/database_helper.dart';
import '../../../core/constants/app_constants.dart';

class ArticleDao {
  final DatabaseHelper _dbHelper;

  ArticleDao(this._dbHelper);

  Future<void> insertArticles(List<ArticleModel> articles) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final article in articles) {
      batch.insert(
        AppConstants.articlesTable,
        article.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<ArticleModel>> getAllArticles() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.articlesTable,
      orderBy: 'cachedAt DESC',
    );
    return maps.map(ArticleModel.fromMap).toList();
  }

  Future<ArticleModel?> getArticleByUrl(String url) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.articlesTable,
      where: 'url = ?',
      whereArgs: [url],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ArticleModel.fromMap(maps.first);
  }

  Future<bool> isCacheValid() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT cachedAt FROM ${AppConstants.articlesTable} ORDER BY cachedAt DESC LIMIT 1',
    );
    if (result.isEmpty) return false;
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(
      result.first['cachedAt'] as int,
    );
    return DateTime.now().difference(cachedAt).inSeconds <
        AppConstants.cacheDuration;
  }

  Future<void> clearAll() async {
    final db = await _dbHelper.database;
    await db.delete(AppConstants.articlesTable);
  }

  Future<void> clearExpired() async {
    final db = await _dbHelper.database;
    final expiryTime =
        DateTime.now()
            .subtract(const Duration(seconds: AppConstants.cacheDuration))
            .millisecondsSinceEpoch;
    await db.delete(
      AppConstants.articlesTable,
      where: 'cachedAt < ?',
      whereArgs: [expiryTime],
    );
  }
}
