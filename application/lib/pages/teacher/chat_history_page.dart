import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _chatHistory = [];
  
  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }
  
  Future<void> _loadChatHistory() async {
    // In a real app, this would fetch from a database
    // For this demo, we'll use mock data
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _chatHistory = [
          {
            'id': '1',
            'title': 'Grading Math Quiz',
            'last_message': 'I\'ve analyzed the student answers and provided grades.',
            'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
            'messages_count': 12,
          },
          {
            'id': '2',
            'title': 'Essay Feedback',
            'last_message': 'Here\'s detailed feedback on the essays you uploaded.',
            'timestamp': DateTime.now().subtract(const Duration(days: 1)),
            'messages_count': 8,
          },
          {
            'id': '3',
            'title': 'Science Test Analysis',
            'last_message': 'The class average was 78%. Here are areas for improvement.',
            'timestamp': DateTime.now().subtract(const Duration(days: 3)),
            'messages_count': 15,
          },
        ];
        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chatHistory.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.black26,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No chat history yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your conversations with the AI assistant will appear here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _chatHistory.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final chat = _chatHistory[index];
                    return ListTile(
                      title: Text(
                        chat['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            chat['last_message'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                _formatTimestamp(chat['timestamp']),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${chat['messages_count']} messages',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        child: const Icon(Icons.chat_outlined),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        onPressed: () {
                          // View chat details
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chat details not implemented in this demo'),
                            ),
                          );
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      onTap: () {
                        // View chat details
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chat details not implemented in this demo'),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

