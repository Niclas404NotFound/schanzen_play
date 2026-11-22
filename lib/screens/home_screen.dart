import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../widgets/files/files_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  bool _isSaving = false;

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
  }

  // Open native file picker
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      // User cancelled the picker
      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

      if (!mounted) return;

      _showAddDialog(file);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select audio file: $e'),
        ),
      );
    }
  }

  // Copy selected file into application storage
  Future<String> _saveFile(
    PlatformFile file,
    String customName,
  ) async {
    if (file.path == null) {
      throw Exception(
        'The selected file has no accessible local path.',
      );
    }

    // Get application support directory
    final appDirectory = await getApplicationSupportDirectory();

    // Create files subdirectory
    final filesDirectory = Directory(
      p.join(appDirectory.path, 'SoundFX'),
    );

    await filesDirectory.create(recursive: true);

    // Preserve original extension
    final extension = p.extension(file.name);

    // Remove extension if user entered one
    var name = p.basenameWithoutExtension(
      customName.trim(),
    );

    // Sanitize filename
    name = name.replaceAll(
      RegExp(r'[<>:"/\\|?*\x00-\x1F]'),
      '_',
    );

    if (name.isEmpty) {
      throw Exception('Invalid file name.');
    }

    // Build destination path
    var finalPath = p.join(
      filesDirectory.path,
      '$name$extension',
    );

    // Avoid overwriting existing files
    var counter = 1;

    while (await File(finalPath).exists()) {
      finalPath = p.join(
        filesDirectory.path,
        '$name ($counter)$extension',
      );

      counter++;
    }

    // Copy file
    await File(file.path!).copy(finalPath);

    return finalPath;
  }

  // Show filename dialog
  void _showAddDialog(PlatformFile file) {
    _nameController.text = p.basenameWithoutExtension(file.name);

    showDialog(
      context: context,
      barrierDismissible: !_isSaving,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add file'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected: ${file.name}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    enabled: !_isSaving,
                    decoration: const InputDecoration(
                      hintText: 'Enter file name...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_isSaving) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          final name = _nameController.text.trim();

                          if (name.isEmpty) return;

                          setDialogState(() {
                            _isSaving = true;
                          });

                          try {
                            final savedPath = await _saveFile(
                              file,
                              name,
                            );

                            if (!mounted) return;

                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'File saved successfully: '
                                  '${p.basename(savedPath)}',
                                ),
                              ),
                            );

                            debugPrint(
                              'Saved file: $savedPath',
                            );

                            // TODO: Refresh FilesList
                          } catch (e) {
                            setDialogState(() {
                              _isSaving = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to save file: $e',
                                ),
                              ),
                            );
                          }
                        },
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search files...',
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  // TODO: Filter FilesList
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
