import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String uid;
  String content;
  String? imageUrl;
  // String? videoUrl;
  final DateTime timestamp;
  List<String> likes;
  List<String> comments; // List of comment IDs

  PostModel({
    required this.uid,
    required this.content,
    this.imageUrl,
    // this.videoUrl,
    required this.timestamp,
    this.likes = const [],
    this.comments = const [],
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      uid: map['uid'],
      content: map['content'],
      imageUrl: map['imageUrl'],
      // videoUrl: map['videoUrl'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      likes: List<String>.from(map['likes'] ?? []),
      comments: List<String>.from(map['comments'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'content': content,
      'imageUrl': imageUrl,
      // 'videoUrl': videoUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'comments': comments,
    };
  }
}