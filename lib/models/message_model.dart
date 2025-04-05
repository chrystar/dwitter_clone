import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String senderUid;
  String receiverUid;
  String content;
  final DateTime timestamp;

  MessageModel({
    required this.senderUid,
    required this.receiverUid,
    required this.content,
    required this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderUid: map['senderUid'],
      receiverUid: map['receiverUid'],
      content: map['content'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
