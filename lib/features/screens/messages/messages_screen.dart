import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../providers/message_provider.dart';
import './chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final messageProvider = Provider.of<MessageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Messages');
            final userData = snapshot.data?.data() as Map<String, dynamic>?;
            return Text(
              userData?['username'] ?? 'Messages',
              style: const TextStyle(color: Colors.white),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => FollowersListSheet(),
                backgroundColor: Colors.grey[900],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar with Instagram style
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[900],
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),

          // Conversations List
          Expanded(
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: messageProvider
                  .getConversationsWithUserData(currentUser?.uid ?? ''),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final userData =
                        snapshot.data![index].data() as Map<String, dynamic>;
                    final conversationId = messageProvider.getConversationId(
                      currentUser?.uid ?? '',
                      snapshot.data![index].id,
                    );

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundImage:
                            NetworkImage(userData['profileImage'] ?? ''),
                      ),
                      title: Text(
                        userData['username'] ?? 'Unknown User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('conversations')
                            .doc(conversationId)
                            .snapshots(),
                        builder: (context, convSnapshot) {
                          if (!convSnapshot.hasData) return const SizedBox();
                          final convData = convSnapshot.data?.data()
                              as Map<String, dynamic>?;
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  convData?['lastMessage'] ??
                                      'Start a conversation',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (convData?['timestamp'] != null)
                                Text(
                                  timeago.format(
                                    (convData!['timestamp'] as Timestamp)
                                        .toDate(),
                                    allowFromNow: true,
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              conversationId: conversationId,
                              recipientId: snapshot.data![index].id,
                              recipientName:
                                  userData['username'] ?? 'Unknown User',
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FollowersListSheet extends StatelessWidget {
  const FollowersListSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New Message',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.grey[800],
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser?.uid)
                  .collection('following')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final followingId = snapshot.data!.docs[index].id;
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(followingId)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const SizedBox();
                        }

                        final userData =
                            userSnapshot.data!.data() as Map<String, dynamic>;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(userData['profileImage'] ?? ''),
                            radius: 24,
                          ),
                          title: Text(
                            userData['username'] ?? 'Unknown User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            final messageProvider =
                                Provider.of<MessageProvider>(context,
                                    listen: false);
                            final conversationId =
                                messageProvider.getConversationId(
                              currentUser?.uid ?? '',
                              followingId,
                            );

                            Navigator.pop(context); // Close bottom sheet
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  conversationId: conversationId,
                                  recipientId: followingId,
                                  recipientName:
                                      userData['username'] ?? 'Unknown User',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
