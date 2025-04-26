import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../models/message_model.dart';
import '../../../providers/message_provider.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String recipientId;
  final String recipientName;

  const ChatScreen({
    Key? key,
    required this.conversationId,
    required this.recipientId,
    required this.recipientName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Mark conversation as read when opened
    Provider.of<MessageProvider>(context, listen: false)
        .markConversationAsRead(widget.conversationId, currentUser?.uid ?? '');
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = MessageModel(
      senderUid: currentUser?.uid ?? '',
      receiverUid: widget.recipientId,
      content: _messageController.text,
      timestamp: DateTime.now(),
      conversationId: widget.conversationId,
    );

    try {
      await Provider.of<MessageProvider>(context, listen: false)
          .sendMessage(message);
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.recipientName,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (context, messageProvider, child) {
                return StreamBuilder<QuerySnapshot>(
                  stream: messageProvider.getMessages(
                    widget.conversationId,
                    currentUser?.uid ?? '',
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No messages yet',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final messages = snapshot.data!.docs;
                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final messageData =
                            messages[index].data() as Map<String, dynamic>;
                        final message = MessageModel(
                          senderUid: messageData['senderUid'] ?? '',
                          receiverUid: messageData['receiverUid'] ?? '',
                          content: messageData['content'] ?? '',
                          timestamp:
                              (messageData['timestamp'] as Timestamp).toDate(),
                          conversationId: widget.conversationId,
                        );
                        final isMe = message.senderUid == currentUser?.uid;

                        return MessageBubble(
                          message: message.content,
                          isMe: isMe,
                          timestamp: message.timestamp,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime? timestamp;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
