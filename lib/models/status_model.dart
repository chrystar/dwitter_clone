import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String userId;
  final String imageUrl;
  final String videoUrl;
  final DateTime createdAt;
  final String mediaType; // 'image' or 'video'

  Story({
    required this.userId,
    required this.imageUrl,
    required this.videoUrl,
    required this.createdAt,
    required this.mediaType,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      userId: json['userId'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      mediaType: json['mediaType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'mediaType': mediaType,
    };
  }
}