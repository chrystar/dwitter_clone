import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String senderUid;
  String receiverUid;
  String content;
  final DateTime timestamp;
  final String conversationId;
  final bool isRead;
  final String messageType; // 'text', 'image', etc.

  MessageModel({
    required this.senderUid,
    required this.receiverUid,
    required this.content,
    required this.timestamp,
    required this.conversationId,
    this.isRead = false,
    this.messageType = 'text',
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderUid: map['senderUid'],
      receiverUid: map['receiverUid'],
      content: map['content'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      conversationId: map['conversationId'],
      isRead: map['isRead'] ?? false,
      messageType: map['messageType'] ?? 'text',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'conversationId': conversationId,
      'isRead': isRead,
      'messageType': messageType,
    };
  }
}
