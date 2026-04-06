import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../core/constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.usersTable} (
        uid TEXT PRIMARY KEY,
        displayName TEXT,
        email TEXT,
        photoUrl TEXT,
        isGuest INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.articlesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sourceId TEXT,
        sourceName TEXT,
        author TEXT,
        title TEXT NOT NULL,
        description TEXT,
        url TEXT NOT NULL UNIQUE,
        urlToImage TEXT,
        publishedAt TEXT,
        content TEXT,
        cachedAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.messagesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId TEXT NOT NULL,
        type TEXT NOT NULL,
        sender TEXT NOT NULL,
        text TEXT,
        imagePath TEXT,
        sentAt INTEGER NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.bookmarksTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        sourceId TEXT,
        sourceName TEXT,
        author TEXT,
        title TEXT NOT NULL,
        description TEXT,
        url TEXT NOT NULL,
        urlToImage TEXT,
        publishedAt TEXT,
        content TEXT,
        bookmarkedAt INTEGER NOT NULL,
        UNIQUE(userId, url)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppConstants.bookmarksTable} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT NOT NULL,
          sourceId TEXT,
          sourceName TEXT,
          author TEXT,
          title TEXT NOT NULL,
          description TEXT,
          url TEXT NOT NULL,
          urlToImage TEXT,
          publishedAt TEXT,
          content TEXT,
          bookmarkedAt INTEGER NOT NULL,
          UNIQUE(userId, url)
        )
      ''');
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
