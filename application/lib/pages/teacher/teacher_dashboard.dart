import 'package:flutter/material.dart';
import 'package:gradegood/pages/teacher/ai_assistant_page.dart';
import 'package:gradegood/pages/teacher/classroom_page.dart';
import 'package:gradegood/pages/teacher/settings_page.dart';
import 'package:gradegood/pages/teacher/chat_history_page.dart';
import 'package:gradegood/pages/landing_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;
  String _teacherName = 'Teacher';
  bool _isLoading = true;

  final List<Widget> _pages = [
    const AIAssistantPage(),
    const ClassroomPage(),
    const SettingsPage(),
    const ChatHistoryPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadTeacherProfile();
  }

  Future<void> _loadTeacherProfile() async {
    try {
      // Simulate a delay for loading effect
      await Future.delayed(const Duration(milliseconds: 500));
    
      if (mounted) {
        setState(() {
          _teacherName = 'Demo Teacher';
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
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: Text('AI Assistant'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.class_outlined),
                selectedIcon: Icon(Icons.class_),
                label: Text('Classroom'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: Text('Chat History'),
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
                      _isLoading ? 'Loading...' : _teacherName,
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

