import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/community_model.dart';

class CommunityProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getCommunityPosts(String communityId) {
    return _firestore
        .collection('communities')
        .doc(communityId)
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<List<CommunityModel>> getUserCommunities() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('communities')
        .where('members', arrayContains: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommunityModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<List<CommunityModel>> getAllCommunities() {
    return _firestore.collection('communities').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => CommunityModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<List<CommunityModel>> searchCommunities(String query) async {
    final snapshot = await _firestore
        .collection('communities')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .get();

    return snapshot.docs
        .map((doc) =>
            CommunityModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> createCommunity({
    required String name,
    required String description,
    required String category,
    String? bannerImage,
    String? avatarImage,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final communityData = CommunityModel(
      id: '', // Will be set by Firestore
      name: name,
      description: description,
      category: category,
      creatorUid: user.uid,
      createdAt: DateTime.now(),
      bannerImage: bannerImage,
      avatarImage: avatarImage,
      members: [user.uid],
      moderators: [user.uid],
    ).toMap();

    await _firestore.collection('communities').add(communityData);
    notifyListeners();
  }

  Future<void> joinCommunity(String communityId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('communities').doc(communityId).update({
      'members': FieldValue.arrayUnion([user.uid])
    });
    notifyListeners();
  }

  Future<void> leaveCommunity(String communityId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('communities').doc(communityId).update({
      'members': FieldValue.arrayRemove([user.uid])
    });
    notifyListeners();
  }

  Stream<List<CommunityModel>> getCategoryCommunities(String category) {
    return _firestore
        .collection('communities')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommunityModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }
}
