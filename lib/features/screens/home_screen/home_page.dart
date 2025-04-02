import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController _scrollController = ScrollController();
  bool _isAppBarVisible = true;
  bool _isBottomNavVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_isAppBarVisible) {
          setState(() {
            _isAppBarVisible = false;
            _isBottomNavVisible = true;
          });
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_isAppBarVisible) {
          setState(() {
            _isAppBarVisible = true;
            _isBottomNavVisible = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
