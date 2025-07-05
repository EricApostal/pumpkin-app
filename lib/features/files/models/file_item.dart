import 'dart:io';

enum FileType {
  directory,
  textFile,
  configFile,
  logFile,
  jarFile,
  imageFile,
  unknownFile,
}

class FileItem {
  final String name;
  final String path;
  final FileType type;
  final int size;
  final DateTime lastModified;
  final bool isDirectory;
  final bool isHidden;

  FileItem({
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    required this.lastModified,
    required this.isDirectory,
    this.isHidden = false,
  });

  factory FileItem.fromFileSystemEntity(FileSystemEntity entity) {
    final stat = entity.statSync();
    final name = entity.path.split('/').last;
    final isDirectory = entity is Directory;
    final isHidden = name.startsWith('.');

    return FileItem(
      name: name,
      path: entity.path,
      type: _getFileType(name, isDirectory),
      size: stat.size,
      lastModified: stat.modified,
      isDirectory: isDirectory,
      isHidden: isHidden,
    );
  }

  static FileType _getFileType(String name, bool isDirectory) {
    if (isDirectory) return FileType.directory;

    final extension = name.split('.').last.toLowerCase();
    switch (extension) {
      case 'txt':
      case 'md':
      case 'yml':
      case 'yaml':
        return FileType.textFile;
      case 'toml':
      case 'json':
      case 'properties':
      case 'cfg':
      case 'conf':
        return FileType.configFile;
      case 'log':
        return FileType.logFile;
      case 'jar':
        return FileType.jarFile;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
        return FileType.imageFile;
      default:
        return FileType.unknownFile;
    }
  }

  String get sizeFormatted {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024)
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  String get lastModifiedFormatted {
    final now = DateTime.now();
    final difference = now.difference(lastModified);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
