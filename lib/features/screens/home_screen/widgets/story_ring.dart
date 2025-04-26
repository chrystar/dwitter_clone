import 'package:flutter/material.dart';

class StoryRing extends StatelessWidget {
  final Widget child;
  final bool hasUnviewedStories;
  final double radius;

  const StoryRing({
    Key? key,
    required this.child,
    required this.hasUnviewedStories,
    this.radius = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasUnviewedStories
            ? LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: hasUnviewedStories ? null : Colors.grey[800],
      ),
      padding: EdgeInsets.all(2),
      child: child,
    );
  }
}
