import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = true;
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _emailController = TextEditingController();
  String? _avatarUrl;
  
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
  
  Future<void> _loadProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final userData = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        
        if (mounted) {
          setState(() {
            _nameController.text = userData['name'] ?? '';
            _emailController.text = user.email ?? '';
            _avatarUrl = userData['avatar_url'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('profiles').update({
          'name': _nameController.text.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Avatar
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _avatarUrl != null
                              ? NetworkImage(_avatarUrl!)
                              : null,
                          child: _avatarUrl == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () {
                            // Upload avatar functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Avatar upload not implemented in this demo'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.upload),
                          label: const Text('Change Avatar'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Name
                  const Text(
                    'Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your name',
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Email
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your email',
                    ),
                    readOnly: true,
                    enabled: false,
                  ),
                  const SizedBox(height: 32),
                  
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _updateProfile,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text('Save Changes'),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Password change
                  const Text(
                    'Security',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Change password functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password change not implemented in this demo'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Change Password'),
                  ),
                ],
              ),
            ),
    );
  }
}

