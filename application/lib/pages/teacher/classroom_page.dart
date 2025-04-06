import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ClassroomPage extends StatefulWidget {
  const ClassroomPage({super.key});

  @override
  State<ClassroomPage> createState() => _ClassroomPageState();
}

class _ClassroomPageState extends State<ClassroomPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _classes = [];
  
  @override
  void initState() {
    super.initState();
    _loadClasses();
  }
  
  Future<void> _loadClasses() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final data = await supabase
            .from('classes')
            .select()
            .eq('teacher_id', user.id);
        
        if (mounted) {
          setState(() {
            _classes = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading classes: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _createClass() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController classNameController = TextEditingController();
        final TextEditingController classDescriptionController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Create New Class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: classNameController,
                  decoration: const InputDecoration(
                    labelText: 'Class Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: classDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (classNameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a class name'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                try {
                  final user = supabase.auth.currentUser;
                  if (user != null) {
                    // Generate a unique class code
                    final classCode = _generateClassCode();
                    
                    await supabase.from('classes').insert({
                      'name': classNameController.text.trim(),
                      'description': classDescriptionController.text.trim(),
                      'teacher_id': user.id,
                      'class_code': classCode,
                      'created_at': DateTime.now().toIso8601String(),
                    });
                    
                    if (mounted) {
                      Navigator.of(context).pop();
                      _loadClasses();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Class created with code: $classCode'),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error creating class: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
  
  String _generateClassCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String result = '';
    
    for (var i = 0; i < 6; i++) {
      result += chars[(random + i) % chars.length];
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classroom Management'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createClass,
            tooltip: 'Create New Class',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.class_outlined,
                        size: 64,
                        color: Colors.black26,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No classes yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create your first class to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _createClass,
                        icon: const Icon(Icons.add),
                        label: const Text('Create Class'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _classes.length,
                  itemBuilder: (context, index) {
                    final classItem = _classes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    classItem['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    'Code: ${classItem['class_code']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: Colors.blue.shade100,
                                ),
                              ],
                            ),
                            if (classItem['description'] != null &&
                                classItem['description'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  classItem['description'],
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    // View class details
                                  },
                                  icon: const Icon(Icons.visibility),
                                  label: const Text('View'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    // Manage students
                                  },
                                  icon: const Icon(Icons.people),
                                  label: const Text('Students'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

