import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dwitter_clone/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../../providers/auth_provider.dart'; // Assuming your AuthProviders is here

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profileImageUrl = 'URL_TO_PROFILE_PICTURE'; // Replace with actual fetched URL
  String _currentName = 'c3dchris'; // Replace with actual fetched name

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        setState(() {
          _currentName = userData.data()?['name'] ?? 'c3dchris';
          _profileImageUrl = userData.data()?['profileImage'];
        });
      }
    } else {
      // Handle case where user is not logged in (e.g., navigate to login)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      // Optionally navigate to login screen
      // Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _updateProfileImage() async {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    final user = authProvider.user ?? FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      final userId = user.uid;

      try {
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child(userId)
            .child('${userId}_profile.jpg');

        await ref.putFile(imageFile);
        String downloadURL = await ref.getDownloadURL();

        await authProvider.setUserProfile(null, downloadURL); // Update only profileImage
        setState(() {
          _profileImageUrl = downloadURL;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully!')),
        );
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile image.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XDarkThemeColors.secondaryBackground,
      appBar: AppBar(
        backgroundColor: XDarkThemeColors.secondaryBackground,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: XDarkThemeColors.iconColor,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        actions: const [
          IconButton(
            icon: Icon(
              Icons.search,
              color: XDarkThemeColors.iconColor,
            ),
            onPressed: null, // Add search functionality
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: XDarkThemeColors.iconColor,
            ),
            onPressed: null, // Add more options
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image (Placeholder)
            Stack(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  color: XDarkThemeColors
                      .primaryAccent, // Replace with actual image
                ),
                Padding(
                  padding: EdgeInsets.only(top: 110, left: 10),
                  child: GestureDetector(
                    onTap: _updateProfileImage,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                      child: _profileImageUrl == null
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: XDarkThemeColors.primaryText,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Row(
                            children: [
                              Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Get Verified',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '@christian039571',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: () {
                          // Implement edit profile functionality
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Edit profile',
                          style: TextStyle(
                            color: XDarkThemeColors.primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Building cool apps with flutter',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.cake, color: Colors.grey, size: 16),
                      SizedBox(width: 4),
                      Text('Born 15 January 2003',
                          style: TextStyle(color: Colors.grey)),
                      SizedBox(width: 16),
                      Icon(Icons.calendar_today_outlined,
                          color: Colors.grey, size: 16),
                      SizedBox(width: 4),
                      Text('Joined November 2024',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Text('51',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(width: 4),
                      Text('Following', style: TextStyle(color: Colors.grey)),
                      SizedBox(width: 16),
                      Text('9',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(width: 4),
                      Text('Followers', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  DefaultTabController(
                    length: 5,
                    child: Column(
                      children: [
                        const TabBar(
                          isScrollable: true,
                          labelColor: XDarkThemeColors.primaryText,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.blue,
                          tabs: [
                            Tab(text: 'Posts'),
                            Tab(text: 'Replies'),
                            Tab(text: 'Highlights'),
                            Tab(text: 'Articles'),
                            Tab(text: 'More'),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height -
                              AppBar().preferredSize.height -
                              150 -
                              MediaQuery.of(context).padding.top -
                              MediaQuery.of(context).padding.bottom -
                              350,
                          child: const TabBarView(
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              Center(child: Text('Posts Content')),
                              Center(child: Text('Replies Content')),
                              Center(child: Text('Highlights Content')),
                              Center(child: Text('Articles Content')),
                              Center(child: Text('More Content')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement compose tweet/post functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}