import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_logcat_monitor/flutter_logcat_monitor.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pumpkin_app/rust/src/api/simple.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:toml/toml.dart';
import 'dart:developer' as developer;
import 'package:flutter_logcat/flutter_logcat.dart';

part 'server.g.dart';

@Riverpod(keepAlive: true)
class ServerController extends _$ServerController {
  @override
  void build() {}

  Future<void> start() async {
    final directory = Directory(
      "${(await getApplicationDocumentsDirectory()).path}/server",
    );
    await directory.create();
    final configPath = '${directory.path}/config/features.toml';

    FlutterLogcatMonitor.addListen((log) {
      if ((log as String).contains("pumpkin::")) {
        final text = log.split("pumpkin::")[1];
      }
    });
    await FlutterLogcatMonitor.startMonitor("*");
    try {
      TomlDocument document = await TomlDocument.load(configPath);

      final config = document.toMap();

      config["networking"]["rcon"]["enabled"] = true;
      config["networking"]["rcon"]["password"] = "pumpkin";
      TomlDocument newDocument = TomlDocument.fromMap(config);
      final file = File(configPath);
      await file.writeAsString(newDocument.toString());

      print("Starting server!");
      startServer(appDir: directory.path);
    } catch (e, st) {
      print(e);
      print(st);
    }
  }
}

@Riverpod(keepAlive: true)
class ServerLogs extends _$ServerLogs {
  @override
  List<String> build() {
    return [];
  }
}
