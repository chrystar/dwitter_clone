import 'package:dwitter_clone/features/screens/community/communities.dart';
import 'package:dwitter_clone/features/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../theme/app_theme.dart';
import '../../../providers/message_provider.dart';
import '../../widgets/Ddrawer.dart';
import '../Login/login_screen.dart';
import '../chart/chat_screen.dart';
import '../home_screen/home_page.dart';
import '../notification/notification_screen.dart';
import '../post/create_post_screen.dart';
import '../search/search_screen.dart';
import '../messages/messages_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

List navOptions = [
  HomePage(),
  SearchScreen(),
  Communities(),
  ChatScreen(),
  ProfileScreen(),
];

final List<String> _appBarTitles = [
  'Dewitt',
  'Search',
  'Profile',
  'Profile',
  'Profile',
];

int selectedItem = 0;

class _BottomNavState extends State<BottomNav> {
  Widget _buildBadge(int count) {
    if (count == 0) return const SizedBox();
    return Positioned(
      right: 0,
      top: 0,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        constraints: const BoxConstraints(
          minWidth: 16,
          minHeight: 16,
        ),
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationScreen()),
    );
  }

  void _showPopupMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: XDarkThemeColors.secondaryBackground,
        title: Text(
          'Options',
          style: TextStyle(color: XDarkThemeColors.primaryText),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.logout, color: XDarkThemeColors.iconColor),
              title: Text(
                'Logout',
                style: TextStyle(color: XDarkThemeColors.primaryText),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  // Replace the entire navigation stack with login screen
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: XDarkThemeColors.iconColor),
            ),
          ),
        ],
      ),
    );
  }

  void onItemTapped(int index) {
    setState(() {
      selectedItem = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final messageProvider = Provider.of<MessageProvider>(context);

    final List<List<Widget>> appBarActions = [
      [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Row(children: <Widget>[
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications,
                      color: XDarkThemeColors.iconColor),
                  onPressed: _navigateToNotifications,
                ),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser?.uid)
                      .collection('notifications')
                      .doc('counter')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count = (snapshot.data?.data()
                            as Map<String, dynamic>?)?['unreadCount'] ??
                        0;
                    return _buildBadge(count);
                  },
                ),
              ],
            ),
            const SizedBox(width: 10),
            Stack(
              children: [
                IconButton(
                  icon: Icon(AntDesign.send_outline,
                      color: XDarkThemeColors.iconColor),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MessagesScreen()),
                  ),
                ),
                Consumer<MessageProvider>(
                  builder: (context, messageProvider, _) {
                    return StreamBuilder<int>(
                      stream: messageProvider
                          .getTotalUnreadCount(currentUser?.uid ?? ''),
                      builder: (context, snapshot) {
                        return _buildBadge(snapshot.data ?? 0);
                      },
                    );
                  },
                ),
              ],
            ),
          ]),
        ),
      ],
      [IconButton(icon: const Icon(Icons.filter_list), onPressed: () {})],
      [IconButton(icon: const Icon(Icons.edit), onPressed: () {})],
      [IconButton(icon: const Icon(Icons.edit), onPressed: () {})],
      [
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
          onPressed: () => _showPopupMenu(context),
        ),
      ],
    ];

    return Scaffold(
      backgroundColor: XDarkThemeColors.secondaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: Text(
          _appBarTitles[selectedItem],
          style: TextStyle(color: XDarkThemeColors.primaryText),
        ),
        actions: appBarActions[selectedItem],
        centerTitle: true,
      ),
      body: navOptions[selectedItem],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: XDarkThemeColors.secondaryBackground,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.shade400,
        currentIndex: selectedItem,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        onTap: onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'post',
          ),
          BottomNavigationBarItem(
            icon: Icon(AntDesign.video_camera_add_outline),
            label: 'chat',
          ),
          BottomNavigationBarItem(
              icon: CircleAvatar(
                radius: 12,
              ),
              label: 'account'),
        ],
      ),
    );
  }
}
