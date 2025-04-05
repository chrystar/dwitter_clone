import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../models/status_model.dart';

class StoryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> _followingUserIds = []; // Implement logic to fetch following list
  Map<String, List<Story>> _userStories = {};

  Map<String, List<Story>> get userStories => _userStories;

  Future<void> fetchStories() async {
    _userStories.clear();
    final now = DateTime.now();
    final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));

    // For now, fetch all stories within the last 24 hours
    final snapshot = await _firestore
        .collection('stories')
        .where('createdAt', isGreaterThan: twentyFourHoursAgo)
        .orderBy('createdAt')
        .get();

    for (final doc in snapshot.docs) {
      final story = Story.fromJson(doc.data());
      if (_userStories.containsKey(story.userId)) {
        _userStories[story.userId]!.add(story);
      } else {
        _userStories[story.userId] = [story];
      }
    }
    notifyListeners();
  }

  Future<void> uploadStory(String? imagePath, String? videoPath, BuildContext context) async {
    if (_auth.currentUser == null) return;
    final userId = _auth.currentUser!.uid;
    final now = DateTime.now();
    String? mediaUrl;
    String mediaType;

    if (imagePath != null) {
      mediaType = 'image';
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('stories')
            .child(userId)
            .child('${now.millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(File(imagePath));
        mediaUrl = await storageRef.getDownloadURL();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
        return;
      }
    } else if (videoPath != null) {
      mediaType = 'video';
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('stories')
            .child(userId)
            .child('${now.millisecondsSinceEpoch}.mp4');
        await storageRef.putFile(File(videoPath));
        mediaUrl = await storageRef.getDownloadURL();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading video: $e')));
        return;
      }
    } else {
      return; // No media selected
    }

    final newStory = Story(
      userId: userId,
      imageUrl: mediaUrl ?? '',
      videoUrl: mediaUrl ?? '',
      createdAt: now,
      mediaType: mediaType,
    );

    try {
      await _firestore.collection('stories').add(newStory.toJson());
      fetchStories(); // Refresh stories
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving story data: $e')));
    }
  }
}