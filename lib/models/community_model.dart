import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String creatorUid;
  final DateTime createdAt;
  final String? bannerImage;
  final String? avatarImage;
  final List<String> members;
  final List<String> moderators;

  CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.creatorUid,
    required this.createdAt,
    this.bannerImage,
    this.avatarImage,
    this.members = const [],
    this.moderators = const [],
  });

  factory CommunityModel.fromMap(Map<String, dynamic> map, String id) {
    return CommunityModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      creatorUid: map['creatorUid'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      bannerImage: map['bannerImage'],
      avatarImage: map['avatarImage'],
      members: List<String>.from(map['members'] ?? []),
      moderators: List<String>.from(map['moderators'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'creatorUid': creatorUid,
      'createdAt': Timestamp.fromDate(createdAt),
      'bannerImage': bannerImage,
      'avatarImage': avatarImage,
      'members': members,
      'moderators': moderators,
    };
  }
}
