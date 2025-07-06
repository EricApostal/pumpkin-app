import 'dart:async';
import 'dart:io';

import 'package:flutter_native_log_handler/flutter_native_logs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pumpkin_app/rust/src/api/simple.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server.g.dart';

@Riverpod(keepAlive: true)
class ServerController extends _$ServerController {
  StreamSubscription<NativeLogMessage>? _logSubscription;
  PumpkinServer? _server;

  @override
  bool build() {
    return false;
  }

  Future<void> stop() async {
    if (_server != null) {
      await _server!.stop();
      _server = null;
    }
    state = false;
    ref.read(serverLogsProvider.notifier).clearLogs();
    await _logSubscription?.cancel();
  }

  Future<void> sendCommand(String command) async {
    if (_server != null) {
      await _server!.runCommand(command: command);
    }
  }

  Future<void> start() async {
    final directory = Directory(
      "${(await getApplicationDocumentsDirectory()).path}/server",
    );
    await directory.create();

    final logsNotifier = ref.read(serverLogsProvider.notifier);

    _logSubscription = FlutterNativeLogs().logStream.listen((
      NativeLogMessage message,
    ) {
      logsNotifier.addLog(message.message);
    });

    try {
      print("Starting server!");
      logsNotifier.addLog("Starting server!");
      state = true;

      _server ??= await PumpkinServer.newInstance(appDir: directory.path);
      await _server!.start();

      state = false;
      ref.read(serverLogsProvider.notifier).clearLogs();
    } catch (e, st) {
      print(e);
      print(st);
      logsNotifier.addLog("Error: $e");
      state = false;
      ref.read(serverLogsProvider.notifier).clearLogs();
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
