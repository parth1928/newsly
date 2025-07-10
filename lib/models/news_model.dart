import 'package:cloud_firestore/cloud_firestore.dart';

class NewsModel {
  final String headline;
  final String content;
  final String imageUrl;
  final String category;
  final DateTime timestamp;
  final String author;
  final int likes;
  final String id;
  final String subtitle;

  NewsModel({
    required this.headline,
    required this.content,
    required this.imageUrl,
    required this.category,
    required this.timestamp,
    required this.author,
    required this.likes,
    required this.id,
    required this.subtitle,
  });

  factory NewsModel.fromMap(Map<String, dynamic> map, String id) {
    try {
      final timestampData = map['timestamp'] ?? map['Time'];
      if (timestampData == null) {
        throw Exception('Timestamp field not found in map');
      }
      
      final timestamp = timestampData is Timestamp 
          ? timestampData.toDate()
          : (timestampData is DateTime ? timestampData : DateTime.now());

      return NewsModel(
        id: id,
        headline: map['headline'] ?? '',
        content: map['content'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        category: map['category'] ?? '',
        timestamp: timestamp,
        author: map['author'] ?? '',
        likes: (map['likes'] as num?)?.toInt() ?? 0,
        subtitle: map['subtitle'] ?? '',
      );
    } catch (e) {
      print('Error creating NewsModel from map: $e');
      print('Map data: $map');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'headline': headline,
      'content': content,
      'imageUrl': imageUrl,
      'category': category,
      'timestamp': Timestamp.fromDate(timestamp),
      'author': author,
      'likes': likes,
      'subtitle': subtitle,
    };
  }

  @override
  String toString() {
    return 'NewsModel(id: $id, headline: $headline, category: $category, author: $author, likes: $likes)';
  }
}
