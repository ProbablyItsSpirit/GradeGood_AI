import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class UploadWorkPage extends StatefulWidget {
  const UploadWorkPage({super.key});

  @override
  State<UploadWorkPage> createState() => _UploadWorkPageState();
}

class _UploadWorkPageState extends State<UploadWorkPage> {
  bool _isLoading = false;
  List<PlatformFile>? _selectedFiles;
  String? _selectedClass;
  String? _selectedAssignment;
  final TextEditingController _notesController = TextEditingController();
  
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _assignments = [];
  
  @override
  void initState() {
    super.initState();
    _loadClasses();
  }
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // In a real app, this would fetch from a database
      // For this demo, we'll use mock data
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() {
          _classes = [
            {'id': '1', 'name': 'Mathematics'},
            {'id': '2', 'name': 'Science'},
            {'id': '3', 'name': 'History'},
            {'id': '4', 'name': 'English'},
          ];
          _isLoading = false;
        });
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
  
  Future<void> _loadAssignments(String classId) async {
    setState(() {
      _isLoading = true;
      _selectedAssignment = null;
    });
    
    try {
      // In a real app, this would fetch from a database
      // For this demo, we'll use mock data
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          switch (classId) {
            case '1': // Mathematics
              _assignments = [
                {'id': '1', 'title': 'Math Homework'},
                {'id': '2', 'title': 'Algebra Quiz'},
              ];
              break;
            case '2': // Science
              _assignments = [
                {'id': '3', 'title': 'Science Lab Report'},
                {'id': '4', 'title': 'Physics Problem Set'},
              ];
              break;
            case '3': // History
              _assignments = [
                {'id': '5', 'title': 'History Essay'},
                {'id': '6', 'title': 'Historical Analysis'},
              ];
              break;
            case '4': // English
              _assignments = [
                {'id': '7', 'title': 'Literature Analysis'},
                {'id': '8', 'title': 'Creative Writing'},
              ];
              break;
            default:
              _assignments = [];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading assignments: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
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
  
  Future<void> _uploadWork() async {
    if (_selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a class'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_selectedAssignment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an assignment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_selectedFiles == null || _selectedFiles!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one file to upload'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Upload files
      List<String> fileUrls = [];
      for (var file in _selectedFiles!) {
        if (file.path != null) {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
          await supabase.storage.from('student_uploads').upload(
                fileName,
                File(file.path!),
              );
          
          final fileUrl = supabase.storage.from('student_uploads').getPublicUrl(fileName);
          fileUrls.add(fileUrl);
        }
      }
      
      // In a real app, save submission to database
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Work uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reset form
        setState(() {
          _selectedFiles = null;
          _notesController.clear();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading work: $e'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Work'),
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
                    'Submit Your Assignment',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Class Selection
                  const Text(
                    'Select Class',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select a class',
                    ),
                    value: _selectedClass,
                    items: _classes.map((classItem) {
                      return DropdownMenuItem<String>(
                        value: classItem['id'],
                        child: Text(classItem['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClass = value;
                      });
                      if (value != null) {
                        _loadAssignments(value);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Assignment Selection
                  const Text(
                    'Select Assignment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select an assignment',
                    ),
                    value: _selectedAssignment,
                    items: _assignments.map((assignment) {
                      return DropdownMenuItem<String>(
                        value: assignment['id'],
                        child: Text(assignment['title']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAssignment = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // File Upload
                  const Text(
                    'Upload Files',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _pickFiles,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Select Files'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  
                  // Selected Files
                  if (_selectedFiles != null && _selectedFiles!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selected Files:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _selectedFiles!.length,
                            itemBuilder: (context, index) {
                              final file = _selectedFiles![index];
                              return ListTile(
                                leading: Icon(
                                  _getFileIcon(file.extension ?? ''),
                                  color: Colors.blue,
                                ),
                                title: Text(file.name),
                                subtitle: Text(
                                  '${(file.size / 1024).toStringAsFixed(2)} KB',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
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
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  
                  // Notes
                  const Text(
                    'Additional Notes (Optional)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Add any notes for your teacher...',
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _uploadWork,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text('Submit Assignment'),
                      ),
                    ),
                  ),
                ],
              ),
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

