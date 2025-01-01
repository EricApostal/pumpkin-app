import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pumpkin_app/features/pumpkin/models/server.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server.g.dart';

@Riverpod(keepAlive: true)
class ServerController extends _$ServerController {
  static const platform = MethodChannel('pumpkin');

  @override
  Future<ServerState> build() async {
    return ServerState();
  }

  Future<void> startServer() async {
    try {
      state = AsyncData(state.value!.copyWith(status: ServerStatus.starting));

      final String nativeLibDir =
          await platform.invokeMethod('getNativeLibDir');
      final applicationDirectory = await getApplicationDocumentsDirectory();
      final executablePath = '$nativeLibDir/libpumpkin.so';

      var process = await Process.start(
        executablePath,
        [],
        workingDirectory: applicationDirectory.path,
      );

      state = AsyncData(ServerState(
        process: process,
        status: ServerStatus.running,
      ));

      _setupProcessListeners(process);
    } catch (e) {
      state = AsyncData(ServerState(
        status: ServerStatus.error,
        error: e.toString(),
      ));
    }
  }

  void _setupProcessListeners(Process process) {
    process.exitCode.then((exitCode) {
      if (exitCode != 0) {
        state = AsyncData(ServerState(
          status: ServerStatus.error,
          error: 'Server exited with code $exitCode',
        ));
      } else {
        state = AsyncData(ServerState(status: ServerStatus.stopped));
      }
    });
  }

  Future<void> stopServer() async {
    final currentProcess = state.value?.process;
    if (currentProcess != null) {
      currentProcess.stdin.writeln("stop");
      state = AsyncData(ServerState(status: ServerStatus.stopped));
    }
  }

  Future<void> restartServer() async {
    await stopServer();
    await startServer();
  }

  Future<void> sendCommand(String command) async {
    final currentProcess = state.value?.process;
    if (currentProcess != null) {
      currentProcess.stdin.writeln(command);
    }
  }
}

@Riverpod(keepAlive: true)
Stream<String> serverLogs(Ref ref) {
  final controller = StreamController<String>();
  final serverState = ref.watch(serverControllerProvider);

  if (serverState.value?.status == ServerStatus.running) {
    final process = serverState.value!.process!;

    process.stdout.transform(SystemEncoding().decoder).listen((data) {
      controller.add('[stdout] $data');
    });

    process.stderr.transform(SystemEncoding().decoder).listen((data) {
      controller.add('[stderr] $data');
    });
  }

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
}
