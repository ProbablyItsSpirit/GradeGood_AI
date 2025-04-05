import 'package:flutter/material.dart';
import 'package:gradegood/pages/student/classes_page.dart';
import 'package:gradegood/pages/student/assignments_page.dart';
import 'package:gradegood/pages/student/grades_page.dart';
import 'package:gradegood/pages/student/ai_assistant_page.dart';
import 'package:gradegood/pages/student/upload_work_page.dart';
import 'package:gradegood/pages/landing_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;
  String _studentName = 'Student';
  bool _isLoading = true;

  final List<Widget> _pages = [
    const ClassesPage(),
    const AssignmentsPage(),
    const GradesPage(),
    const StudentAIAssistantPage(),
    const UploadWorkPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
  }

  Future<void> _loadStudentProfile() async {
    try {
      // Simulate a delay for loading effect
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _studentName = 'Demo Student';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    // No need to sign out from Supabase
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LandingPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar navigation
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 800,
            minExtendedWidth: 200,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.class_outlined),
                selectedIcon: Icon(Icons.class_),
                label: Text('Classes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: Text('Assignments'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.grade_outlined),
                selectedIcon: Icon(Icons.grade),
                label: Text('Grades'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: Text('AI Assistant'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.upload_file_outlined),
                selectedIcon: Icon(Icons.upload_file),
                label: Text('Upload Work'),
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(height: 8),
                  if (MediaQuery.of(context).size.width > 800)
                    Text(
                      _isLoading ? 'Loading...' : _studentName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _signOut,
                tooltip: 'Logout',
              ),
            ),
          ),
          
          // Main content
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

