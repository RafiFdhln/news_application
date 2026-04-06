import 'package:news_apps/data/models/article_model.dart';
import 'package:news_apps/data/local/dao/bookmark_dao.dart';
import 'package:news_apps/data/local/database/database_helper.dart';
import 'package:news_apps/presentation/controllers/bookmark_controller.dart';

/// A no-op BookmarkDao backed by the real DatabaseHelper singleton
/// but with every method overridden to be a no-op — safe for widget tests
/// that never actually open SQLite.
class _NoOpBookmarkDao extends BookmarkDao {
  _NoOpBookmarkDao() : super(DatabaseHelper.instance);

  @override
  Future<void> addBookmark(String userId, ArticleModel article) async {}

  @override
  Future<void> removeBookmark(String userId, String url) async {}

  @override
  Future<bool> isBookmarked(String userId, String url) async => false;

  @override
  Future<List<ArticleModel>> getBookmarks(String userId) async => [];

  @override
  Future<void> clearBookmarks(String userId) async {}
}

/// Stub [BookmarkController] with an empty in-memory bookmark list.
/// Suitable for widget tests that render pages requiring BookmarkController.
class FakeBookmarkController extends BookmarkController {
  FakeBookmarkController() : super(bookmarkDao: _NoOpBookmarkDao());

  @override
  void onInit() {
    // Do NOT call super.onInit() to avoid triggering loadBookmarks()
    // which would try to open SQLite in a test environment.
    isLoading.value = false;
  }
}
