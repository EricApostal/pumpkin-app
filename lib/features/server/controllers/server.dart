import 'dart:async';
import 'dart:io';

import 'package:flutter_logcat_monitor/flutter_logcat_monitor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pumpkin_app/rust/src/api/simple.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:toml/toml.dart';

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

    final logsNotifier = ref.read(serverLogsProvider.notifier);

    FlutterLogcatMonitor.addListen((log) {
      if ((log as String).contains("pumpkin::")) {
        final text = log
            .split("pumpkin::")[1]
            .replaceFirst("server: ", '')
            .replaceFirst("server::conn..: ", '')
            .replaceFirst("server::key_..: ", '');
        logsNotifier.addLog(text);
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
      logsNotifier.addLog("Starting server!");
      startServer(appDir: directory.path);
    } catch (e, st) {
      print(e);
      print(st);
      logsNotifier.addLog("Error: $e");
    }
  }
}

@Riverpod(keepAlive: true)
class ServerLogs extends _$ServerLogs {
  final StreamController<String> _logController =
      StreamController<String>.broadcast();
  final List<String> _logs = [];

  @override
  Stream<List<String>> build() async* {
    ref.onDispose(() {
      _logController.close();
    });

    yield List.unmodifiable(_logs);

    await for (final _ in _logController.stream) {
      yield List.unmodifiable(_logs);
    }
  }

  void addLog(String log) {
    _logs.add(log);
    if (_logs.length > 1000) {
      _logs.removeAt(0);
    }
    _logController.add(log);
  }

  void clearLogs() {
    _logs.clear();
    _logController.add('');
  }

  List<String> get currentLogs => List.unmodifiable(_logs);
}
