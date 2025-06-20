import 'package:atelier/main.dart';
import 'package:atelier/screens/messaging/chat_screen.dart';
import 'package:atelier/widgets/common/glass_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  late Future<List<Map<String, dynamic>>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    _conversationsFuture = _fetchConversations();
  }

  Future<List<Map<String, dynamic>>> _fetchConversations() async {
    return await supabase.rpc('get_my_conversations');
  }

  Future<void> _refreshConversations() async {
    setState(() {
      _conversationsFuture = _fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const GlassAppBar(title: 'Messages'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _conversationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'You have no messages yet.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final conversations = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshConversations,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 100),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final convo = conversations[index];
                final lastMessageTime = convo['last_message_time'];

                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          conversationId: convo['conversation_id'],
                          otherUserName: convo['other_user_display_name'] ?? 'User',
                        ),
                      ),
                    ).then((_) => _refreshConversations());
                  },
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white10,
                    backgroundImage: convo['other_user_avatar_url'] != null
                        ? CachedNetworkImageProvider(convo['other_user_avatar_url'])
                        : null,
                    child: convo['other_user_avatar_url'] == null
                        ? const Icon(CupertinoIcons.person_fill, color: Colors.white)
                        : null,
                  ),
                  title: Text(
                    convo['other_user_display_name'] ?? 'Unknown User',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    convo['last_message_content'] ?? 'No messages yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  trailing: lastMessageTime != null
                      ? Text(
                          DateFormat.jm().format(DateTime.parse(lastMessageTime)),
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        )
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}