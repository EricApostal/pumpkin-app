import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pumpkin_app/features/files/controllers/file_controller.dart';

class FileViewer extends ConsumerStatefulWidget {
  final String filePath;

  const FileViewer({super.key, required this.filePath});

  @override
  ConsumerState<FileViewer> createState() => _FileViewerState();
}

class _FileViewerState extends ConsumerState<FileViewer> {
  late TextEditingController _controller;
  bool _isEditing = false;
  bool _isLoading = true;
  String? _error;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadFile();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadFile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final content = await ref
          .read(fileControllerProvider.notifier)
          .readTextFile(widget.filePath);
      _controller.text = content;
      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveFile() async {
    try {
      await ref
          .read(fileControllerProvider.notifier)
          .writeTextFile(widget.filePath, _controller.text);
      setState(() {
        _hasChanges = false;
        _isEditing = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('File saved successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving file: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.filePath.split('/').last;

    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
        actions: [
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                if (_hasChanges) {
                  _showDiscardChangesDialog();
                } else {
                  setState(() {
                    _isEditing = false;
                  });
                }
              },
              tooltip: "Cancel editing",
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _hasChanges ? _saveFile : null,
              tooltip: "Save file",
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: "Edit file",
            ),
            IconButton(
              icon: const Icon(Icons.content_copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _controller.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Content copied to clipboard')),
                );
              },
              tooltip: "Copy content",
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadFile,
              tooltip: "Reload file",
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading file',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadFile, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_hasChanges)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('You have unsaved changes'),
                ],
              ),
            ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: _isEditing
                  ? TextField(
                      controller: _controller,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      onChanged: (value) {
                        if (!_hasChanges) {
                          setState(() {
                            _hasChanges = true;
                          });
                        }
                      },
                    )
                  : SingleChildScrollView(
                      child: SelectableText(
                        _controller.text,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                    ),
            ),
          ),
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (_hasChanges) {
                          _showDiscardChangesDialog();
                        } else {
                          setState(() {
                            _isEditing = false;
                          });
                        }
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _hasChanges ? _saveFile : null,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showDiscardChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes'),
        content: const Text('Are you sure you want to discard your changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadFile(); // Reload original content
              setState(() {
                _isEditing = false;
                _hasChanges = false;
              });
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
}
