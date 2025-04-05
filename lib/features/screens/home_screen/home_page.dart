import 'package:dwitter_clone/features/widgets/Ddrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stories_for_flutter/stories_for_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class _HomePageState extends State<HomePage> {
  User? user = _auth.currentUser;

  final storyProfile = _firestore.collection('users').doc('profileImage');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black12,
          title: Text(
            "Dwitt",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Builder(
              // Wrap GestureDetector with Builder
              builder: (BuildContext innerContext) {
                return GestureDetector(
                  onTap: () {
                    Scaffold.of(innerContext)
                        .openDrawer(); // Use the innerContext
                  },
                  child: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                );
              },
            ),
          )),
      drawer: XDrawer(),
      body: Padding(
        padding: EdgeInsets.only(top: 10, left: 20),
        child: Column(
          children: [
          
          ],
        ),
      ),
    );
  }
}
