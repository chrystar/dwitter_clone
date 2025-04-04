import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class XDrawer extends StatefulWidget {
  const XDrawer({super.key});

  @override
  State<XDrawer> createState() => _XDrawerState();
}

class _XDrawerState extends State<XDrawer> {
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;

  String _name = '';
  Future<void> _loadUser() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userData =
        await _fireStore.collection('users').doc(user.uid).get();

        if(userData.exists){
          setState(() {
            _name = userData.get('name') ?? 'your name';
          });
        }
      } catch (e) {}
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUser();
    print(_name);
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildDrawerHeader(context),
          _buildDrawerItem(
              icon: Icons.person_outline,
              text: 'Profile',
              onTap: () {
                // Handle Profile navigation
                Navigator.pushReplacementNamed(context, '/profile');
              }),
          _buildDrawerItem(
              icon: Icons.list_alt_outlined,
              text: 'Lists',
              onTap: () {
                // Handle Lists navigation
                Navigator.pop(context);
              }),
          _buildDrawerItem(
              icon: Icons.topic_outlined,
              text: 'Topics',
              onTap: () {
                // Handle Topics navigation
                Navigator.pop(context);
              }),
          _buildDrawerItem(
              icon: Icons.bookmark_border_outlined,
              text: 'Bookmarks',
              onTap: () {
                // Handle Bookmarks navigation
                Navigator.pop(context);
              }),
          _buildDrawerItem(
              icon: Icons.monetization_on_outlined,
              text: 'Monetization',
              onTap: () {
                // Handle Monetization navigation
                Navigator.pop(context);
              }),
          const Divider(),
          _buildDrawerItem(text: 'Settings and support', isHeader: true),
          _buildDrawerItem(
              icon: Icons.settings_outlined,
              text: 'Settings and privacy',
              onTap: () {
                // Handle Settings and privacy navigation
                Navigator.pop(context);
              }),
          _buildDrawerItem(
              icon: Icons.help_outline,
              text: 'Help Center',
              onTap: () {
                // Handle Help Center navigation
                Navigator.pop(context);
              }),
          const Divider(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.lightbulb_outline),
                  onPressed: () {
                    // Toggle light/dark mode
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () {
                    // Open QR code scanner
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, ) {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: const BoxDecoration(
        color: Colors.white, // Or your app's background color
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              // Navigate to the profile screen
              Navigator.pushReplacementNamed(context, '/profile');
              // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage('URL_TO_YOUR_PROFILE_IMAGE'),
                  // Replace with your image URL
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      // Optional: Verified badge
                      // Positioned(
                      //   bottom: -2,
                      //   right: -2,
                      //   child: Icon(Icons.check_circle, color: Colors.blue, size: 18),
                      // ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    backgroundColor: Colors.white,
                      scrollControlDisabledMaxHeightRatio: 0.35,
                      context: context,
                      builder: (context) {
                        return Container(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Text('data'),
                            ],
                          ),
                        );
                      }),
                  child: Icon(Icons.more_vert),
                ),
                //const SizedBox(width: 12),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
               _name, // Replace with the user's name
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                '@yourhandle', // Replace with the user's handle
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                '100 ', // Replace with the number of following
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                'Following',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              SizedBox(width: 16),
              Text(
                '200 ', // Replace with the number of followers
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                'Followers',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      {IconData? icon,
      required String text,
      VoidCallback? onTap,
      bool isHeader = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            if (icon != null) Icon(icon),
            if (icon != null) const SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
