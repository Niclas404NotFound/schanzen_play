import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

import '../widgets/files/files_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    // Optional: Reset your FilesList filter here
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: false,
    );

    // User cancelled the picker
    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;

    if (!mounted) return;

    // Open input dialog
    _showAddDialog(file);
  }

  void _showAddDialog(PlatformFile file) {
    _nameController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add file'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selected: ${file.name}'),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Enter file name...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text.trim();

                if (name.isEmpty) return;

                debugPrint('File: ${file.name}');
                debugPrint('Custom name: $name');

                // TODO: Save the selected file

                Navigator.pop(context);
              },
              child: const Text('Add'),
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
        // Swap the title widget based on _isSearching
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true, // Opens the keyboard automatically
                decoration: const InputDecoration(
                  hintText: 'Search files...',
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  // Pass 'query' to filter your FilesList
                },
              )
            : Text(widget.title),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _stopSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _startSearch,
            ),
        ],
      ),
      body: const Center(
        child: FilesList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        child: const Icon(Icons.add),
      ),
    );
  }
}
