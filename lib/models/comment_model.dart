import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  String uid;
  String postId; // ID of the post the comment is on
  String content;
  final DateTime timestamp;

  CommentModel({
    required this.uid,
    required this.postId,
    required this.content,
    required this.timestamp,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      uid: map['uid'],
      postId: map['postId'],
      content: map['content'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'postId': postId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}