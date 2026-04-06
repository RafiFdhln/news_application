import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/article_model.dart';
import '../../data/local/dao/bookmark_dao.dart';
import 'auth_controller.dart';

class BookmarkController extends GetxController {
  final BookmarkDao _bookmarkDao;

  BookmarkController({required BookmarkDao bookmarkDao})
      : _bookmarkDao = bookmarkDao;

  final RxList<ArticleModel> bookmarks = <ArticleModel>[].obs;
  final RxBool isLoading = false.obs;

  String? get _userId =>
      Get.find<AuthController>().currentUser.value?.uid;

  @override
  void onInit() {
    super.onInit();
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    final uid = _userId;
    if (uid == null) return;
    isLoading.value = true;
    try {
      bookmarks.value = await _bookmarkDao.getBookmarks(uid);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> isBookmarked(String url) async {
    final uid = _userId;
    if (uid == null) return false;
    return await _bookmarkDao.isBookmarked(uid, url);
  }

  Future<void> toggleBookmark(ArticleModel article) async {
    final uid = _userId;
    if (uid == null) return;

    final alreadyBookmarked =
        await _bookmarkDao.isBookmarked(uid, article.url);
    if (alreadyBookmarked) {
      await _bookmarkDao.removeBookmark(uid, article.url);
      bookmarks.removeWhere((a) => a.url == article.url);
      Get.snackbar(
        '🗑️ Removed',
        'Article removed from bookmarks',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E1E30),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } else {
      await _bookmarkDao.addBookmark(uid, article);
      bookmarks.insert(0, article);
      Get.snackbar(
        '🔖 Bookmarked',
        'Article saved to bookmarks',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F3460),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Future<void> removeBookmark(ArticleModel article) async {
    final uid = _userId;
    if (uid == null) return;
    await _bookmarkDao.removeBookmark(uid, article.url);
    bookmarks.removeWhere((a) => a.url == article.url);
  }

  Future<void> clearAll() async {
    final uid = _userId;
    if (uid == null) return;
    await _bookmarkDao.clearBookmarks(uid);
    bookmarks.clear();
  }
}
