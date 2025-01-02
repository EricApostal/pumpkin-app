import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:toml/toml.dart';

part 'features.g.dart';

/// Manages the application configuration.
@riverpod
class Features extends _$Features {
  @override
  Future<TomlDocument?> build() async {
    final applicationDirectory = await getApplicationDocumentsDirectory();

    final document = await TomlDocument.load(
        '${applicationDirectory.path}/config/features.toml');
    return document;
  }

  Future<void> save(Map<String, dynamic> newConfig) async {
    final document = TomlDocument.fromMap(newConfig);

    final applicationDirectory = await getApplicationDocumentsDirectory();
    final configDir = Directory('${applicationDirectory.path}/config');

    // if (!await configDir.exists()) {
    //   await configDir.create(recursive: true);
    // }

    print("writing: ${document.toString()}");

    final configFile = File('${configDir.path}/features.toml');
    await configFile.writeAsString(document.toString());

    state = AsyncValue.data(document);
  }
}
