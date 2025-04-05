import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ClassesPage extends StatefulWidget {
  const ClassesPage({super.key});

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
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
            .from('student_classes')
            .select('*, classes(*)')
            .eq('student_id', user.id);
        
        List<Map<String, dynamic>> formattedClasses = [];
        for (var item in data) {
          formattedClasses.add(item['classes']);
        }
        
        if (mounted) {
          setState(() {
            _classes = formattedClasses;
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
  
  void _joinClass() {
    final TextEditingController classCodeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Join Class'),
          content: TextField(
            controller: classCodeController,
            decoration: const InputDecoration(
              labelText: 'Enter Class Code',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (classCodeController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a class code'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                try {
                  final user = supabase.auth.currentUser;
                  if (user != null) {
                    // Find the class with the given code
                    final classData = await supabase
                        .from('classes')
                        .select()
                        .eq('class_code', classCodeController.text.trim())
                        .maybeSingle();
                    
                    if (classData == null) {
                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Class not found. Please check the code and try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }
                    
                    // Check if already joined
                    final existingJoin = await supabase
                        .from('student_classes')
                        .select()
                        .eq('student_id', user.id)
                        .eq('class_id', classData['id'])
                        .maybeSingle();
                    
                    if (existingJoin != null) {
                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You have already joined this class'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                      return;
                    }
                    
                    // Join the class
                    await supabase.from('student_classes').insert({
                      'student_id': user.id,
                      'class_id': classData['id'],
                      'joined_at': DateTime.now().toIso8601String(),
                    });
                    
                    if (mounted) {
                      Navigator.of(context).pop();
                      _loadClasses();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Successfully joined ${classData['name']}'),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error joining class: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Classes'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _joinClass,
            tooltip: 'Join Class',
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
                        'Join a class to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _joinClass,
                        icon: const Icon(Icons.add),
                        label: const Text('Join Class'),
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
                            Text(
                              classItem['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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
                                    // View assignments
                                  },
                                  icon: const Icon(Icons.assignment),
                                  label: const Text('Assignments'),
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

