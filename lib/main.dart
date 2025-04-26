import 'package:dwitter_clone/features/screens/Login/login_screen.dart';
import 'package:dwitter_clone/features/screens/bottom_nav/bottom_nav.dart';
import 'package:dwitter_clone/features/screens/profile/profile_screen.dart';
import 'package:dwitter_clone/features/screens/register/register_screen.dart';
import 'package:dwitter_clone/firebase_options.dart';
import 'package:dwitter_clone/providers/auth_provider.dart';
import 'package:dwitter_clone/providers/comment_provider.dart';
import 'package:dwitter_clone/providers/follow_provider.dart';
import 'package:dwitter_clone/providers/like_provider.dart';
import 'package:dwitter_clone/providers/message_provider.dart';
import 'package:dwitter_clone/providers/post_provider.dart';
import 'package:dwitter_clone/providers/stories_provider.dart';
import 'package:dwitter_clone/providers/community_provider.dart';
import 'package:dwitter_clone/providers/viewed_stories_provider.dart';
import 'package:dwitter_clone/providers/notification_provider.dart';
import 'package:dwitter_clone/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MyApp(),
  );
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasData) {
          // Initialize StoryProvider when user is authenticated
          Future.microtask(() {
            context.read<StoryProvider>().initialize();
          });
          return const BottomNav();
        }

        return const LoginScreen();
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProviders()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => FollowProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => LikeProvider()),
        ChangeNotifierProvider(create: (_) => ViewedStoriesProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(),
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        title: 'Flutter Demo',
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/register': (context) => RegisterScreen(),
          '/login': (context) => LoginScreen(),
          '/home': (context) =>
              const BottomNav(), // Changed from HomePage to BottomNav
          '/profile': (context) => ProfileScreen(),
        },
      ),
    );
  }
}
