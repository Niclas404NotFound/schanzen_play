import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FilesList extends StatefulWidget {
  const FilesList({super.key});

  @override
  State<FilesList> createState() => _FilesListState();
}

class _FilesListState extends State<FilesList> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription<FileSystemEvent>? _watchSubscription;

  @override
  void initState() {
    super.initState();
    _initDirectoryAndWatch();
  }

  Future<void> _initDirectoryAndWatch() async {
    try {
      final Directory baseDir = await getApplicationSupportDirectory();
      final Directory subDir = Directory('${baseDir.path}/SoundFX');

      if (!await subDir.exists()) {
        await subDir.create(recursive: true);
      }

      // 1. Load initial files
      await _refreshFiles(subDir);

      // 2. Listen for any file additions, deletions, or renames
      _watchSubscription = subDir.watch().listen((FileSystemEvent event) {
        _refreshFiles(subDir);
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshFiles(Directory dir) async {
    final List<FileSystemEntity> entities = await dir.list().toList();
    if (mounted) {
      setState(() {
        _files = entities;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Always cancel the watcher when the widget is closed to prevent memory leaks
    _watchSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text('Error: $_error')),
      );
    }

    if (_files.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No files found')),
      );
    }

    return Scaffold(
      body: ListView.separated(
        itemCount: _files.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final entity = _files[index];
          final fileName = entity.uri.pathSegments.lastWhere(
            (segment) => segment.isNotEmpty,
            orElse: () => entity.path,
          );

          return ListTile(
            leading: Icon(
              entity is Directory ? Icons.folder : Icons.insert_drive_file,
            ),
            title: Text(fileName),
          );
        },
      ),
    );
  }
}
