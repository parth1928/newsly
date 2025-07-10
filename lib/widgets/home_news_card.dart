import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../constants/style_constants.dart';
import 'full_screen_news_card.dart';
import '../services/firebase_service.dart';

class HomeNewsCard extends StatefulWidget {
  final NewsModel news;
  final VoidCallback onTap;

  const HomeNewsCard({
    super.key,
    required this.news,
    required this.onTap,
  });

  @override
  State<HomeNewsCard> createState() => _HomeNewsCardState();
}

class _HomeNewsCardState extends State<HomeNewsCard> {
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => Scaffold(
            body: FullScreenNewsCard(news: widget.news),
          ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: Offset(0, 6),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                widget.news.imageUrl,
                width: double.infinity,
                height: 320,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 320,
                    color: AppColors.surface,
                    child: Icon(Icons.error, color: AppColors.textSecondary),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.5, 0.7],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {},
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: Image.asset(
                      'assets/share/icons8-share-windows-11-filled-96.png',
                      width: 22,
                      height: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.news.headline,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      fontFamily: 'Roboto',
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.news.author,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                            GestureDetector(
                            onTap: _toggleLike,
                            child: Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border_outlined,
                              color: _isLiked ? Colors.red : Colors.white,
                              size: 18,
                            ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                            onTap: _toggleSave,
                            child: Icon(
                              _isSaved ? Icons.bookmark : Icons.bookmark_border_outlined,
                              color: _isSaved ? Colors.yellow : Colors.white,
                              size: 18,
                            ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
