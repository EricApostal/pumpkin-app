import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:toml/toml.dart';

part 'config.g.dart';

/// Manages the application configuration.
@riverpod
class Config extends _$Config {
  @override
  Future<TomlDocument?> build() async {
    final applicationDirectory = await getApplicationDocumentsDirectory();
    final document = await TomlDocument.load(
        '${applicationDirectory.path}/config/configuration.toml');
    return document;
  }

  Future<void> save(Map<String, dynamic> newConfig) async {
    final document = TomlDocument.fromMap(newConfig);

    final applicationDirectory = await getApplicationDocumentsDirectory();
    final configDir = Directory('${applicationDirectory.path}/config');

    final configFile = File('${configDir.path}/configuration.toml');
    await configFile.writeAsString(document.toString());

    state = AsyncValue.data(document);
  }
}
