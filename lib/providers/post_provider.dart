import 'package:dwitter_clone/models/post_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _fireStore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;


class PostProvider extends ChangeNotifier {


  Future<void> createPost(String content) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final uid = currentUser.uid;
      await _fireStore.collection('posts').add(
            PostModel(
              uid: uid,
              content: content,
              timestamp: DateTime.now(),
            ).toMap(),
          );
    }
  }


  Future<String?> getCurrentUserName() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userDoc =
      await _fireStore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        return userData?['username'] as String?; // Assuming 'username' field
      }
    }
    return null;
  }
}
