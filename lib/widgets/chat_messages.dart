import 'package:chatbuddy/widgets/messgae_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});

  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  final authenticationUser = FirebaseAuth.instance.currentUser!;
  final Set<String> _selectedMessages = {}; // Stores selected message IDs
  bool _isSelectionMode = false;

  Future<void> _deleteMessages() async {
    for (String messageId in _selectedMessages) {
      try {
        await FirebaseFirestore.instance.collection("chat").doc(messageId).delete();
      } catch (error) {
        print("Error deleting message: $error");
      }
    }
    setState(() {
      _isSelectionMode = false;
      _selectedMessages.clear();
    });
  }

  void _toggleSelectionMode(String messageId) {
    setState(() {
      if (_selectedMessages.contains(messageId)) {
        _selectedMessages.remove(messageId);
      } else {
        _selectedMessages.add(messageId);
      }
      _isSelectionMode = _selectedMessages.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
        title: Text("${_selectedMessages.length} selected"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _selectedMessages.isNotEmpty
                ? () => _showDeleteConfirmationDialog(context)
                : null,
          ),
        ],
      )
          : null,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("chat")
            .orderBy("CreatedAt", descending: true)
            .snapshots(),
        builder: (ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            return Center(child: Text("No messages found"));
          }
          if (chatSnapshot.hasError) {
            return Center(child: Text("Something went wrong..."));
          }
          final loadedMessages = chatSnapshot.data!.docs;
          return ListView.builder(
            padding: EdgeInsets.only(bottom: 40, left: 13, right: 13),
            reverse: true,
            itemCount: loadedMessages.length,
            itemBuilder: (ctx, index) {
              final messageDoc = loadedMessages[index];
              final chatMessages = messageDoc.data();
              final nextChatMessage = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data()
                  : null;
              final currentMessageUserId = chatMessages["userId"];
              final nextMessageUserId =
              nextChatMessage != null ? nextChatMessage["userId"] : null;
              final nextUserIsSame = nextMessageUserId == currentMessageUserId;
              final messageId = messageDoc.id;
              final isSelected = _selectedMessages.contains(messageId);

              return GestureDetector(
                onLongPress: () {
                  if (authenticationUser.uid == currentMessageUserId) {
                    _toggleSelectionMode(messageId);
                  }
                },
                onTap: () {
                  if (_isSelectionMode) {
                    _toggleSelectionMode(messageId);
                  }
                },
                child: Container(
                  color: isSelected ? Colors.blue.withOpacity(0.2) : null,
                  child: nextUserIsSame
                      ? MessageBubble.next(
                    message: chatMessages["text"],
                    isMe: authenticationUser.uid == currentMessageUserId,
                  )
                      : MessageBubble.first(
                    username: chatMessages["username"],
                    message: chatMessages["text"],
                    isMe: authenticationUser.uid == currentMessageUserId,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Messages"),
        content: Text("Are you sure you want to delete selected messages?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _deleteMessages();
              Navigator.of(ctx).pop();
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }
}
