import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dwitter_clone/models/community_model.dart';
import 'package:dwitter_clone/providers/community_provider.dart';
import 'package:dwitter_clone/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommunityDetailScreen extends StatelessWidget {
  final CommunityModel community;

  const CommunityDetailScreen({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: XDarkThemeColors.primaryBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: XDarkThemeColors.primaryBackground,
            flexibleSpace: FlexibleSpaceBar(
              background: community.bannerImage != null
                  ? Image.network(
                      community.bannerImage!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: XDarkThemeColors.secondaryBackground,
                      child: Center(
                        child: Icon(
                          Icons.group,
                          size: 50,
                          color: XDarkThemeColors.mutedIconColor,
                        ),
                      ),
                    ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: XDarkThemeColors.iconColor),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.more_vert, color: XDarkThemeColors.iconColor),
                onPressed: () {
                  // TODO: Show community settings/menu
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: community.avatarImage != null
                            ? NetworkImage(community.avatarImage!)
                            : null,
                        child: community.avatarImage == null
                            ? Text(
                                community.name[0].toUpperCase(),
                                style: TextStyle(
                                  color: XDarkThemeColors.primaryText,
                                  fontSize: 24,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              community.name,
                              style: TextStyle(
                                color: XDarkThemeColors.primaryText,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Category: ${community.category}',
                              style: TextStyle(
                                color: XDarkThemeColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (!community.members.contains(currentUser?.uid))
                              ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<CommunityProvider>()
                                      .joinCommunity(community.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      XDarkThemeColors.primaryAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text('Join Community'),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    community.description,
                    style: TextStyle(
                      color: XDarkThemeColors.primaryText,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: XDarkThemeColors.divider),
                StreamBuilder<QuerySnapshot>(
                  stream: context
                      .read<CommunityProvider>()
                      .getCommunityPosts(community.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading posts: ${snapshot.error}',
                          style: TextStyle(color: XDarkThemeColors.primaryText),
                        ),
                      );
                    }

                    final posts = snapshot.data?.docs ?? [];
                    if (posts.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No posts yet. Be the first to post!',
                            style: TextStyle(
                                color: XDarkThemeColors.secondaryText),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post =
                            posts[index].data() as Map<String, dynamic>;
                        return _buildPostCard(context, post);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: community.members.contains(currentUser?.uid)
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Navigate to create post screen
              },
              backgroundColor: XDarkThemeColors.primaryAccent,
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildPostCard(BuildContext context, Map<String, dynamic> post) {
    return Card(
      color: XDarkThemeColors.secondaryBackground,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: XDarkThemeColors.mutedIconColor,
                  child: Text(
                    post['authorName']?[0].toUpperCase() ?? '?',
                    style: TextStyle(color: XDarkThemeColors.primaryText),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  post['authorName'] ?? 'Unknown',
                  style: TextStyle(
                    color: XDarkThemeColors.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post['content'] ?? '',
              style: TextStyle(color: XDarkThemeColors.primaryText),
            ),
            if (post['imageUrl'] != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post['imageUrl'],
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
