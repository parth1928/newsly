import 'package:flutter/material.dart';
import '../../constants/style_constants.dart';
import '../../models/news_model.dart';
import '../../services/firebase_service.dart';
import '../../widgets/full_screen_news_card.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';


class SwipeNewsScreen extends StatefulWidget {
  const SwipeNewsScreen({super.key});

  @override
  State<SwipeNewsScreen> createState() => _SwipeNewsScreenState();
}

class _SwipeNewsScreenState extends State<SwipeNewsScreen> {
  final CardSwiperController controller = CardSwiperController();
  final FirebaseService _firebaseService = FirebaseService();
  List<NewsModel>? _newsArticles;
  Map<String, bool> _likedStatus = {};
  Map<String, bool> _savedStatus = {};

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    final articles = await _firebaseService.fetchNewsArticles();
    // Check like and save status for each article
    Map<String, bool> likedStatus = {};
    Map<String, bool> savedStatus = {};
    for (var article in articles) {
      likedStatus[article.id] = await _firebaseService.isNewsLiked(article.id);
      savedStatus[article.id] = await _firebaseService.isNewsSaved(article.id);
    }
    setState(() {
      _newsArticles = articles;
      _likedStatus = likedStatus;
      _savedStatus = savedStatus;
    });
  }

  Future<void> _toggleSave(String articleId) async {
    try {
      await _firebaseService.toggleSaveArticle(articleId);
      setState(() {
        _savedStatus[articleId] = !(_savedStatus[articleId] ?? false);
      });
    } catch (e) {
      print('Error toggling save: $e');
    }
  }

  Future<void> _toggleLike(String articleId) async {
    try {
      await _firebaseService.toggleLikeNews(articleId);
      setState(() {
        _likedStatus[articleId] = !(_likedStatus[articleId] ?? false);
      });
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_newsArticles == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
        ),
      );
    }

    if (_newsArticles!.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            'No more news articles',
            style: AppTypography.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Discover News',
                        style: AppTypography.heading2.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.refresh_rounded,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),
                          onPressed: _loadNews,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: CardSwiper(
                    controller: controller,
                    cardsCount: _newsArticles!.length,
                    onSwipe: (previousIndex, currentIndex, direction) async {
                      if (direction == CardSwiperDirection.right) {
                      final article = _newsArticles![previousIndex];
                      if (!(_likedStatus[article.id] ?? false)) {
                        await _toggleLike(article.id);
                      }
                      } else if (direction == CardSwiperDirection.left) {
                      final article = _newsArticles![previousIndex];
                      if (_likedStatus[article.id] ?? false) {
                        await _toggleLike(article.id);
                      }
                      }
                      return true;
                    },
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
                    cardBuilder: (context, index, previousIndex, direction) =>
                      _buildNewsCard(_newsArticles![index]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  Widget _buildNewsCard(NewsModel news) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FullScreenNewsCard(news: news),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.network(
                      news.imageUrl,
                      height: MediaQuery.of(context).size.height * 0.35, // Slightly increased height
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          news.category.toUpperCase(),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), // Increased padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                        news.headline,
                        style: AppTypography.heading3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 18, // Adjusted font size
                        height: 1.2,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                        const SizedBox(height: 10),
                    Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_outline_rounded,
                                    size: 14,
                                    color: AppColors.textSecondary.withOpacity(0.8),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      news.author,
                                      style: TextStyle(
                                        color: AppColors.textSecondary.withOpacity(0.8),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 15,
                                    color: AppColors.textSecondary.withOpacity(0.8),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getTimeAgo(news.timestamp),
                                    style: TextStyle(
                                      color: AppColors.textSecondary.withOpacity(0.8),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                              if (_likedStatus[news.id] ?? false)
                                Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.favorite,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => _toggleSave(news.id),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Icon(
                                  _savedStatus[news.id] ?? false
                                    ? Icons.bookmark
                                    : Icons.bookmark_outline_rounded,
                                  size: 18,
                                  color: _savedStatus[news.id] ?? false
                                    ? Colors.yellow
                                    : AppColors.textSecondary.withOpacity(0.8),
                                  ),
                                ),
                                ),
                              ),
                                const SizedBox(width: 4),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Image.asset(
                                    'assets/share/icons8-share-windows-11-filled-32.png',
                                    width: 18,
                                    height: 18,
                                    color: AppColors.textSecondary.withOpacity(0.8),
                                    ),
                                  ),
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                          news.content,
                          style: AppTypography.body1.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 15, // Increased font size
                            height: 1.3,
                          ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
