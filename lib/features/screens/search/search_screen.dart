import 'package:dwitter_clone/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dwitter_clone/features/screens/profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Stream<QuerySnapshot>? _searchResultsStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResultsStream = null;
      });
      return;
    }

    setState(() {
      _searchResultsStream = _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .limit(10)
          .snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XDarkThemeColors.secondaryBackground,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _searchResultsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final userData = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: userData['profilePic'] != null
                            ? NetworkImage(userData['profilePic'])
                            : null,
                        child: userData['profilePic'] == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(userData['name'] ?? ''),
                      subtitle: Text(userData['username'] ?? ''),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              userId: snapshot.data!.docs[index].id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
