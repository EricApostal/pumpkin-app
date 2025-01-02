import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pumpkin_app/features/pumpkin/models/server.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server.g.dart';

/// A controller that manages the lifecycle of a server process.
/// Ensures only one server instance can run at a time and provides
/// robust error handling and state management.
@Riverpod(keepAlive: true)
class ServerController extends _$ServerController {
  static const platform = MethodChannel('pumpkin');

  static const _operationTimeout = Duration(seconds: 30);
  bool _isOperationInProgress = false;

  @override
  Future<ServerState> build() async {
    return ServerState();
  }

  /// Starts the server if it's not already running.
  /// Returns immediately if a server operation is in progress or if server is already running.
  Future<void> startServer() async {
    if (_isOperationInProgress) {
      print('Server operation already in progress, ignoring start request');
      return;
    }

    final currentState = state.value;
    if (currentState?.status == ServerStatus.running ||
        currentState?.status == ServerStatus.starting) {
      print(
          'Server is already ${currentState?.status}, ignoring start request');
      return;
    }

    _isOperationInProgress = true;

    try {
      state = AsyncData(state.value!.copyWith(status: ServerStatus.starting));

      final serverEnvironment = await _prepareServerEnvironment();

      final process = await _startServerProcess(
        serverEnvironment.executablePath,
        serverEnvironment.workingDirectory,
      );

      _setupProcessListeners(process);

      state = AsyncData(ServerState(
        process: process,
        status: ServerStatus.running,
      ));
    } catch (e, stackTrace) {
      print('Error starting server: $e\n$stackTrace');
      state = AsyncData(ServerState(
        status: ServerStatus.error,
        error: 'Failed to start server: ${e.toString()}',
      ));
    } finally {
      _isOperationInProgress = false;
    }
  }

  /// Prepares the server environment by validating paths and permissions
  Future<ServerEnvironment> _prepareServerEnvironment() async {
    final String nativeLibDir = await platform.invokeMethod('getNativeLibDir');
    final applicationDirectory = await getApplicationDocumentsDirectory();
    final executablePath = '$nativeLibDir/libpumpkin.so';

    if (!await File(executablePath).exists()) {
      throw Exception('Server executable not found at $executablePath');
    }

    if (!await Directory(applicationDirectory.path).exists()) {
      throw Exception(
          'Working directory does not exist: ${applicationDirectory.path}');
    }

    return ServerEnvironment(
      executablePath: executablePath,
      workingDirectory: applicationDirectory.path,
    );
  }

  /// Starts the server process with a timeout
  Future<Process> _startServerProcess(
      String executablePath, String workingDirectory) async {
    return await Process.start(
      executablePath,
      [],
      workingDirectory: workingDirectory,
    ).timeout(
      _operationTimeout,
      onTimeout: () {
        throw TimeoutException('Server start operation timed out');
      },
    );
  }

  /// Sets up listeners for process events and output
  void _setupProcessListeners(Process process) {
    process.exitCode.then((exitCode) {
      if (exitCode != 0 && exitCode != 1) {
        state = AsyncData(ServerState(
          status: ServerStatus.error,
          error: 'Server exited with code $exitCode',
        ));
      } else {
        state = AsyncData(ServerState(status: ServerStatus.stopped));
      }
    }).catchError((error) {
      state = AsyncData(ServerState(
        status: ServerStatus.error,
        error: 'Error monitoring server process: $error',
      ));
    });
  }

  /// Stops the server gracefully with timeout
  Future<void> stopServer() async {
    if (_isOperationInProgress) {
      print('Server operation already in progress, ignoring stop request');
      return;
    }

    final currentProcess = state.value?.process;
    if (currentProcess == null) {
      print('No server process to stop');
      return;
    }

    _isOperationInProgress = true;

    try {
      currentProcess.stdin.writeln("stop");

      bool stopped =
          await _waitForProcessExit(currentProcess, Duration(seconds: 5));

      if (!stopped) {
        currentProcess.kill(ProcessSignal.sigterm);
        stopped =
            await _waitForProcessExit(currentProcess, Duration(seconds: 2));

        if (!stopped) {
          currentProcess.kill(ProcessSignal.sigkill);
        }
      }

      state = AsyncData(ServerState(status: ServerStatus.stopped));
    } catch (e, stackTrace) {
      print('Error stopping server: $e\n$stackTrace');
      state = AsyncData(ServerState(
        status: ServerStatus.error,
        error: 'Failed to stop server: ${e.toString()}',
      ));
    } finally {
      _isOperationInProgress = false;
    }
  }

  /// Waits for process to exit with timeout
  Future<bool> _waitForProcessExit(Process process, Duration timeout) async {
    try {
      await process.exitCode.timeout(timeout);
      return true;
    } on TimeoutException {
      return false;
    }
  }

  /// Restarts the server with proper error handling
  Future<void> restartServer() async {
    if (_isOperationInProgress) {
      print('Server operation already in progress, ignoring restart request');
      return;
    }

    await stopServer();
    await startServer();
  }

  /// Sends a command to the server if it's running
  Future<void> sendCommand(String command) async {
    final currentProcess = state.value?.process;
    if (currentProcess == null) {
      print('No server process to send command to');
      return;
    }

    try {
      currentProcess.stdin.writeln(command);
    } catch (e, stackTrace) {
      print('Error sending command to server: $e\n$stackTrace');
    }
  }
}

@Riverpod(keepAlive: true)
Stream<String> serverLogs(Ref ref) {
  final controller = StreamController<String>();
  final serverState = ref.watch(serverControllerProvider);

  if (serverState.value?.status == ServerStatus.running) {
    final process = serverState.value!.process!;

    process.stdout.transform(SystemEncoding().decoder).listen(
      (data) {
        controller.add('[stdout] $data');
      },
      onError: (error) {
        controller.add('[stdout error] $error');
      },
    );

    process.stderr.transform(SystemEncoding().decoder).listen(
      (data) {
        controller.add('[stderr] $data');
      },
      onError: (error) {
        controller.add('[stderr error] $error');
      },
    );
  }

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
}
