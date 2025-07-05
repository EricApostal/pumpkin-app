import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pumpkin_app/features/files/controllers/file_controller.dart';
import 'package:pumpkin_app/features/files/models/file_item.dart';
import 'package:pumpkin_app/features/files/views/file_viewer.dart';

class FileBrowserScreen extends ConsumerStatefulWidget {
  const FileBrowserScreen({super.key});

  @override
  ConsumerState<FileBrowserScreen> createState() => _FileBrowserScreenState();
}

class _FileBrowserScreenState extends ConsumerState<FileBrowserScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fileControllerProvider.notifier).loadDirectory(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filesAsyncValue = ref.watch(fileControllerProvider);
    final currentDirectory = ref.watch(currentDirectoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Files"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(fileControllerProvider.notifier)
                  .loadDirectory(currentDirectory);
            },
            tooltip: "Refresh",
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'create_folder') {
                _showCreateDialog(context, true);
              } else if (value == 'create_file') {
                _showCreateDialog(context, false);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'create_folder',
                child: Row(
                  children: [
                    Icon(Icons.folder_outlined),
                    SizedBox(width: 8),
                    Text('New Folder'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'create_file',
                child: Row(
                  children: [
                    Icon(Icons.description_outlined),
                    SizedBox(width: 8),
                    Text('New File'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Breadcrumb navigation
          if (currentDirectory != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      ref.read(currentDirectoryProvider.notifier).goBack();
                      ref
                          .read(fileControllerProvider.notifier)
                          .loadDirectory(ref.read(currentDirectoryProvider));
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: _buildBreadcrumbs(context)),
                    ),
                  ),
                ],
              ),
            ),
          // File list
          Expanded(
            child: filesAsyncValue.when(
              data: (files) => files.isEmpty
                  ? const Center(
                      child: Text(
                        "No files in this directory",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        final file = files[index];
                        return _buildFileItem(context, file);
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading files: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(fileControllerProvider.notifier)
                            .loadDirectory(currentDirectory);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBreadcrumbs(BuildContext context) {
    final breadcrumbs = ref.read(currentDirectoryProvider.notifier).breadcrumbs;
    final List<Widget> widgets = [];

    for (int i = 0; i < breadcrumbs.length; i++) {
      widgets.add(
        TextButton(
          onPressed: i == breadcrumbs.length - 1
              ? null
              : () {
                  // Navigate to this breadcrumb level
                  // Implementation depends on your navigation structure
                },
          child: Text(
            breadcrumbs[i],
            style: TextStyle(
              color: i == breadcrumbs.length - 1
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      );

      if (i < breadcrumbs.length - 1) {
        widgets.add(const Icon(Icons.chevron_right));
      }
    }

    return widgets;
  }

  Widget _buildFileItem(BuildContext context, FileItem file) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: _getFileIcon(file.type),
        title: Text(
          file.name,
          style: TextStyle(
            fontWeight: file.isDirectory ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: file.isDirectory
            ? null
            : Text('${file.sizeFormatted} • ${file.lastModifiedFormatted}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteDialog(context, file);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          if (file.isDirectory) {
            ref.read(currentDirectoryProvider.notifier).setDirectory(file.path);
            ref.read(fileControllerProvider.notifier).loadDirectory(file.path);
          } else {
            _openFile(context, file);
          }
        },
      ),
    );
  }

  Icon _getFileIcon(FileType type) {
    switch (type) {
      case FileType.directory:
        return const Icon(Icons.folder, color: Colors.blue);
      case FileType.textFile:
        return const Icon(Icons.description, color: Colors.green);
      case FileType.configFile:
        return const Icon(Icons.settings, color: Colors.orange);
      case FileType.logFile:
        return const Icon(Icons.article, color: Colors.purple);
      case FileType.jarFile:
        return const Icon(Icons.archive, color: Colors.brown);
      case FileType.imageFile:
        return const Icon(Icons.image, color: Colors.pink);
      case FileType.unknownFile:
        return const Icon(Icons.insert_drive_file, color: Colors.grey);
    }
  }

  void _openFile(BuildContext context, FileItem file) {
    if (file.type == FileType.textFile ||
        file.type == FileType.configFile ||
        file.type == FileType.logFile) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FileViewer(filePath: file.path),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot open ${file.name}: Unsupported file type'),
        ),
      );
    }
  }

  void _showCreateDialog(BuildContext context, bool isFolder) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isFolder ? 'Create Folder' : 'Create File'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: isFolder ? 'Folder name' : 'File name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final currentDir = ref.read(currentDirectoryProvider);
                try {
                  if (isFolder) {
                    await ref
                        .read(fileControllerProvider.notifier)
                        .createDirectory(currentDir ?? '', name);
                  } else {
                    await ref
                        .read(fileControllerProvider.notifier)
                        .createFile(currentDir ?? '', name);
                  }
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, FileItem file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Are you sure you want to delete "${file.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                if (file.isDirectory) {
                  await ref
                      .read(fileControllerProvider.notifier)
                      .deleteDirectory(file.path);
                } else {
                  await ref
                      .read(fileControllerProvider.notifier)
                      .deleteFile(file.path);
                }
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
