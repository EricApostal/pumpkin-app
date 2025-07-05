import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pumpkin_app/features/files/models/file_item.dart';

part 'file_controller.g.dart';

@riverpod
class FileController extends _$FileController {
  @override
  AsyncValue<List<FileItem>> build() {
    return const AsyncValue.loading();
  }

  Future<void> loadDirectory(String? path) async {
    state = const AsyncValue.loading();

    try {
      final String targetPath;
      if (path == null) {
        // Load server directory
        final appDir = await getApplicationDocumentsDirectory();
        targetPath = "${appDir.path}/server";
      } else {
        targetPath = path;
      }

      final directory = Directory(targetPath);

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final entities = await directory.list().toList();
      final files = entities
          .map((entity) => FileItem.fromFileSystemEntity(entity))
          .toList();

      // Sort: directories first, then files, both alphabetically
      files.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      state = AsyncValue.data(files);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<String> readTextFile(String filePath) async {
    try {
      final file = File(filePath);
      return await file.readAsString();
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }

  Future<void> writeTextFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      await file.writeAsString(content);
    } catch (e) {
      throw Exception('Failed to write file: $e');
    }
  }

  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        // Reload current directory
        final currentDir = file.parent.path;
        await loadDirectory(currentDir);
      }
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  Future<void> deleteDirectory(String dirPath) async {
    try {
      final directory = Directory(dirPath);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        // Reload parent directory
        final parentDir = directory.parent.path;
        await loadDirectory(parentDir);
      }
    } catch (e) {
      throw Exception('Failed to delete directory: $e');
    }
  }

  Future<void> createDirectory(String parentPath, String name) async {
    try {
      final newDirPath = '$parentPath/$name';
      final directory = Directory(newDirPath);
      await directory.create();
      await loadDirectory(parentPath);
    } catch (e) {
      throw Exception('Failed to create directory: $e');
    }
  }

  Future<void> createFile(String parentPath, String name) async {
    try {
      final newFilePath = '$parentPath/$name';
      final file = File(newFilePath);
      await file.create();
      await loadDirectory(parentPath);
    } catch (e) {
      throw Exception('Failed to create file: $e');
    }
  }
}

@riverpod
class CurrentDirectory extends _$CurrentDirectory {
  @override
  String? build() {
    return null;
  }

  void setDirectory(String path) {
    state = path;
  }

  void goBack() {
    if (state != null) {
      final directory = Directory(state!);
      final parent = directory.parent;
      state = parent.path;
    }
  }

  String get displayPath {
    if (state == null) return 'Server Root';
    return state!.split('/').last;
  }

  List<String> get breadcrumbs {
    if (state == null) return ['Server Root'];
    return state!.split('/').where((s) => s.isNotEmpty).toList();
  }
}
