import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  List<PlatformFile>? _selectedFiles;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.files;
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty && (_selectedFiles == null || _selectedFiles!.isEmpty)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _messages.add(
        ChatMessage(
          text: message,
          isUser: true,
          files: _selectedFiles,
        ),
      );
      _messageController.clear();
    });

    // Upload files if any
    List<String> fileUrls = [];
    if (_selectedFiles != null && _selectedFiles!.isNotEmpty) {
      for (var file in _selectedFiles!) {
        if (file.path != null) {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
          await supabase.storage.from('uploads').upload(
                fileName,
                File(file.path!),
              );
          
          final fileUrl = supabase.storage.from('uploads').getPublicUrl(fileName);
          fileUrls.add(fileUrl);
        }
      }
    }

    // Simulate AI response
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock AI response based on input
    String aiResponse = '';
    if (message.toLowerCase().contains('grade') || 
        message.toLowerCase().contains('check') ||
        fileUrls.isNotEmpty) {
      aiResponse = "I've analyzed the uploaded documents. Would you like me to grade them or provide feedback on specific aspects?";
    } else if (message.toLowerCase().contains('hello') || 
               message.toLowerCase().contains('hi')) {
      aiResponse = "Hello! I'm your AI teaching assistant. How can I help you today?";
    } else if (message.isEmpty && fileUrls.isNotEmpty) {
      aiResponse = "I've received your files. What would you like me to do with them?";
    } else {
      aiResponse = "I'm here to help with grading and classroom management. You can upload answer keys, question papers, and student answers for AI-assisted grading.";
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _selectedFiles = null;
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
        title: const Text('AI Assistant'),
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
                          'Your AI assistant is ready to help',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Upload files or ask questions about grading',
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
          
          // Selected files preview
          if (_selectedFiles != null && _selectedFiles!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 4.0),
                    child: Text(
                      'Selected Files:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedFiles!.length,
                      itemBuilder: (context, index) {
                        final file = _selectedFiles![index];
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Chip(
                            label: Text(
                              file.name.length > 15
                                  ? '${file.name.substring(0, 15)}...'
                                  : file.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                _selectedFiles!.removeAt(index);
                                if (_selectedFiles!.isEmpty) {
                                  _selectedFiles = null;
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickFiles,
                  tooltip: 'Upload Files',
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
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
  final List<PlatformFile>? files;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.files,
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
              backgroundColor: Color(0xFF4CAF50),
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
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.text.isNotEmpty)
                    Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  if (message.files != null && message.files!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: message.files!.map((file) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: message.isUser
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: message.isUser
                                    ? Colors.white.withOpacity(0.3)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getFileIcon(file.extension ?? ''),
                                  size: 16,
                                  color: message.isUser
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  file.name.length > 15
                                      ? '${file.name.substring(0, 15)}...'
                                      : file.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: message.isUser
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
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

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}

