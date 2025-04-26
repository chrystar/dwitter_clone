import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dwitter_clone/features/screens/profile/widgets/post_list.dart';
import 'package:dwitter_clone/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:dwitter_clone/providers/follow_provider.dart';
import '../../../providers/auth_provider.dart'; // Assuming your AuthProviders is here

class ProfileScreen extends StatefulWidget {
  final String? userId; // Add userId parameter

  const ProfileScreen({super.key, this.userId}); // Make userId optional

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profileImageUrl;
  String? _currentName;
  String? _username;
  String? _bio;
  DateTime? _joinDate;
  int _followingCount = 0;
  int _followersCount = 0;
  late Future<bool> _isFollowingFuture;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _userId = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (_userId != null && widget.userId != null) {
      _isFollowingFuture = context.read<FollowProvider>().isFollowing(_userId!);
    }
  }

  Future<void> _loadUserProfile() async {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    final user = authProvider.user;
    final targetUserId = widget.userId ?? user?.uid;

    if (targetUserId != null) {
      try {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(targetUserId)
            .get();

        if (userData.exists) {
          setState(() {
            _currentName = userData.data()?['name'] ?? 'No name set';
            _profileImageUrl = userData.data()?['profileImage'];
            _username = userData.data()?['username'] ??
                '@user${targetUserId.substring(0, 8)}';
            _bio = userData.data()?['bio'] ?? 'No bio yet';
            _followingCount = userData.data()?['followingCount'] ?? 0;
            _followersCount = userData.data()?['followersCount'] ?? 0;
            _joinDate =
                userData.data()?['joinDate']?.toDate() ?? DateTime.now();
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to view profile')),
      );
      // Navigate to login screen
      Navigator.pushReplacementNamed(context, '/login');
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
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${userId}_profile.jpg');

        await ref.putFile(imageFile);
        String downloadURL = await ref.getDownloadURL();

        await authProvider.setUserProfile(
            null, downloadURL); // Update only profileImage
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

  Future<void> _showEditProfileDialog() async {
    final TextEditingController nameController =
        TextEditingController(text: _currentName);
    final TextEditingController bioController =
        TextEditingController(text: _bio);
    final TextEditingController usernameController =
        TextEditingController(text: _username);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: XDarkThemeColors.secondaryBackground,
        title: Text('Edit Profile',
            style: TextStyle(color: XDarkThemeColors.primaryText)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: XDarkThemeColors.primaryText),
                ),
                style: TextStyle(color: XDarkThemeColors.primaryText),
              ),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: XDarkThemeColors.primaryText),
                ),
                style: TextStyle(color: XDarkThemeColors.primaryText),
              ),
              TextField(
                controller: bioController,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  labelStyle: TextStyle(color: XDarkThemeColors.primaryText),
                ),
                style: TextStyle(color: XDarkThemeColors.primaryText),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: XDarkThemeColors.primaryText)),
          ),
          TextButton(
            onPressed: () async {
              final authProvider =
                  Provider.of<AuthProviders>(context, listen: false);
              final user = authProvider.user;
              if (user != null) {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .update({
                    'name': nameController.text,
                    'username': usernameController.text,
                    'bio': bioController.text,
                  });

                  setState(() {
                    _currentName = nameController.text;
                    _username = usernameController.text;
                    _bio = bioController.text;
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Profile updated successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Error updating profile: ${e.toString()}')),
                  );
                }
              }
            },
            child: Text('Save',
                style: TextStyle(color: XDarkThemeColors.primaryAccent)),
          ),
        ],
      ),
    );
  }

  // Update the build method's UI elements to use dynamic data
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isCurrentUserProfile =
        widget.userId == null || widget.userId == currentUser?.uid;
    final followProvider = Provider.of<FollowProvider>(context);

    return Scaffold(
      backgroundColor: XDarkThemeColors.secondaryBackground,
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
                            _currentName ?? 'Loading...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: XDarkThemeColors.primaryText,
                            ),
                          ),
                          Text(
                            _username ?? '@username',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      if (isCurrentUserProfile)
                        OutlinedButton(
                          onPressed: _showEditProfileDialog,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Edit profile',
                            style: TextStyle(
                              color: XDarkThemeColors.primaryText,
                            ),
                          ),
                        )
                      else if (_userId != null)
                        FutureBuilder<bool>(
                          future: _isFollowingFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(),
                              );
                            }

                            final isFollowing = snapshot.data ?? false;

                            return ElevatedButton(
                              onPressed: () async {
                                await followProvider.toggleFollow(_userId!);
                                setState(() {
                                  _isFollowingFuture =
                                      followProvider.isFollowing(_userId!);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFollowing
                                    ? XDarkThemeColors.secondaryBackground
                                    : XDarkThemeColors.primaryAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: isFollowing
                                      ? const BorderSide(
                                          color: XDarkThemeColors.primaryAccent)
                                      : BorderSide.none,
                                ),
                              ),
                              child: Text(
                                isFollowing ? 'Following' : 'Follow',
                                style: TextStyle(
                                  color: isFollowing
                                      ? XDarkThemeColors.primaryAccent
                                      : XDarkThemeColors.primaryText,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _bio ?? 'No bio yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: XDarkThemeColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Joined ${_joinDate?.month ?? 'Unknown'} ${_joinDate?.year ?? ''}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        '$_followingCount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: XDarkThemeColors.primaryText,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('Following',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 16),
                      Text(
                        '$_followersCount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: XDarkThemeColors.primaryText,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('Followers',
                          style: TextStyle(color: Colors.grey)),
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
                          child: TabBarView(
                            children: [
                              const PostList(), // Assuming you have a PostList widget
                              const Center(
                                child: Text('Replies coming soon',
                                    style: TextStyle(color: Colors.grey)),
                              ),
                              const Center(
                                child: Text('Highlights coming soon',
                                    style: TextStyle(color: Colors.grey)),
                              ),
                              const Center(
                                child: Text('Articles coming soon',
                                    style: TextStyle(color: Colors.grey)),
                              ),
                              const Center(
                                child: Text('More features coming soon',
                                    style: TextStyle(color: Colors.grey)),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement compose tweet/post functionality
        },
        backgroundColor: XDarkThemeColors.primaryAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
