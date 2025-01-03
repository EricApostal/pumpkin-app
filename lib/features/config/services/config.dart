import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:toml/toml.dart';

class ConfigService {
  /// Loads a TOML configuration file
  static Future<TomlDocument?> loadConfig(String fileName) async {
    try {
      final applicationDirectory = await getApplicationDocumentsDirectory();
      final document = await TomlDocument.load(
          '${applicationDirectory.path}/config/$fileName.toml');
      return document;
    } catch (e) {
      print('Error loading config: $e');
      return null;
    }
  }

  /// Saves a configuration to a TOML file
  static Future<void> saveConfig(
      String fileName, Map<String, dynamic> config) async {
    try {
      final document = TomlDocument.fromMap(config);
      final applicationDirectory = await getApplicationDocumentsDirectory();
      final configDir = Directory('${applicationDirectory.path}/config');

      if (!await configDir.exists()) {
        await configDir.create(recursive: true);
      }

      final configFile = File('${configDir.path}/$fileName.toml');
      await configFile.writeAsString(document.toString());
    } catch (e) {
      print('Error saving config: $e');
      rethrow;
    }
  }

  /// Converts nested TOML structure to flat map
  static Map<String, dynamic> flattenConfig(Map<String, dynamic> config,
      [String prefix = '']) {
    final result = <String, dynamic>{};

    config.forEach((key, value) {
      final newKey = prefix.isEmpty ? key : '$prefix.$key';

      if (value is Map<String, dynamic>) {
        result.addAll(flattenConfig(value, newKey));
      } else {
        result[newKey] = value;
      }
    });

    return result;
  }

  /// Converts flat map back to nested structure
  static Map<String, dynamic> unflattenConfig(Map<String, dynamic> flat) {
    final result = <String, dynamic>{};

    flat.forEach((key, value) {
      final parts = key.split('.');
      var current = result;

      for (var i = 0; i < parts.length; i++) {
        final part = parts[i];
        if (i == parts.length - 1) {
          current[part] = value;
        } else {
          current[part] = current[part] ?? <String, dynamic>{};
          current = current[part] as Map<String, dynamic>;
        }
      }
    });

    return result;
  }
}
