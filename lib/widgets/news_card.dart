import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../services/firebase_service.dart';

class NewsCard extends StatefulWidget {
  final NewsModel news;
  final VoidCallback onTap;

  const NewsCard({
    super.key,
    required this.news,
    required this.onTap,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              if (widget.news.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.news.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.image_not_supported_rounded,
                                color: Colors.white54,
                                size: 32,
                              ),
                            );
                          },
                        ),
                        // Gradient overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                                stops: const [0.6, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Action buttons
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Row(
                            children: [
                              _ActionButton(
                                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                                color: _isLiked ? Colors.red : Colors.white,
                                onTap: _toggleLike,
                              ),
                              const SizedBox(width: 8),
                              _ActionButton(
                                icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
                                color: _isSaved ? Colors.yellow : Colors.white,
                                onTap: _toggleSave,
                              ),
                              const SizedBox(width: 8),
                              _ActionButton(
                                icon: Icons.share_rounded,
                                onTap: () {
                                  // Implement share functionality
                                },
                              ),
                            ],
                          ),
                        ),
                        // Headline text
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 0,
                          child: Text(
                            widget.news.headline,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: InkWell(
        onTap: onTap,
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }
}
