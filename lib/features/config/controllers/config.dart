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

    print("loading config from: ${applicationDirectory.path}");

    final document = await TomlDocument.load(
        '${applicationDirectory.path}/config/configuration.toml');
    print("CONTENTS: ----");
    print(document.toString());
    print("----");

    return document;
  }

  Future<void> save(Map<String, dynamic> newConfig) async {
    // Convert the map to a TOML document
    final document = TomlDocument.fromMap(newConfig);

    final applicationDirectory = await getApplicationDocumentsDirectory();
    final configDir = Directory('${applicationDirectory.path}/config');

    // if (!await configDir.exists()) {
    //   await configDir.create(recursive: true);
    // }

    print("writing: ${document.toString()}");

    final configFile = File('${configDir.path}/configuration.toml');
    await configFile.writeAsString(document.toString());

    state = AsyncValue.data(document);
  }
}
