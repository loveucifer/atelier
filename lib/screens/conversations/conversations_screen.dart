import 'package:atelier/main.dart';
import 'package:atelier/screens/messaging/chat_screen.dart';
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

  // Logic to fetch conversations is preserved
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
      appBar: AppBar(
        title: const Text('Messages'),
      ),
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
            return Center(
              child: Text(
                'You have no messages yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
            );
          }

          final conversations = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshConversations,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const Divider(indent: 80, height: 1),
              itemBuilder: (context, index) {
                final convo = conversations[index];
                final lastMessageTime = convo['last_message_time'];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
                    backgroundImage: convo['other_user_avatar_url'] != null
                        ? CachedNetworkImageProvider(convo['other_user_avatar_url'])
                        : null,
                    child: convo['other_user_avatar_url'] == null
                        ? Icon(CupertinoIcons.person_fill, color: Colors.grey.shade400)
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
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  ),
                  trailing: lastMessageTime != null
                      ? Text(
                          DateFormat.jm().format(DateTime.parse(lastMessageTime)),
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        )
                      : null,
                  onTap: () {
                    // Navigation logic is preserved
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}