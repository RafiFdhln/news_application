import 'package:sqflite/sqflite.dart';
import '../../models/article_model.dart';
import '../database/database_helper.dart';
import '../../../core/constants/app_constants.dart';

class BookmarkDao {
  final DatabaseHelper _dbHelper;

  BookmarkDao(this._dbHelper);

  Future<void> addBookmark(String userId, ArticleModel article) async {
    final db = await _dbHelper.database;
    await db.insert(
      AppConstants.bookmarksTable,
      {
        'userId': userId,
        'sourceId': article.source?.id,
        'sourceName': article.source?.name,
        'author': article.author,
        'title': article.title,
        'description': article.description,
        'url': article.url,
        'urlToImage': article.urlToImage,
        'publishedAt': article.publishedAt,
        'content': article.content,
        'bookmarkedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeBookmark(String userId, String url) async {
    final db = await _dbHelper.database;
    await db.delete(
      AppConstants.bookmarksTable,
      where: 'userId = ? AND url = ?',
      whereArgs: [userId, url],
    );
  }

  Future<bool> isBookmarked(String userId, String url) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      AppConstants.bookmarksTable,
      where: 'userId = ? AND url = ?',
      whereArgs: [userId, url],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<List<ArticleModel>> getBookmarks(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.bookmarksTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'bookmarkedAt DESC',
    );
    return maps.map((m) => ArticleModel.fromMap(m)).toList();
  }

  Future<void> clearBookmarks(String userId) async {
    final db = await _dbHelper.database;
    await db.delete(
      AppConstants.bookmarksTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}
