import 'package:dwitter_clone/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProviders extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _fireSore = FirebaseFirestore.instance;
  User? _user;

  User? get user => _user;

  Future<void> getCurrentUser() async {
    await _auth.currentUser;
  }

  Future<UserModel?> registerUser(
    String email,
    String password,
    UserModel userModel,
    BuildContext context,
  ) async {
    final UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    if (user != null) {
      final UserModel updatedUserModel = UserModel(
        uid: user.uid,
        // Add the user id.
        email: userModel.email,
        name: userModel.name,
        profileImage: userModel.profileImage,
        createdAt: userModel.createdAt,
      );

      await _fireSore
          .collection('users')
          .doc(user.uid)
          .set(updatedUserModel.toMap());
      notifyListeners();
      return updatedUserModel;
    } else {
      return null;
    }
  }

  Future<void> signOut()async{
    await _auth.signOut();
  }

  Future<void> setUserProfile(String? name, String? profileImage) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userDocRef = _fireSore.collection('users').doc(currentUser.uid);
      final Map<String, dynamic> updateData = {};

      if (name != null) {
        updateData['name'] = name;
      }
      if (profileImage != null) {
        updateData['profileImage'] = profileImage;
      }

      try {
        await userDocRef.update(updateData);
        notifyListeners();
      } catch (e) {
        print("Error updating user profile: $e");
        // Handle the error appropriately (e.g., show a snackbar)
      }
    }
  }


}
