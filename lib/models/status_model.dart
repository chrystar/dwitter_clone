import 'package:cloud_firestore/cloud_firestore.dart';

class StatusModel {
  String uid;
  String content;
  String? imageUrl;

  // String? videoUrl;
  final DateTime timestamp;

  StatusModel(
    this.uid,
    this.content,
    this.imageUrl,
    this.timestamp,
  );

// ... (fromMap, toMap, constructor)
}
