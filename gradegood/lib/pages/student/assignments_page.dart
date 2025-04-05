import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AssignmentsPage extends StatefulWidget {
  const AssignmentsPage({super.key});

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _assignments = [];
  
  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }
  
  Future<void> _loadAssignments() async {
    // In a real app, this would fetch from a database
    // For this demo, we'll use mock data
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _assignments = [
          {
            'id': '1',
            'title': 'Math Homework',
            'class_name': 'Mathematics',
            'due_date': DateTime.now().add(const Duration(days: 2)),
            'status': 'pending',
          },
          {
            'id': '2',
            'title': 'Science Lab Report',
            'class_name': 'Science',
            'due_date': DateTime.now().add(const Duration(days: 5)),
            'status': 'pending',
          },
          {
            'id': '3',
            'title': 'History Essay',
            'class_name': 'History',
            'due_date': DateTime.now().subtract(const Duration(days: 1)),
            'status': 'uploaded',
          },
          {
            'id': '4',
            'title': 'Literature Analysis',
            'class_name': 'English',
            'due_date': DateTime.now().subtract(const Duration(days: 3)),
            'status': 'graded',
            'grade': 'A-',
          },
        ];
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'uploaded':
        return Colors.blue;
      case 'graded':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inDays == 0) {
      return 'Due Today';
    } else if (difference.inDays == 1) {
      return 'Due Tomorrow';
    } else {
      return 'Due in ${difference.inDays} days';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _assignments.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: Colors.black26,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No assignments yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your assignments will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = _assignments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          assignment['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text('Class: ${assignment['class_name']}'),
                            const SizedBox(height: 4),
                            Text(
                              _formatDueDate(assignment['due_date']),
                              style: TextStyle(
                                color: assignment['due_date'].isBefore(DateTime.now())
                                    ? Colors.red
                                    : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(assignment['status']).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    assignment['status'].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(assignment['status']),
                                    ),
                                  ),
                                ),
                                if (assignment['status'] == 'graded')
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Grade: ${assignment['grade']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 16),
                          onPressed: () {
                            // View assignment details
                          },
                        ),
                        onTap: () {
                          // View assignment details
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

