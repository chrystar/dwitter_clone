import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String uid;
  final String postId;
  final String content;
  final DateTime timestamp;
  final List<String> likes;
  final String? imageUrl;
  final String? commentId;

  CommentModel({
    required this.uid,
    required this.postId,
    required this.content,
    required this.timestamp,
    this.likes = const [],
    this.imageUrl,
    this.commentId,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      uid: map['uid'] ?? '',
      postId: map['postId'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      likes: List<String>.from(map['likes'] ?? []),
      imageUrl: map['imageUrl'],
      commentId: map['commentId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'postId': postId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'imageUrl': imageUrl,
      'commentId': commentId,
    };
  }

  CommentModel copyWith({
    String? uid,
    String? postId,
    String? content,
    DateTime? timestamp,
    List<String>? likes,
    String? imageUrl,
    String? commentId,
  }) {
    return CommentModel(
      uid: uid ?? this.uid,
      postId: postId ?? this.postId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      imageUrl: imageUrl ?? this.imageUrl,
      commentId: commentId ?? this.commentId,
    );
  }
}
