import 'package:dwitter_clone/features/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../../theme/app_theme.dart';
import '../../widgets/Ddrawer.dart';
import '../chart/chat_screen.dart';
import '../home_screen/home_page.dart';
import '../notification/notification_screen.dart';
import '../post/create_post_screen.dart';
import '../search/search_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

List navOptions = [
  HomePage(),
  SearchScreen(),
  CreatePostScreen(),
  ChatScreen(),
  ProfileScreen(),
];

int selectedItem = 0;


class _BottomNavState extends State<BottomNav> {
  @override

  void onItemTapped(int index) {
    setState(() {
      selectedItem = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XDarkThemeColors.secondaryBackground,
      appBar: AppBar(
          backgroundColor: Colors.black12,
          title: Text(
            "Dwitt",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: XDarkThemeColors.primaryText,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
              children: <Widget>[
                Icon(Icons.notifications, color: XDarkThemeColors.iconColor),
                SizedBox(width: 10),
                Icon(AntDesign.send_outline, color: XDarkThemeColors.iconColor,)
              ]
                        ),
            ),
        ],
          centerTitle: true,
         ),
      body: navOptions[selectedItem],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: XDarkThemeColors.primaryBackground,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.shade400,
        currentIndex: selectedItem,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        onTap: (index) {
          if(index == 2){
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostScreen()));
          }else {
            onItemTapped(index);
          }
        },
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
            icon: Icon(Icons.add),
            label: 'post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'chat',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(radius: 12,),
            label: 'account'
          ),
        ],
      ),
    );
  }
}
