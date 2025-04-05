import 'package:flutter/material.dart';

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
  NotificationScreen(),
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
      body: navOptions[selectedItem],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade800,
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
            icon: Icon(Icons.notifications,),
            label: 'notifi'
          ),
        ],
      ),
    );
  }
}
