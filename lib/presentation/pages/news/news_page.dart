import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../controllers/news_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/bookmark_controller.dart';
import 'widgets/news_card.dart';
import 'widgets/news_card_shimmer.dart';
import '../bookmark/bookmark_page.dart';
import '../profile/profile_page.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _currentNavIndex = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final news = Get.find<NewsController>();
    final auth = Get.find<AuthController>();
    final bookmark = Get.find<BookmarkController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildNewsTab(news, auth),
          const BookmarkPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(bookmark),
    );
  }

  Widget _buildBottomNav(BookmarkController bookmark) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: Color(0xFF2A2A4A), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 3) {
            // Chat tab — navigate to chat page
            Get.toNamed(AppRoutes.chat);
            return;
          }
          setState(() => _currentNavIndex = index);
        },
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.highlight,
        unselectedItemColor: AppColors.textHint,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
        ),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.newspaper_outlined),
            activeIcon: Icon(Icons.newspaper_rounded),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Obx(() => Badge(
                  isLabelVisible: bookmark.bookmarks.isNotEmpty,
                  label: Text('${bookmark.bookmarks.length}'),
                  child: const Icon(Icons.bookmark_border_rounded),
                )),
            activeIcon: Obx(() => Badge(
                  isLabelVisible: bookmark.bookmarks.isNotEmpty,
                  label: Text('${bookmark.bookmarks.length}'),
                  child: const Icon(Icons.bookmark_rounded),
                )),
            label: 'Bookmarks',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
        ],
      ),
    );
  }

  Widget _buildNewsTab(NewsController news, AuthController auth) {
    return RefreshIndicator(
      color: AppColors.highlight,
      backgroundColor: AppColors.surface,
      onRefresh: news.refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // App Bar
          _buildSliverAppBar(auth, news),

          // Offline Banner
          SliverToBoxAdapter(
            child: Obx(() {
              if (!news.isOffline.value) return const SizedBox.shrink();
              return _buildOfflineBanner();
            }),
          ),

          // Search Bar
          SliverToBoxAdapter(child: _buildSearchBar(news)),

          // Category Chips
          SliverToBoxAdapter(child: _buildCategoryChips(news)),

          // Search Results or Normal News
          Obx(() {
            if (news.isSearching.value) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(
                      color: AppColors.highlight,
                    ),
                  ),
                ),
              );
            }

            if (news.searchQuery.value.isNotEmpty) {
              return _buildSearchResults(news);
            }

            if (news.isLoading.value) {
              return _buildShimmerList();
            }

            if (news.errorMessage.value.isNotEmpty && news.articles.isEmpty) {
              return SliverToBoxAdapter(child: _buildErrorWidget(news));
            }

            if (news.articles.isEmpty) {
              return SliverToBoxAdapter(child: _buildEmptyWidget());
            }

            return _buildArticleList(news);
          }),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(AuthController auth, NewsController news) {
    return SliverAppBar(
      expandedHeight: 60,
      floating: true,
      snap: true,
      pinned: false,
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.newspaper_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'News Application',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        Obx(() => news.isOffline.value
            ? const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.wifi_off_rounded,
                  color: AppColors.warning,
                  size: 22,
                ),
              )
            : const SizedBox.shrink()),
        // Avatar tap to go profile
        GestureDetector(
          onTap: () => setState(() => _currentNavIndex = 2),
          child: Obx(() {
            final user = auth.currentUser.value;
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: user?.photoUrl != null && !user!.isGuest
                  ? CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(user.photoUrl!),
                      backgroundColor: AppColors.surface,
                    )
                  : const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.accent,
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: AppColors.warning.withAlpha(38),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, color: AppColors.warning, size: 16),
          SizedBox(width: 8),
          Text(
            'Offline mode — showing cached news',
            style: TextStyle(
              color: AppColors.warning,
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(NewsController news) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Poppins',
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Search news...',
          hintStyle: const TextStyle(color: AppColors.textHint),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textHint,
          ),
          suffixIcon: Obx(() => news.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textHint),
                  onPressed: () {
                    _searchCtrl.clear();
                    news.clearSearch();
                  },
                )
              : const SizedBox.shrink()),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onSubmitted: news.searchArticles,
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildCategoryChips(NewsController news) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: news.categories.length,
        itemBuilder: (context, i) {
          final cat = news.categories[i];
          return Obx(() {
            final isSelected = news.selectedCategory.value == cat['id'];
            return GestureDetector(
              onTap: () => news.selectCategory(cat['id']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.accentGradient : null,
                  color: isSelected ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFF2A2A4A),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${cat['emoji']} ${cat['label']}',
                  style: TextStyle(
                    color:
                        isSelected ? Colors.white : AppColors.textSecondary,
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  SliverList _buildShimmerList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => const NewsCardShimmer(),
        childCount: 5,
      ),
    );
  }

  SliverList _buildArticleList(NewsController news) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final article = news.articles[i];
          return NewsCard(
            article: article,
            isFeatured: i == 0,
          );
        },
        childCount: news.articles.length,
      ),
    );
  }

  SliverList _buildSearchResults(NewsController news) {
    if (news.searchResults.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          _buildEmptySearchWidget(),
        ]),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) => NewsCard(article: news.searchResults[i]),
        childCount: news.searchResults.length,
      ),
    );
  }

  Widget _buildErrorWidget(NewsController news) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.textHint,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              news.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textHint,
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: news.refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.newspaper_rounded,
              color: AppColors.textHint,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No articles found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Pull down to refresh',
              style: TextStyle(
                color: AppColors.textHint,
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearchWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              color: AppColors.textHint,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(
                color: AppColors.textHint,
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
