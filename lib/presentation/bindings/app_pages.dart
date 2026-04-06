import 'package:get/get.dart';
import '../../core/constants/app_routes.dart';
import '../bindings/app_binding.dart';
import '../pages/splash/splash_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/news/news_page.dart';
import '../pages/news/news_detail_page.dart';
import '../pages/chat/chat_page.dart';
import '../pages/bookmark/bookmark_page.dart';
import '../pages/profile/profile_page.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: AppRoutes.news,
      page: () => const NewsPage(),
      binding: NewsBinding(),
    ),
    GetPage(
      name: AppRoutes.newsDetail,
      page: () => const NewsDetailPage(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatPage(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.bookmark,
      page: () => const BookmarkPage(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
    ),
  ];
}
