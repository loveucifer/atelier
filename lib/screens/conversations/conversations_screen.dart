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
        title: const Text('Inbox'),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.ellipses_bubble, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                   const SizedBox(height: 8),
                  Text(
                    'Start a conversation from a listing page.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final conversations = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshConversations,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const Divider(indent: 84, height: 1),
              itemBuilder: (context, index) {
                final convo = conversations[index];
                final lastMessageTime = convo['last_message_time'];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
                    backgroundImage: convo['other_user_avatar_url'] != null
                        ? CachedNetworkImageProvider(convo['other_user_avatar_url'])
                        : null,
                    child: convo['other_user_avatar_url'] == null
                        ? Icon(CupertinoIcons.person_fill, color: Colors.grey.shade400, size: 28)
                        : null,
                  ),
                  title: Text(
                    convo['other_user_display_name'] ?? 'Unknown User',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                  subtitle: Text(
                    convo['last_message_content'] ?? 'No messages yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15),
                  ),
                  trailing: lastMessageTime != null
                      ? Text(
                          DateFormat.jm().format(DateTime.parse(lastMessageTime)),
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        )
                      : null,
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}