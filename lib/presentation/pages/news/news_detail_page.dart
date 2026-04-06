import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/article_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../controllers/bookmark_controller.dart';

class NewsDetailPage extends StatefulWidget {
  const NewsDetailPage({super.key});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  final RxBool _isBookmarked = false.obs;
  ArticleModel? _article;

  @override
  void initState() {
    super.initState();
    _article = Get.arguments as ArticleModel?;
    if (_article != null) {
      _checkBookmark();
    }
  }

  Future<void> _checkBookmark() async {
    final bookmark = Get.find<BookmarkController>();
    final result = await bookmark.isBookmarked(_article!.url);
    _isBookmarked.value = result;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('EEEE, MMMM d, y • h:mm a').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _toggleBookmark() async {
    if (_article == null) return;
    final bookmark = Get.find<BookmarkController>();
    await bookmark.toggleBookmark(_article!);
    _isBookmarked.value = await bookmark.isBookmarked(_article!.url);
  }

  void _openChatBot() {
    Get.toNamed(AppRoutes.chat);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        '⚠️ Error',
        'Could not open the article URL',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E1E30),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_article == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Article')),
        body: const Center(child: Text('Article not found')),
      );
    }
    final article = _article!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero image app bar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            actions: [
              // Bookmark button
              Obx(() => IconButton(
                    onPressed: _toggleBookmark,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _isBookmarked.value
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: _isBookmarked.value
                            ? AppColors.highlight
                            : Colors.white,
                        size: 18,
                      ),
                    ),
                  )),
              // Copy URL button
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: article.url));
                  Get.snackbar(
                    '✅ Copied',
                    'Article URL copied to clipboard',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.surface,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.copy_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              // Ask NewsBot button
              IconButton(
                onPressed: _openChatBot,
                tooltip: 'Ask NewsBot',
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (article.urlToImage != null)
                    CachedNetworkImage(
                      imageUrl: article.urlToImage!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.textHint,
                          size: 48,
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Icon(
                        Icons.newspaper_rounded,
                        color: AppColors.textHint,
                        size: 80,
                      ),
                    ),
                  // Bottom gradient
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xDD0D0D1A)],
                        stops: [0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Article content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source & Date
                  Row(
                    children: [
                      if (article.source?.name != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            article.source!.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Text(
                        _formatDate(article.publishedAt),
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontFamily: 'Poppins',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Author
                  if (article.author != null && article.author!.isNotEmpty)
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.accent,
                          child: Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'By ${article.author}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFF2A2A4A)),
                  const SizedBox(height: 20),

                  // Description
                  if (article.description != null &&
                      article.description!.isNotEmpty) ...[
                    Text(
                      article.description!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Content
                  if (article.content != null &&
                      article.content!.isNotEmpty) ...[
                    Text(
                      _cleanContent(article.content!),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                    const SizedBox(height: 16),

                  // Read Full Article button
                  if (article.url.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => _openUrl(article.url),
                        icon: const Icon(
                          Icons.open_in_browser_rounded,
                          size: 20,
                        ),
                        label: const Text('Read Full Article'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.highlight,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _cleanContent(String content) {
    return content.replaceAll(RegExp(r'\s*\[\+\d+ chars\]'), '...');
  }
}
