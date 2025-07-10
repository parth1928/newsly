import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../constants/style_constants.dart';
import '../services/firebase_service.dart';

class FullScreenNewsCard extends StatefulWidget {
  final NewsModel news;
  const FullScreenNewsCard({super.key, required this.news});

  @override
  State<FullScreenNewsCard> createState() => _FullScreenNewsCardState();
}

class _FullScreenNewsCardState extends State<FullScreenNewsCard> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLiked = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkLikeAndSaveStatus();
  }

  Future<void> _checkLikeAndSaveStatus() async {
    try {
      final isLiked = await _firebaseService.isNewsLiked(widget.news.id);
      final isSaved = await _firebaseService.isNewsSaved(widget.news.id);
      if (mounted) {
        setState(() {
          _isLiked = isLiked;
          _isSaved = isSaved;
        });
      }
    } catch (e) {
      print('Error checking like/save status: $e');
    }
  }

  Future<void> _toggleLike() async {
    try {
      await _firebaseService.toggleLikeNews(widget.news.id);
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
        });
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Future<void> _toggleSave() async {
    try {
      await _firebaseService.toggleSaveArticle(widget.news.id);
      if (mounted) {
        setState(() {
          _isSaved = !_isSaved;
        });
      }
    } catch (e) {
      print('Error toggling save: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 90;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'news_image_${widget.news.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24)),
                    child: Image.network(
                      widget.news.imageUrl,
                      height: screenHeight * 0.3,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: screenHeight * 0.35,
                          color: AppColors.surface,
                          child: Icon(Icons.error,
                              color: AppColors.textSecondary, size: 48),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          color: AppColors.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.news.category.toUpperCase(),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(widget.news.timestamp),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.news.headline,
                    style: AppTypography.heading2.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.2,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.accent.withOpacity(0.1),
                            child: Text(
                              widget.news.author[0].toUpperCase(),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.news.author,
                            style: AppTypography.body2.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border_outlined,
                              color: _isLiked
                                  ? Colors.red
                                  : AppColors.textSecondary,
                            ),
                            onPressed: _toggleLike,
                          ),
                          IconButton(
                            icon: Icon(Icons.share_outlined,
                                color: AppColors.textSecondary),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(
                              _isSaved
                                  ? Icons.bookmark
                                  : Icons.bookmark_border_outlined,
                              color: _isSaved
                                  ? Colors.yellow
                                  : AppColors.textSecondary,
                            ),
                            onPressed: _toggleSave,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
                physics: const BouncingScrollPhysics(),
                child: Text(
                  widget.news.content,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
