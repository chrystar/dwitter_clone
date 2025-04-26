import 'package:dwitter_clone/models/community_model.dart';
import 'package:dwitter_clone/providers/community_provider.dart';
import 'package:dwitter_clone/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'create_community_screen.dart';
import 'community_detail_screen.dart';

class Communities extends StatefulWidget {
  const Communities({super.key});

  @override
  State<Communities> createState() => _CommunitiesState();
}

class _CommunitiesState extends State<Communities>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<String> categories = [
    'All',
    'Technology',
    'Gaming',
    'Sports',
    'Entertainment',
    'Education',
    'Art',
    'Music',
    'Food',
    'Travel',
    'Other'
  ];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XDarkThemeColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: XDarkThemeColors.primaryBackground,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: TextStyle(color: XDarkThemeColors.primaryText),
                decoration: InputDecoration(
                  hintText: 'Search communities...',
                  hintStyle: TextStyle(color: XDarkThemeColors.secondaryText),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  // Trigger search
                  context.read<CommunityProvider>().searchCommunities(value);
                },
              )
            : Text('Communities',
                style: TextStyle(color: XDarkThemeColors.primaryText)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search,
                color: XDarkThemeColors.iconColor),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.add, color: XDarkThemeColors.iconColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateCommunityScreen(),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(96),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: XDarkThemeColors.primaryAccent,
                labelColor: XDarkThemeColors.primaryText,
                unselectedLabelColor: XDarkThemeColors.secondaryText,
                tabs: [
                  Tab(text: 'Home'),
                  Tab(text: 'Explore'),
                ],
              ),
              Container(
                height: 48,
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(categories[index]),
                        selected: _selectedCategory == categories[index],
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = categories[index];
                          });
                        },
                        selectedColor: XDarkThemeColors.primaryAccent,
                        backgroundColor: XDarkThemeColors.secondaryBackground,
                        labelStyle: TextStyle(
                          color: _selectedCategory == categories[index]
                              ? XDarkThemeColors.primaryText
                              : XDarkThemeColors.secondaryText,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          _buildExploreTab(),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return StreamBuilder<List<CommunityModel>>(
      stream: context.watch<CommunityProvider>().getUserCommunities(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final communities = snapshot.data ?? [];
        if (communities.isEmpty) {
          return Center(
            child: Text(
              'Join some communities to see them here!',
              style: TextStyle(color: XDarkThemeColors.secondaryText),
            ),
          );
        }

        return ListView.builder(
          itemCount: communities.length,
          itemBuilder: (context, index) {
            final community = communities[index];
            if (_selectedCategory != 'All' &&
                community.category != _selectedCategory) {
              return SizedBox.shrink();
            }
            return _buildCommunityCard(community);
          },
        );
      },
    );
  }

  Widget _buildExploreTab() {
    return StreamBuilder<List<CommunityModel>>(
      stream: context.watch<CommunityProvider>().getAllCommunities(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final communities = snapshot.data ?? [];
        if (communities.isEmpty) {
          return Center(
            child: Text(
              'No communities found',
              style: TextStyle(color: XDarkThemeColors.secondaryText),
            ),
          );
        }

        return ListView.builder(
          itemCount: communities.length,
          itemBuilder: (context, index) {
            final community = communities[index];
            if (_selectedCategory != 'All' &&
                community.category != _selectedCategory) {
              return SizedBox.shrink();
            }
            return _buildCommunityCard(community);
          },
        );
      },
    );
  }

  Widget _buildCommunityCard(CommunityModel community) {
    return Card(
      color: XDarkThemeColors.secondaryBackground,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: community.avatarImage != null
              ? NetworkImage(community.avatarImage!)
              : null,
          child: community.avatarImage == null
              ? Text(community.name[0].toUpperCase())
              : null,
        ),
        title: Text(
          community.name,
          style: TextStyle(
            color: XDarkThemeColors.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          community.description,
          style: TextStyle(color: XDarkThemeColors.secondaryText),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CommunityDetailScreen(community: community),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: XDarkThemeColors.primaryAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text('View'),
        ),
      ),
    );
  }
}
