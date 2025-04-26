import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViewedStoriesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, Set<String>> _viewedStories = {};

  bool hasUnviewedStories(String userId, List<String> storyIds) {
    if (_viewedStories.containsKey(userId)) {
      return storyIds.any((id) => !_viewedStories[userId]!.contains(id));
    }
    return storyIds.isNotEmpty;
  }

  Future<void> markStoryAsViewed(String userId, String storyId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    if (!_viewedStories.containsKey(userId)) {
      _viewedStories[userId] = {};
    }
    _viewedStories[userId]!.add(storyId);

    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('viewedStories')
        .doc(userId)
        .set({
      'storyIds': _viewedStories[userId]!.toList(),
      'lastViewed': DateTime.now(),
    });

    notifyListeners();
  }

  Future<void> loadViewedStories() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final viewedStoriesSnapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('viewedStories')
        .get();

    _viewedStories.clear();
    for (final doc in viewedStoriesSnapshot.docs) {
      final userId = doc.id;
      final data = doc.data();
      _viewedStories[userId] = Set.from(data['storyIds'] as List<dynamic>);
    }

    notifyListeners();
  }
}
