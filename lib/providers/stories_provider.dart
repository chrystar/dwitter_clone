import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../models/status_model.dart';

class StoryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, List<Story>> _userStories = {};
  bool _initialized = false;

  Map<String, List<Story>> get userStories => _userStories;

  Future<void> initialize() async {
    if (_initialized) return;
    await fetchStories();
    _initialized = true;
  }

  Stream<QuerySnapshot> getStories() {
    return _firestore
        .collection('stories')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> fetchStories() async {
    final storiesSnapshot = await _firestore
        .collection('stories')
        .where('createdAt',
            isGreaterThan: DateTime.now().subtract(Duration(hours: 24)))
        .orderBy('createdAt', descending: true)
        .get();

    _userStories.clear();
    for (final doc in storiesSnapshot.docs) {
      final data = doc.data();
      final story = Story.fromJson(data);

      if (!_userStories.containsKey(story.userId)) {
        _userStories[story.userId] = [];
      }
      _userStories[story.userId]!.add(story);
    }

    notifyListeners();
  }

  Future<void> fetchStoriesForUser(String userId) async {
    final storiesSnapshot = await _firestore
        .collection('stories')
        .where('userId', isEqualTo: userId)
        .where('createdAt',
            isGreaterThan: DateTime.now().subtract(Duration(hours: 24)))
        .orderBy('createdAt', descending: true)
        .get();

    _userStories[userId] =
        storiesSnapshot.docs.map((doc) => Story.fromJson(doc.data())).toList();

    notifyListeners();
  }

  Future<void> fetchStoriesForFollowedUsers() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Get the list of users that the current user follows
      final followingSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('following')
          .get();

      final followedUserIds =
          followingSnapshot.docs.map((doc) => doc.id).toList();

      // Add current user's ID to fetch their own stories too
      followedUserIds.add(user.uid);

      // Fetch stories for all followed users
      final storiesSnapshot = await _firestore
          .collection('stories')
          .where('userId',
              whereIn: followedUserIds.isEmpty ? [user.uid] : followedUserIds)
          .where('createdAt',
              isGreaterThan: DateTime.now().subtract(Duration(hours: 24)))
          .orderBy('createdAt', descending: true)
          .get();

      _userStories.clear();
      for (final doc in storiesSnapshot.docs) {
        final data = doc.data();
        final story = Story.fromJson(data);

        if (!_userStories.containsKey(story.userId)) {
          _userStories[story.userId] = [];
        }
        _userStories[story.userId]!.add(story);
      }

      notifyListeners();
    } catch (e) {
      print('Error fetching stories for followed users: $e');
    }
  }

  bool canCreateStory() {
    return _auth.currentUser != null;
  }

  Future<void> uploadStory(
      String imagePath, String? caption, BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('stories')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(File(imagePath));
      final imageUrl = await storageRef.getDownloadURL();

      // Create story in Firestore
      final story = Story(
        userId: user.uid,
        imageUrl: imageUrl,
        textContent: caption ?? '',
        createdAt: DateTime.now(),
        mediaType: 'image',
      );

      await _firestore.collection('stories').add(story.toJson());
      await fetchStories(); // Refresh stories
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading story: $e')),
      );
    }
  }

  Future<void> uploadTextStory(String text, BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final storiesRef = FirebaseFirestore.instance.collection('stories');

      await storiesRef.add({
        'userId': user.uid,
        'content': text,
        'type': 'text',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Refresh stories after upload
      await fetchStoriesForFollowedUsers();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to upload text story: $e');
    }
  }

  Future<void> deleteStory(String storyId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('stories').doc(storyId).delete();
    await fetchStories(); // Refresh stories
  }

  Future<void> deleteExpiredStories() async {
    try {
      final now = DateTime.now();
      final storiesRef = FirebaseFirestore.instance.collection('stories');

      // Get all stories that are older than 24 hours
      final snapshot = await storiesRef
          .where('createdAt', isLessThan: now.subtract(Duration(hours: 24)))
          .get();

      // Delete expired stories
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Update local state
      await fetchStoriesForFollowedUsers();
      notifyListeners();
    } catch (e) {
      print('Error deleting expired stories: $e');
    }
  }
}
