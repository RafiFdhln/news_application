import 'package:get/get.dart';
import '../../data/local/database/database_helper.dart';
import '../../data/local/dao/user_dao.dart';
import '../../data/local/dao/article_dao.dart';
import '../../data/local/dao/message_dao.dart';
import '../../data/local/dao/bookmark_dao.dart';
import '../../data/remote/api/news_api_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/news_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../controllers/auth_controller.dart';
import '../controllers/news_controller.dart';
import '../controllers/chat_controller.dart';
import '../controllers/bookmark_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Database
    Get.put<DatabaseHelper>(DatabaseHelper.instance, permanent: true);

    // DAOs
    Get.put<UserDao>(
      UserDao(Get.find<DatabaseHelper>()),
      permanent: true,
    );
    Get.put<ArticleDao>(
      ArticleDao(Get.find<DatabaseHelper>()),
      permanent: true,
    );
    Get.put<MessageDao>(
      MessageDao(Get.find<DatabaseHelper>()),
      permanent: true,
    );
    Get.put<BookmarkDao>(
      BookmarkDao(Get.find<DatabaseHelper>()),
      permanent: true,
    );

    // Services
    Get.put<NewsApiService>(NewsApiService(), permanent: true);

    // Repositories
    Get.put<AuthRepository>(
      AuthRepository(userDao: Get.find<UserDao>()),
      permanent: true,
    );
    Get.put<NewsRepository>(
      NewsRepository(
        apiService: Get.find<NewsApiService>(),
        articleDao: Get.find<ArticleDao>(),
      ),
      permanent: true,
    );
    Get.put<ChatRepository>(
      ChatRepository(messageDao: Get.find<MessageDao>()),
      permanent: true,
    );

    // Controllers
    Get.put<AuthController>(
      AuthController(authRepository: Get.find<AuthRepository>()),
      permanent: true,
    );
    Get.put<BookmarkController>(
      BookmarkController(bookmarkDao: Get.find<BookmarkDao>()),
      permanent: true,
    );
  }
}

class NewsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewsController>(
      () => NewsController(newsRepository: Get.find<NewsRepository>()),
    );
  }
}

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(
      () => ChatController(chatRepository: Get.find<ChatRepository>()),
    );
  }
}
