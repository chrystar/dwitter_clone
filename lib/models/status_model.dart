import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String userId;
  final String imageUrl;
  final String videoUrl;
  final String textContent;
  final DateTime createdAt;
  final String mediaType; // 'image', 'video', or 'text'

  Story({
    required this.userId,
    this.imageUrl = '',
    this.videoUrl = '',
    this.textContent = '',
    required this.createdAt,
    required this.mediaType,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'textContent': textContent,
      'createdAt': Timestamp.fromDate(createdAt),
      'mediaType': mediaType,
    };
  }

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      videoUrl: json['videoUrl'] as String? ?? '',
      textContent: json['textContent'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      mediaType: json['mediaType'] as String,
    );
  }
}
