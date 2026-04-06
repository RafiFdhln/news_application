class AppConstants {
  // News API
  static const String newsApiBaseUrl = 'https://newsapi.org/v2';
  static const String newsApiKey = '01511cc4ad5e403daa81a030a43a8e44';

  // SQLite
  static const String dbName = 'news_app.db';
  static const int dbVersion = 2;

  // Tables
  static const String usersTable = 'users';
  static const String articlesTable = 'articles';
  static const String messagesTable = 'messages';
  static const String bookmarksTable = 'bookmarks';

  // Cache duration (seconds)
  static const int cacheDuration = 3600;

  // Chatbot name
  static const String botName = 'NewsBot';
  static const String botAvatar = 'NB';

  // Pagination
  static const int pageSize = 20;
}
