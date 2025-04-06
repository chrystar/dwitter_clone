import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dwitter_clone/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class PostDetailScreen extends StatelessWidget {
  final String userName;
  final String content;
  String date;

  PostDetailScreen({super.key, required this.userName, required this.content, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XDarkThemeColors.secondaryBackground,
      appBar: AppBar(
        backgroundColor: XDarkThemeColors.secondaryBackground,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(AntDesign.arrow_left_outline),
          color: XDarkThemeColors.iconColor,
        ),
        title: Text(
          'Post',
          style: TextStyle(
            color: XDarkThemeColors.primaryText,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(),
                    SizedBox(width: 5),
                    Text(
                      userName.toString(),
                      style: TextStyle(
                          color: XDarkThemeColors.primaryText, fontSize: 18),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Follow'),
                ),
              ],
            ),
            Text(
              content.toString(),
              style: TextStyle(
                color: XDarkThemeColors.primaryText,
                fontSize: 20,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              child: Text(date.toString(), style: TextStyle(
                color: XDarkThemeColors.secondaryText,
              ),),
            ),
            Divider(
              color: XDarkThemeColors.divider,
              thickness: 2,
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Text('256 Likes', style: TextStyle(
                    color: XDarkThemeColors.primaryText,
                    fontSize: 16,
                  ),),
                ],
              ),
            ),
            Divider(
              color: XDarkThemeColors.divider,
              thickness: 2,
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Icon(AntDesign.comment_outline, color: XDarkThemeColors.mutedIconColor,),
                  SizedBox(width: 20),
                  Icon(AntDesign.heart_outline, color: XDarkThemeColors.mutedIconColor,),
                ],
              ),
            ),
            Divider(
              color: XDarkThemeColors.divider,
              thickness: 2,
              height: 5,
            ),
          ],
        ),
      ),
    );
  }
}
