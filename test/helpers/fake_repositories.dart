import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_apps/data/models/article_model.dart';
import 'package:news_apps/data/models/message_model.dart';
import 'package:news_apps/data/models/user_model.dart';
import 'package:news_apps/data/repositories/auth_repository_interface.dart';
import 'package:news_apps/data/repositories/chat_repository_interface.dart';
import 'package:news_apps/data/repositories/news_repository_interface.dart';

// ─── FakeAuthRepository ────────────────────────────────────────────────────────

class FakeAuthRepository implements AuthRepositoryInterface {
  UserModel? _cachedUser;
  UserModel? _googleUser;
  UserModel? _guestUser;
  bool throwOnGoogle = false;
  bool throwOnGuest = false;

  FakeAuthRepository({
    UserModel? guestUser,
    UserModel? cachedUser,
    UserModel? googleUser,
  })  : _guestUser = guestUser,
        _cachedUser = cachedUser,
        _googleUser = googleUser;

  void setGoogleUser(UserModel u) => _googleUser = u;
  void setGuestUser(UserModel u) => _guestUser = u;
  void setCachedUser(UserModel u) => _cachedUser = u;

  @override
  User? get currentFirebaseUser => null;

  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  Future<UserModel?> getCachedUser() async => _cachedUser;

  @override
  Future<UserModel?> getLastCachedUser() async => _cachedUser;

  @override
  Future<UserModel> signInWithGoogle() async {
    if (throwOnGoogle) throw Exception('Google Sign-In cancelled.');
    if (_googleUser == null) throw Exception('No Google user configured');
    return _googleUser!;
  }

  @override
  Future<UserModel> signInAsGuest() async {
    if (throwOnGuest) throw Exception('Guest sign-in failed.');
    if (_guestUser == null) throw Exception('No guest user configured');
    return _guestUser!;
  }

  @override
  Future<void> signOut() async => _cachedUser = null;
}

class FakeNewsRepository implements NewsRepositoryInterface {
  List<ArticleModel> articles;
  bool offlineMode;
  bool shouldThrow;
  String? lastCategory;
  String? lastSearchQuery;

  FakeNewsRepository({
    List<ArticleModel>? articles,
    this.offlineMode = false,
    this.shouldThrow = false,
  }) : articles = articles ?? [];

  @override
  Future<bool> isOffline() async => offlineMode;

  @override
  Future<List<ArticleModel>> getTopHeadlines({
    String country = 'us',
    String? category,
    bool forceRefresh = false,
  }) async {
    lastCategory = category;
    if (shouldThrow) throw Exception('Network error');
    return articles;
  }

  @override
  Future<List<ArticleModel>> searchArticles(String query) async {
    lastSearchQuery = query;
    if (shouldThrow) throw Exception('Search failed');
    return articles;
  }

  @override
  Future<List<ArticleModel>> getCachedArticles() async => articles;
}

class FakeChatRepository implements ChatRepositoryInterface {
  final List<MessageModel> stored = [];
  bool shouldThrow = false;

  @override
  Future<MessageModel> sendMessage({
    required String sessionId,
    required String text,
    required MessageSender sender,
  }) async {
    if (shouldThrow) throw Exception('Send failed');
    final msg = MessageModel(
      id: stored.length + 1,
      sessionId: sessionId,
      type: MessageType.text,
      sender: sender,
      text: text,
      sentAt: DateTime.now(),
    );
    stored.add(msg);
    return msg;
  }

  @override
  Future<MessageModel> sendImage({
    required String sessionId,
    required String imagePath,
    required MessageSender sender,
  }) async {
    final msg = MessageModel(
      id: stored.length + 1,
      sessionId: sessionId,
      type: MessageType.image,
      sender: sender,
      imagePath: imagePath,
      sentAt: DateTime.now(),
    );
    stored.add(msg);
    return msg;
  }

  @override
  Future<List<MessageModel>> getMessages(String sessionId) async =>
      stored.where((m) => m.sessionId == sessionId).toList();

  @override
  Future<void> clearChat(String sessionId) async =>
      stored.removeWhere((m) => m.sessionId == sessionId);

  @override
  String generateBotReply(String userMessage) {
    final lower = userMessage.toLowerCase();
    if (lower.contains('hello') ||
        lower.contains('hi') ||
        lower.contains('hey')) {
      return 'Hello! 👋 I\'m NewsBot.';
    }
    if (lower.contains('news') || lower.contains('headline')) {
      return '📰 Check the News tab for the latest headlines!';
    }
    if (lower.contains('help')) {
      return '🤖 I can help you with news, headlines, and app tips!';
    }
    return '📱 I\'m here to help you stay informed!';
  }
}

List<ArticleModel> sampleArticles() => [
      ArticleModel(
        title: 'Flutter 4.0 Released',
        url: 'https://example.com/flutter-4',
        description: 'Flutter 4.0 brings major improvements to performance.',
        publishedAt: '2024-01-15T10:00:00Z',
        source: SourceModel(name: 'Tech News', id: 'tech'),
      ),
      ArticleModel(
        title: 'Dart Testing Best Practices',
        url: 'https://example.com/dart-testing',
        description: 'Learn how to write great Dart tests.',
        publishedAt: '2024-01-14T09:00:00Z',
        source: SourceModel(name: 'Dev Blog', id: 'dev'),
      ),
    ];

UserModel sampleGuestUser() => UserModel(
      uid: 'guest-uid',
      displayName: 'Guest',
      isGuest: true,
      createdAt: DateTime.now(),
    );

UserModel sampleGoogleUser() => UserModel(
      uid: 'google-uid',
      displayName: 'Test User',
      email: 'test@example.com',
      isGuest: false,
      createdAt: DateTime.now(),
    );
