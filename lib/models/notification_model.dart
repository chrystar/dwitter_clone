import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String receiverUid;
  String senderUid;
  String type; // "like", "comment", "follow", "message", etc.
  String? postId; // ID of the post (if applicable)
  String? commentId; // ID of the comment (if applicable)
  String? messageId; // Id of the message (if applicable)
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.receiverUid,
    required this.senderUid,
    required this.type,
    this.postId,
    this.commentId,
    this.messageId,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      receiverUid: map['receiverUid'],
      senderUid: map['senderUid'],
      type: map['type'],
      postId: map['postId'],
      commentId: map['commentId'],
      messageId: map['messageId'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'receiverUid': receiverUid,
      'senderUid': senderUid,
      'type': type,
      'postId': postId,
      'commentId': commentId,
      'messageId': messageId,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}