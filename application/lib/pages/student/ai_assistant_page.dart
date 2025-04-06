import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class StudentAIAssistantPage extends StatefulWidget {
  const StudentAIAssistantPage({super.key});

  @override
  State<StudentAIAssistantPage> createState() => _StudentAIAssistantPageState();
}

class _StudentAIAssistantPageState extends State<StudentAIAssistantPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _messages.add(
        ChatMessage(
          text: message,
          isUser: true,
        ),
      );
      _messageController.clear();
    });

    // Simulate AI response
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock AI response based on input
    String aiResponse = '';
    if (message.toLowerCase().contains('math') || 
        message.toLowerCase().contains('problem')) {
      aiResponse = "I can help with math problems. Could you share the specific question or topic you're struggling with?";
    } else if (message.toLowerCase().contains('essay') || 
               message.toLowerCase().contains('writing')) {
      aiResponse = "For essay writing, I recommend starting with a clear thesis statement. What's the topic you're writing about?";
    } else if (message.toLowerCase().contains('hello') || 
               message.toLowerCase().contains('hi')) {
      aiResponse = "Hello! I'm your AI learning assistant. How can I help with your assignments today?";
    } else {
      aiResponse = "I'm here to help with your assignments and learning. Feel free to ask me about specific subjects or homework questions.";
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _messages.add(
          ChatMessage(
            text: aiResponse,
            isUser: false,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Learning Assistant'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.black26,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Your AI learning assistant is ready',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Ask questions about your assignments or subjects',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return ChatBubble(message: message);
                    },
                  ),
          ),
          
          // Message input
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask a question...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            const CircleAvatar(
              backgroundColor: Color(0xFF2196F3),
              radius: 16,
              child: Icon(
                Icons.smart_toy,
                size: 16,
                color: Colors.white,
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser)
            const CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 16,
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

