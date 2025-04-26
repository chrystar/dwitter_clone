import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FollowProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<bool> isFollowing(String targetUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final doc = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('following')
        .doc(targetUserId)
        .get();

    return doc.exists;
  }

  Future<void> toggleFollow(String targetUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final isCurrentlyFollowing = await isFollowing(targetUserId);
    final batch = _firestore.batch();

    final currentUserFollowingRef = _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('following')
        .doc(targetUserId);

    final targetUserFollowersRef = _firestore
        .collection('users')
        .doc(targetUserId)
        .collection('followers')
        .doc(currentUser.uid);

    final currentUserDoc = _firestore.collection('users').doc(currentUser.uid);
    final targetUserDoc = _firestore.collection('users').doc(targetUserId);

    if (isCurrentlyFollowing) {
      // Unfollow
      batch.delete(currentUserFollowingRef);
      batch.delete(targetUserFollowersRef);
      batch
          .update(currentUserDoc, {'followingCount': FieldValue.increment(-1)});
      batch.update(targetUserDoc, {'followersCount': FieldValue.increment(-1)});
    } else {
      // Follow
      final timestamp = DateTime.now();
      batch.set(currentUserFollowingRef, {'timestamp': timestamp});
      batch.set(targetUserFollowersRef, {'timestamp': timestamp});
      batch.update(currentUserDoc, {'followingCount': FieldValue.increment(1)});
      batch.update(targetUserDoc, {'followersCount': FieldValue.increment(1)});
    }

    await batch.commit();
    notifyListeners();
  }
}
