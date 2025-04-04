import 'package:dwitter_clone/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AuthProviders? authProviders;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authProviders = Provider.of<AuthProviders>(context, listen:  false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            authProviders?.signOut();
            Navigator.pushReplacementNamed(context, '/login');
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
    );
  }
}
