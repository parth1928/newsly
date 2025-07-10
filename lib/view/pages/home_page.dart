import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/news_model.dart';
import '../../constants/style_constants.dart';
import '../../widgets/home_news_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<NewsModel> _newsArticles = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchNewsArticles();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchNewsArticles() async {
    try {
      final articles = await _firebaseService.fetchNewsArticles();
      setState(() {
        _newsArticles = articles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching news articles: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _fetchNewsArticles,
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              centerTitle: true,
              title: const Text('Newsly'),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final article = _newsArticles[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: HomeNewsCard(
                        news: article,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenNewsView(
                              title: article.headline,
                              content: article.content,
                              imageUrl: article.imageUrl,
                              articleId: article.id,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _newsArticles.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenNewsView extends StatelessWidget {
  final String title;
  final String content;
  final String imageUrl;
  final String articleId;

  const FullScreenNewsView({
    super.key,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.articleId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'news_$articleId',
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          size: 40,
                          color: Colors.white54,
                        ),
                      ),
                    );
                  },
                ),
              ),
              title: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              titlePadding: EdgeInsets.zero,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: Colors.grey[300],
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.favorite_border_rounded),
                            onPressed: () {},
                            splashRadius: 24,
                            iconSize: 24,
                            color: Colors.grey[400],
                          ),
                          IconButton(
                            icon: const Icon(Icons.bookmark_border_rounded),
                            onPressed: () {},
                            splashRadius: 24,
                            iconSize: 24,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_rounded),
                        onPressed: () {},
                        splashRadius: 24,
                        iconSize: 24,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}