import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/news_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addTestData() async {
    try {
      print('Starting test data initialization...');
      
      final userEmail = _auth.currentUser?.email;
      if (userEmail == null) {
        print('No user logged in during test data initialization');
        return;
      }

      // Initialize user data first
      await initializeUserData(_auth.currentUser!);
      
      print('Checking Firestore connection...');

      // Verify Firestore connection and permissions
      try {
        await _firestore.collection('news').get();
        print('Firestore connection and permissions verified');
      } catch (e) {
        print('Error accessing Firestore: $e');
        throw Exception(
            'Firestore access denied. Please check security rules.');
      }

      // Check if test data already exists
      final existingDocs = await _firestore.collection('news').limit(1).get();
      print('Found ${existingDocs.docs.length} existing documents');

      if (existingDocs.docs.isNotEmpty) {
        print('Test data already exists, skipping initialization');
        return;
      }

        final testArticles = [
        {
          'headline': 'Flutter 3.0 Released',
          'content':
            'Flutter 3.0 brings significant improvements to performance and new features including Material 3 support, casual gaming toolkit, and enhanced platform integration...',
          'imageUrl': 'https://picsum.photos/800/400',
          'category': 'technology',
          'timestamp': Timestamp.now(),
          'author': 'Tech News',
          'likes': 42,
          'subtitle': 'Major update brings new features',
        },
        {
          'headline': 'The Rise of Neo-Brutalism in Web Design',
          'content':
            'Neo-brutalism is making waves in modern web design with its bold and unapologetic approach. This design trend emphasizes raw functionality, exposed elements, and high-contrast visuals...',
          'imageUrl': 'https://picsum.photos/800/401',
          'category': 'design',
          'timestamp': Timestamp.now(),
          'author': 'Design Weekly',
          'likes': 28,
          'subtitle': 'New design trends shaping the web',
        },
        {
          'headline': 'Firebase Updates Its Real-time Database',
          'content':
            'Firebase announces major updates to its real-time database with improved performance, enhanced security features, and new integration options for modern web applications...',
          'imageUrl': 'https://picsum.photos/800/402',
          'category': 'technology',
          'timestamp': Timestamp.now(),
          'author': 'Firebase Team',
          'likes': 35,
          'subtitle': 'Enhanced performance and security features',
        },
        {
          'headline': 'Mobile App Development Trends 2024',
          'content':
            'Discover the latest trends in mobile app development, from AI integration to cross-platform solutions and enhanced user experiences using modern frameworks...',
          'imageUrl': 'https://picsum.photos/800/403',
          'category': 'technology',
          'timestamp': Timestamp.now(),
          'author': 'Mobile Dev Insights',
          'likes': 31,
          'subtitle': 'Future of mobile development',
        },
      ];

      print('Starting to add ${testArticles.length} test articles...');

      for (final article in testArticles) {
        try {
          print('Adding article: ${article['headline']}');
          print('Article data: $article');
          final docRef = await _firestore.collection('news').add(article);

          // Verify the document was added
          final addedDoc = await docRef.get();
          if (addedDoc.exists) {
            print(
                'Successfully added and verified article with ID: ${docRef.id}');
          } else {
            print('Warning: Document added but not found on verification');
          }
        } catch (e) {
          print('Error adding article "${article['headline']}": $e');
        }
      }

      // Verify final count
      final finalCount = await _firestore.collection('news').count().get();
      print(
          'Test data initialization complete. Total documents: ${finalCount.count}');
    } catch (e) {
      print('Error during test data initialization: $e');
      throw Exception('Failed to initialize test data: $e');
    }
  }

  // Fetch news articles with pagination
  Future<List<NewsModel>> fetchNewsArticles({
    String? category,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    try {
      print('\nStarting news articles fetch...');
      print(
          'Parameters - Category: $category, Limit: $limit, Has lastDocument: ${lastDocument != null}');

      // First, verify collection exists and is accessible
      try {
        final collectionRef = _firestore.collection('news');
        final count = await collectionRef.count().get();
        print('Total documents in collection: ${count.count}');
      } catch (e) {
        print('Error accessing news collection: $e');
        throw Exception(
            'Cannot access news collection. Check Firestore rules.');
      }

      Query query = _firestore
          .collection('news')
          //.orderBy('timestamp', descending: true)
          .limit(limit);

      if (category != null) {
        print('Applying category filter: $category');
        query = query.where('category', isEqualTo: category);
      }

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      print('Query: ${query.parameters.toString()}'); // Log query parameters
      final snapshot = await query.get();
      print('Fetched ${snapshot.docs.length} documents');
      print('Query complete. Found ${snapshot.docs.length} documents');

      if (snapshot.docs.isEmpty) {
        print('No documents found in the news collection');
        return [];
      }

      print('\nProcessing documents...');
      final articles = snapshot.docs
          .where((doc) => doc.data() != null)
          .map((doc) {
            print('\nProcessing document ID: ${doc.id}');
            try {
              final data = doc.data()! as Map<String, dynamic>;
              print('Document data: $data');
              final article = NewsModel.fromMap(data, doc.id);
              print('Successfully converted to NewsModel: ${article.headline}');
              return article;
            } catch (e) {
              print('Error processing document ${doc.id}: $e');
              return null;
            }
          })
          .where((article) => article != null)
          .cast<NewsModel>()
          .toList();

      print(
          '\nFetch complete. Successfully processed ${articles.length} articles');
      return articles;
    } catch (e) {
      print('Error fetching news articles: $e');
      throw Exception('Failed to fetch news articles: ${e.toString()}');
    }
  }

  // Add a new article
  Future<void> addArticle(NewsModel article) async {
    try {
      print('Adding new article: ${article.headline}');
      await _firestore.collection('news').add(article.toMap());
      print('Article added successfully');
    } catch (e) {
      print('Error adding article: $e');
      throw Exception('Failed to add article: $e');
    }
  }

  // Update article likes
  Future<void> updateArticleLikes(String articleId, int likes) async {
    try {
      print('Updating likes for article $articleId to $likes');
      await _firestore.collection('news').doc(articleId).update({
        'likes': likes,
      });
      print('Likes updated successfully');
    } catch (e) {
      print('Error updating likes: $e');
      throw Exception('Failed to update article likes: $e');
    }
  }

  // Delete article
  Future<void> deleteArticle(String articleId) async {
    try {
      print('Deleting article: $articleId');
      await _firestore.collection('news').doc(articleId).delete();
      print('Article deleted successfully');
    } catch (e) {
      print('Error deleting article: $e');
      throw Exception('Failed to delete article: $e');
    }
  }

  // Get user's saved articles using email as document ID
  Future<List<NewsModel>> getSavedArticles() async {
    try {
      final userEmail = _auth.currentUser?.email;
      if (userEmail == null) {
        print('getSavedArticles: No user logged in');
        throw Exception('User not logged in');
      }

      print('getSavedArticles: Fetching saved articles for user: $userEmail');
      final userDoc = await _firestore.collection('user_data').doc(userEmail).get();
      
      if (!userDoc.exists) {
        print('getSavedArticles: No user document found');
        return [];
      }

      final savedNewsIds = List<String>.from(userDoc.data()?['saved'] ?? []);
      print('getSavedArticles: Found ${savedNewsIds.length} saved article IDs');
      
      if (savedNewsIds.isEmpty) {
        print('getSavedArticles: No saved articles found');
        return [];
      }

      // Process in batches of 10 to avoid potential limitations
      List<NewsModel> allArticles = [];
      for (var i = 0; i < savedNewsIds.length; i += 10) {
        final end = (i + 10 < savedNewsIds.length) ? i + 10 : savedNewsIds.length;
        final batch = savedNewsIds.sublist(i, end);
        
        print('getSavedArticles: Processing batch ${i ~/ 10 + 1} with ${batch.length} articles');
        final batchSnapshot = await _firestore
            .collection('news')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        final batchArticles = batchSnapshot.docs
            .map((doc) {
              try {
                return NewsModel.fromMap(doc.data(), doc.id);
              } catch (e) {
                print('getSavedArticles: Error processing article ${doc.id}: $e');
                return null;
              }
            })
            .where((article) => article != null)
            .cast<NewsModel>()
            .toList();

        allArticles.addAll(batchArticles);
      }

      print('getSavedArticles: Successfully fetched ${allArticles.length} articles');
      return allArticles;
    } catch (e) {
      print('getSavedArticles: Error: $e');
      throw Exception('Failed to get saved articles: $e');
    }
  }

  // Toggle save status for a news article
  Future<void> toggleSaveArticle(String articleId) async {
    try {
      final userEmail = _auth.currentUser?.email;
      if (userEmail == null) {
        print('toggleSaveArticle: No user logged in');
        throw Exception('User not logged in');
      }

      print('toggleSaveArticle: Processing for article $articleId and user $userEmail');
      final userDoc = _firestore.collection('user_data').doc(userEmail);
      final userData = await userDoc.get();

      if (!userData.exists) {
        print('toggleSaveArticle: Creating new user document');
        await userDoc.set({
          'email': userEmail,
          'saved': [],
          'liked': [],
        });
      }

      final savedArticles = List<String>.from(userData.data()?['saved'] ?? []);
      print('toggleSaveArticle: Current saved articles: $savedArticles');

      if (savedArticles.contains(articleId)) {
        print('toggleSaveArticle: Removing article from saved list');
        await userDoc.update({
          'saved': FieldValue.arrayRemove([articleId])
        });
        print('toggleSaveArticle: Article removed successfully');
      } else {
        print('toggleSaveArticle: Adding article to saved list');
        await userDoc.update({
          'saved': FieldValue.arrayUnion([articleId])
        });
        print('toggleSaveArticle: Article added successfully');
      }
    } catch (e) {
      print('toggleSaveArticle: Error: $e');
      throw Exception('Failed to toggle save article: $e');
    }
  }

  // Initialize or update user data in Firestore
  Future<void> initializeUserData(User user) async {
    try {
      if (user.email == null) throw Exception('User email is required');
      
      final userDoc = _firestore.collection('user_data').doc(user.email);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'email': user.email,
          'name': user.displayName ?? 'User',
          'liked': [],
          'saved': [],
        });
        print('User data initialized for ${user.email}');
      }
    } catch (e) {
      print('Error initializing user data: $e');
      throw Exception('Failed to initialize user data: $e');
    }
  }

  // Toggle like status for a news article
  Future<void> toggleLikeNews(String articleId) async {
    try {
      final userEmail = _auth.currentUser?.email;
      if (userEmail == null) throw Exception('User not logged in');

      final userDoc = _firestore.collection('user_data').doc(userEmail);
      final userData = await userDoc.get();

      if (!userData.exists) {
        await userDoc.set({
          'email': userEmail,
          'saved': [],
          'liked': [],
        });
      }

      List<String> likedNews = List<String>.from(userData.data()?['liked'] ?? []);

      if (likedNews.contains(articleId)) {
        await userDoc.update({
          'liked': FieldValue.arrayRemove([articleId])
        });
      } else {
        await userDoc.update({
          'liked': FieldValue.arrayUnion([articleId])
        });
      }
    } catch (e) {
      print('Error toggling like status: $e');
      throw Exception('Failed to toggle like status: $e');
    }
  }

  // Check if a news article is liked by the current user
  Future<bool> isNewsLiked(String articleId) async {
    try {
      final userEmail = _auth.currentUser?.email;
      if (userEmail == null) return false;

      final userDoc = await _firestore.collection('user_data').doc(userEmail).get();
      if (!userDoc.exists) return false;

      final likedNews = List<String>.from(userDoc.data()?['liked'] ?? []);
      return likedNews.contains(articleId);
    } catch (e) {
      print('Error checking like status: $e');
      return false;
    }
  }

  // Check if a news article is saved by the current user
  Future<bool> isNewsSaved(String articleId) async {
    try {
      final userEmail = _auth.currentUser?.email;
      if (userEmail == null) {
        print('isNewsSaved: No user logged in');
        return false;
      }

      print('isNewsSaved: Checking save status for article $articleId');
      final userDoc = await _firestore.collection('user_data').doc(userEmail).get();
      if (!userDoc.exists) {
        print('isNewsSaved: No user document found');
        return false;
      }

      final savedArticles = List<String>.from(userDoc.data()?['saved'] ?? []);
      final isSaved = savedArticles.contains(articleId);
      print('isNewsSaved: Article $articleId is${isSaved ? '' : ' not'} saved');
      return isSaved;
    } catch (e) {
      print('isNewsSaved: Error checking save status: $e');
      return false;
    }
  }

  // Get all liked news articles for the current user
  Future<List<NewsModel>> getLikedNews() async {
    try {
      final userEmail = _auth.currentUser?.email;
      if (userEmail == null) throw Exception('User not logged in');

      final userDoc = await _firestore.collection('user_data').doc(userEmail).get();
      if (!userDoc.exists) return [];

      final likedNewsIds = List<String>.from(userDoc.data()?['liked'] ?? []);
      if (likedNewsIds.isEmpty) return [];

      final querySnapshot = await _firestore
          .collection('news')
          .where(FieldPath.documentId, whereIn: likedNewsIds)
          .get();

      return querySnapshot.docs
          .map((doc) => NewsModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching liked news: $e');
      throw Exception('Failed to fetch liked news: $e');
    }
  }

  // Stream user data for real-time updates using email as document ID
  Stream<DocumentSnapshot> getUserDataStream() {
    final userEmail = _auth.currentUser?.email;
    if (userEmail == null) throw Exception('User not logged in');

    return _firestore.collection('user_data').doc(userEmail).snapshots();
  }

  // Stream of saved articles with real-time updates
  Stream<List<NewsModel>> getSavedArticlesStream() {
    final userEmail = _auth.currentUser?.email;
    if (userEmail == null) {
      print('getSavedArticlesStream: No user logged in');
      return Stream.value([]);
    }

    return _firestore
        .collection('user_data')
        .doc(userEmail)
        .snapshots()
        .asyncMap((snapshot) async {
      try {
        if (!snapshot.exists) {
          print('getSavedArticlesStream: No user document found');
          return [];
        }

        final savedNewsIds = List<String>.from(snapshot.get('saved') ?? []);
        print('getSavedArticlesStream: Found ${savedNewsIds.length} saved article IDs');

        if (savedNewsIds.isEmpty) {
          print('getSavedArticlesStream: No saved articles found');
          return [];
        }

        // Process in batches of 10
        List<NewsModel> allArticles = [];
        for (var i = 0; i < savedNewsIds.length; i += 10) {
          final end = (i + 10 < savedNewsIds.length) ? i + 10 : savedNewsIds.length;
          final batch = savedNewsIds.sublist(i, end);
          
          print('getSavedArticlesStream: Processing batch ${i ~/ 10 + 1}');
          final batchSnapshot = await _firestore
              .collection('news')
              .where(FieldPath.documentId, whereIn: batch)
              .get();

          final batchArticles = batchSnapshot.docs
              .map((doc) => NewsModel.fromMap(doc.data(), doc.id))
              .toList();

          allArticles.addAll(batchArticles);
        }

        print('getSavedArticlesStream: Returning ${allArticles.length} articles');
        return allArticles;
      } catch (e) {
        print('getSavedArticlesStream: Error: $e');
        return [];
      }
    });
  }
}
