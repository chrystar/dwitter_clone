import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserModel {
  String? uid;
  String email;
  String name;
  String? profileImage;
  List<String> followers;
  List<String> following;
  final DateTime createdAt;

  UserModel({
     this.uid,
    required this.email,
    required this.name,
    required this.profileImage,
    this.followers = const [],
    this.following = const [],
    required this.createdAt,

  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      profileImage: map['profileImage'],
      followers: map['followers'],
      following: map['following'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profileImage': profileImage,
      'followers': followers,
      'following': following,
      'createdAt': createdAt,
    };
  }
}
